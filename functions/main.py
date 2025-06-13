from firebase_functions import firestore_fn, db_fn, https_fn
from firebase_admin import initialize_app, firestore, messaging
app = initialize_app()


import google.cloud.firestore
from firebase_functions.params import StringParam
import json
import requests
import pandas as pd
import numpy as np
from datetime import datetime
from sklearn.cluster import DBSCAN


api_key = StringParam("API_KEY")

type_data = {
    "parking": {
        "status": "Transit",
        "emoji": "🅿️"
    },
    "corporate_office": {
        "status": "Working",
        "emoji": "💼"
    },
    "auditorium": {
        "status": "Taking class/Watching concerts",
        "emoji": "🎶"
    },
    "library": {
        "status": "Reading/Studying",
        "emoji": "📚"
    },
    "preschool": {
        "status": "Preschool",
        "emoji": "👶"
    },
    "school": {
        "status": "School",
        "emoji": "🏫"
    },
    "university": {
        "status": "University",
        "emoji": "🎓"
    },
    "community_center": {
        "status": "Community Center",
        "emoji": "🤝"
    },
    "convention_center": {
        "status": "Business",
        "emoji": "💼"
    },
    "dance_hall": {
        "status": "Dancing",
        "emoji": "💃"
    },
    "dog_park": {
        "status": "Relaxing",
        "emoji": "😌"
    },
    "internet_cafe": {
        "status": "Internet Café",
        "emoji": "💻"
    },
    "movie_theater": {
        "status": "Entertainment",
        "emoji": "🎭"
    },
    "night_club": {
        "status": "Socializing",
        "emoji": "🥂"
    },
    "park": {
        "status": "Relaxing/Playing at Park",
        "emoji": "😌"
    },
    "skateboard_park": {
        "status": "Skateboarding",
        "emoji": "🛹"
    },
    "state_park": {
        "status": "Skating",
        "emoji": "⛸️"
    },
    "bar": {
        "status": "Drinking/Socializing at bar",
        "emoji": "🥂"
    },
    "cafe": {
        "status": "Eating/Working at café",
        "emoji": "☕"
    },
    "cafeteria": {
        "status": "Eating/Working at cafeteria",
        "emoji": "☕"
    },
    "cat_cafe": {
        "status": "Cat café",
        "emoji": "🐱"
    },
    "fast_food_restaurant": {
        "status": "Grabbing food",
        "emoji": "🍔"
    },
    "food_court": {
        "status": "Grabbing food",
        "emoji": "🍔"
    },
    "pub": {
        "status": "Eating at favorite restaurant",
        "emoji": "🍽️"
    },
    "restaurant": {
        "status": "Eating at favorite restaurant",
        "emoji": "🍽️"
    },
    "doctor": {
        "status": "Clinic",
        "emoji": "🩺"
    },
    "drugstore": {
        "status": "Shopping",
        "emoji": "🛍️"
    },
    "hospital": {
        "status": "Hospital",
        "emoji": "🏥"
    },
    "sauna": {
        "status": "Sauna",
        "emoji": "🧖‍♀️"
    },
    "beach": {
        "status": "Leisure/Relaxing at beach",
        "emoji": "🏖️"
    },
    "church": {
        "status": "Religious Activity",
        "emoji": "🙏"
    },
    "hindu_temple": {
        "status": "Religious Activity",
        "emoji": "🙏"
    },
    "mosque": {
        "status": "Religious Activity",
        "emoji": "🙏"
    },
    "synagogue": {
        "status": "Religious Activity",
        "emoji": "🙏"
    },
    "laundry": {
        "status": "Laundry",
        "emoji": "🧺"
    },
    "nail_salon": {
        "status": "Selfcare",
        "emoji": "💆‍♀️"
    },
    "convenience_store": {
        "status": "Convenience Store",
        "emoji": "🏪"
    },
    "grocery_store": {
        "status": "Grocery Shopping",
        "emoji": "🛒"
    },
    "market": {
        "status": "Shopping",
        "emoji": "🛍️"
    },
    "shopping_mall": {
        "status": "Shopping",
        "emoji": "🛍️"
    },
    "store": {
        "status": "Shopping",
        "emoji": "🛍️"
    },
    "supermarket": {
        "status": "Grocery Shopping",
        "emoji": "🛒"
    },
    "gym": {
        "status": "Gym",
        "emoji": "💪"
    },
    "playground": {
        "status": "Playing",
        "emoji": "🤸"
    },
    "sports_activity_location": {
        "status": "Sports",
        "emoji": "🏃‍♀️"
    },
    "swimming_pool": {
        "status": "Swimming",
        "emoji": "🏊‍♀️"
    },
    "airport": {
        "status": "$name",
        "emoji": "✈️"
    },
    "bus_stop": {
        "status": "Commuting",
        "emoji": "🚌"
    },
    "transit_station": {
        "status": "$name",
        "emoji": "🚉"
    }
}


def cluster_behaviors(data):
  df = pd.DataFrame(data)
  df['t'] = pd.to_datetime(df['t'])

  df['w'] = (df['t'].shift(-1) - df['t']).dt.total_seconds().fillna(0)

  coords = df[['x','y']].to_numpy()
  # if coords are lat/lon, convert to radians and use haversine:
  radians = np.radians(coords)
  kms_per_radian = 6371.0088
  epsilon = 0.05 / kms_per_radian  # ~50 m neighborhood

  db = DBSCAN(eps=epsilon, min_samples=1, metric='haversine')
  df['cluster'] = db.fit_predict(radians)

  agg = df.groupby('cluster').agg(
      centroid_lat = ('x',  'mean'),
      centroid_lon = ('y',  'mean'),
      total_time_s = ('w',  'sum'),
      visit_counts = ('w', lambda w: (w>0).sum())  # number of intervals
  ).reset_index()

  # score by total_time (you can combine counts & recency if you like)
  agg = agg.sort_values(by='total_time_s', ascending=False)
  return agg

def find_nearby_places(api_key, lat, lng, radius, maxResultCount=10, place_types=None):
  url = "https://places.googleapis.com/v1/places:searchNearby"
  headers = {
      "Content-Type": "application/json",
      "X-Goog-Api-Key": api_key.value,
      # Field mask must **not** include spaces around commas
      "X-Goog-FieldMask": "places.displayName,places.id,places.types,places.formattedAddress"
  }
  body = {
      "includedTypes": place_types,
      "maxResultCount": maxResultCount,
      "rankPreference": "POPULARITY",
      "locationRestriction": {
          "circle": {
              "center": {"latitude": lat, "longitude": lng},
               "radius": radius
          },
      },
  }

  res = requests.post(url, headers=headers, json=body, timeout=10)

  # 1️⃣ HTTP-level error handling
  try:
      res.raise_for_status()
  except requests.HTTPError as e:
      print("HTTP error:", e, "| Response:", res.text)
      raise

  # 2️⃣ JSON parsing
  try:
      data = res.json()
  except ValueError:
      raise RuntimeError("Response not valid JSON:\n" + res.text)

#   # 3️⃣ API-level error handling
#   if "places" not in data:
#       error_msg = data.get("error", {}).get("message", str(data))
#       raise RuntimeError(f"API error or malformed response: {error_msg}")

  # 4️⃣ Iterate results safely
  for p in data.get("places", []):
      name = p.get("displayName", {}).get("text") or p.get("displayName") or "<no-name>"
      types = p.get("types", [])
      address = p.get("formattedAddress", "<no-address>")
      print(f"{name} | types: {types} | address: {address}")
  return data.get("places", [])

@https_fn.on_call(
    enforce_app_check=True,
    memory=512
)
def analyze_behavior(req: https_fn.CallableRequest) -> dict:
    behavior_data_str = req.data #pass through some kind of network

    suggested_status = []
    #turn json into dic
    behavior_data = json.loads(behavior_data_str)
    sorted_clusters = cluster_behaviors(behavior_data)
    sorted_clusters = sorted_clusters.reset_index()

    three_clusters = sorted_clusters.loc[0:2, ['centroid_lat', 'centroid_lon']]
    print("three clusters:")
    print(three_clusters)

    for _, cluster in three_clusters.iterrows():
        lat = cluster['centroid_lat']
        lng = cluster['centroid_lon']
        place_type = list(type_data.keys())
        places = find_nearby_places(api_key, lat, lng, 100, maxResultCount=1, place_types=place_type)
        radius = 100
        for place in places:
            name = place.get("displayName", {}).get("text")
            types = place.get("types", [])
            for type in types:
                if type in type_data:
                    suggested_status.append({'status': type_data[type]['status'], 
                                             'emoji': type_data[type]['emoji'],
                                             'lat': lat, 'lng': lng,
                                             'name': name,
                                             'radius': radius
                                             })
                    break

    # Print the suggested places
    print("Suggested Places:")
    for status in suggested_status:
        print(f" - {status}")
    return {"suggested_status": suggested_status}


@firestore_fn.on_document_created(
    document="userProfiles/{uid}",
)
def onUserProfileCreated(event: firestore_fn.Event[firestore_fn.DocumentSnapshot | None]) -> None:
    print("onUserProfileChanged")
    firestore_client = firestore.client()

    if event.data is None:
        return
    try:
        userUID = event.params['uid']
        profile_dict = event.data.to_dict() 
        bio = profile_dict['bio']
        name = profile_dict['username']
        iconLink = profile_dict['iconLink']
        print("userUID", userUID)
        print("bio", bio)
        print("name", name)


    except KeyError:
        return

    friend_list_doc = firestore_client.collection("friendList").document(userUID).get()

    if friend_list_doc.exists:
        friend_list_data = friend_list_doc.to_dict().get("friendList", [])
    else:
        friend_list_data = []

    for friend_uid in friend_list_data:
        firestore_client.collection("friendList").document(friend_uid).set({
            "profiles": {
                userUID: {
                    "bio": bio,
                    "username": name,
                    "iconLink": iconLink,
                    "userUID": userUID
                }
            }
        }, merge=True)


@firestore_fn.on_document_updated(
    document="userProfiles/{uid}",
)
def onUserProfileChanged(event: firestore_fn.Event[firestore_fn.DocumentSnapshot | None]) -> None:
    print("onUserProfileChanged")
    firestore_client = firestore.client()

    if event.data is None:
        return
    try:
        userUID = event.params['uid']
        profile_dict = event.data.after.to_dict() 
        bio = profile_dict['bio']
        name = profile_dict['username']
        iconLink = profile_dict['iconLink']
        print("userUID", userUID)
        print("bio", bio)
        print("name", name)


        
    except KeyError:
        return

    friend_list_doc = firestore_client.collection("friendList").document(userUID).get()

    if friend_list_doc.exists:
        friend_list_data = friend_list_doc.to_dict().get("friendList", [])
    else:
        friend_list_data = []

    for friend_uid in friend_list_data:
        firestore_client.collection("friendList").document(friend_uid).set({
            "profiles": 
            {userUID: {
                "bio": bio,
                "username": name,
                "iconLink": iconLink,
                "userUID": userUID
            }}
        }, merge=True)

@firestore_fn.on_document_deleted(
    document="friendList/{uid}",
)
def onUserProfileDeleted(event: firestore_fn.Event[firestore_fn.Change[firestore_fn.DocumentSnapshot | None]]) -> None:
    print("onUserProfileDeleted")
    firestore_client = firestore.client()

    if event.data is None:
        return
    try:
        
        userUID = event.params['uid']
        print("deleted", userUID)
        
    except KeyError:
        return

    friend_list_dict = event.data.to_dict() 

    if friend_list_dict is not None:
        friend_list_data = friend_list_dict.get("friendList", [])
    else:
        friend_list_data = []

    for friend_uid in friend_list_data:
        firestore_client.collection("friendList").document(friend_uid).update({
            f"profiles.{userUID}": firestore.DELETE_FIELD
        })
        firestore_client.collection("friendList").document(friend_uid).update({
            "friendList": firestore.ArrayRemove([userUID])
        })

@firestore_fn.on_document_created(
    document="message/{docId}",
)
def onNotificationUploaded(event: firestore_fn.Event[firestore_fn.Change[firestore_fn.DocumentSnapshot | None]]) -> None:

    print("onNotificationUploaded")
    if event.data is None:
        return
    try:
        docId = event.params['docId']
        profile_dict = event.data.to_dict() 
        title = profile_dict['title']
        body = profile_dict['body']
        imageUrl = profile_dict['imageUrl']
        senderUid = profile_dict['senderUID']
        receiverTokens =  profile_dict['receiverTokens']

        message = messaging.MulticastMessage(
            notification=messaging.Notification(
            title=title,
            body=body,
            ),
            data={
                "imageUrl": imageUrl,
                "senderUID": senderUid,
            },
            tokens=receiverTokens
        )
        response = messaging.send_each_for_multicast(message)
        print(f"Successfully sent message")
    except KeyError as e:
        missing_key = str(e).strip("'")
        print(f"KeyError: Missing required field '{missing_key}' in the document. Ensure that all necessary fields are present.")
        return
    
@db_fn.on_value_updated(reference="/users/{uid}")
def onStatusUpdated(event: db_fn.Event[db_fn.Change]):
    print("onStatusUpdated")
    if event.data is None:
        return
    try:
        status = event.data.after.get('status', 'offline')
        icon = event.data.after.get('icon', 'https://hpgpixer.jp/image_icons/animals/animal_icon/cat/cat_12.gif')
        print("status", status)
        userUID = event.params['uid']

        statusText = icon + " " + status
        
        firebase_client = firestore.client()
        data = firebase_client.collection("friendList").document(userUID).get()
        data_dict = data.to_dict()
        receiverTokens = data_dict.get("firstFriendTokenList", [])
        if receiverTokens is None or receiverTokens == [] or receiverTokens == [""]:
            print("No friend list found for user:", userUID)

        else:
            print("receiverTokens", receiverTokens)
            print("uid", userUID)

            message = messaging.MulticastMessage(
                data={
                    "status": statusText
                },
                tokens=receiverTokens
            )
            response = messaging.send_each_for_multicast(message)


    except KeyError as e:
        missing_key = str(e).strip("'")
        print(f"KeyError: Missing required field '{missing_key}' in the document. Ensure that all necessary fields are present.")
        return

