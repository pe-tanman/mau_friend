import json
import requests
import pandas as pd
import numpy as np
from datetime import datetime
from geopy.distance import great_circle
from sklearn.cluster import DBSCAN



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
      "X-Goog-Api-Key": api_key,
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

  # 3️⃣ API-level error handling
  if "places" not in data:
      error_msg = data.get("error", {}).get("message", str(data))
      raise RuntimeError(f"API error or malformed response: {error_msg}")

  # 4️⃣ Iterate results safely
  for p in data.get("places", []):
      name = p.get("displayName", {}).get("text") or p.get("displayName") or "<no-name>"
      types = p.get("types", [])
      address = p.get("formattedAddress", "<no-address>")
      print(f"{name} | types: {types} | address: {address}")
  return data.get("places", [])


def main():
    api_key = "AIzaSyDj1ij__giQWoAg-ExwAnxe1Tgb1jqoDhM"
    behavior_data_path = 'python/behavior_sample.json'
    type_json_path = 'python/type_data.json'

    suggested_status = []
    #turn json into dic
    with open(behavior_data_path, "r") as file:
        behavior_data = json.load(file) 
    with open(type_json_path, "r") as file:
        type_data = json.load(file)

    sorted_clusters = cluster_behaviors(behavior_data)

    #print
    for _, cluster in sorted_clusters.iterrows():
        print(f"Cluster {cluster['cluster']}: Centroid ({cluster['centroid_lat']}, {cluster['centroid_lon']}), "
              f"Total Time: {cluster['total_time_s']}s, Visit Counts: {cluster['visit_counts']}")

    three_clusters = sorted_clusters.loc[0:3, ['centroid_lat', 'centroid_lon']]


    for _, cluster in three_clusters.iterrows():
        lat = cluster['centroid_lat']
        lng = cluster['centroid_lon']
        place_type = list(type_data.keys())
        data = find_nearby_places(api_key, lat, lng, 100, maxResultCount=2, place_types=place_type)
        places = data.get("places", [])
        for place in places:
            name = place.get("displayName", {}).get("text")
            types = place.get("types", [])
            for type in types:
                if type in type_data:
                    suggested_status.append({'status': type_data[type]['status'], 
                                             'emoji': type_data[type]['emoji'],
                                             'lat': lat, 'lng': lng,
                                             'name': name})
        data = find_nearby_places(api_key, lat, lng, 100, maxResultCount=2, place_types=place_type)
        places = data.get("places", [])
        for place in places:
            name = place.get("displayName", {}).get("text")
            types = place.get("types", [])
            for type in types:
                if type in type_data:
                    suggested_status.append({'status': type_data[type]['status'], 
                                             'emoji': type_data[type]['emoji'],
                                             'lat': lat, 'lng': lng,
                                             'name': name})


    # Print the suggested places
    print("Suggested Places:")
    for status in suggested_status:
        print(f" - {status}")

if __name__ == "__main__":
    main()