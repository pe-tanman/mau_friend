from firebase_functions import firestore_fn

from firebase_admin import initialize_app, firestore
import google.cloud.firestore

app = initialize_app()


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
            "profiles": firestore.ArrayUnion([{
            userUID: {
                "bio": bio,
                "username": name,
                "iconLink": iconLink,
                "userUID": userUID
            }
            }])
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
            "profiles": firestore.ArrayRemove([userUID])
        })
        firestore_client.collection("friendList").document(friend_uid).update({
            "friendList": firestore.ArrayRemove([userUID])
        })
