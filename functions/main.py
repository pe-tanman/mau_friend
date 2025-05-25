from firebase_functions import firestore_fn

from firebase_admin import initialize_app, firestore, messaging
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
        imageUrl = profile_dict['iconLink']
        senderUid = profile_dict['senderUID']
        #receiverTokens =  profile_dict['receiverTokens']
        receiverTokens = ['dtLCkHfhI0x1ihfgeA-Ouo:APA91bHCO1yfs2H2EpkPXMB1xdbjwMLn51pwh1sBgtVdoJOYEU8myMHTp4hNm3H_YX1zBsCgqpfgCHSIr5QZXRZ6TMGQ_NlpWfm2Nao2VkTynSpYNNcY0fE']

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
        response = messaging.send_multicast(message)
        print(f"Successfully sent message: {response.success_count} messages sent.")
    except KeyError:
        print("KeyError: Missing required fields in the document.")
        return