import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:teachme/screens/chat_page.dart';
import 'package:teachme/utils/config.dart';
import 'package:teachme/utils/translate.dart';
import 'package:teachme/widgets/standard_app_bar.dart';

class MessagesPage extends StatelessWidget {
  static const routeName = 'messages';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: standardAppBar(context, "messages"),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 10),
        child: _buildUserList(),
      ),
    );
  }

  Widget _buildUserList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('chat_rooms').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) return Text('Error');
        if (snapshot.connectionState == ConnectionState.waiting)
          return Text('Loading');

        final chatRooms =
            snapshot.data!.docs.where((doc) {
              final data = doc.data()! as Map<String, dynamic>;
              return data['participants'] != null &&
                  (data['participants'] as List).contains(currentUser.id);
            }).toList();

        if (chatRooms.isEmpty) {
          return _noChatsAlert(context);
        }

        return ListView.builder(
          itemCount: chatRooms.length,
          itemBuilder: (context, index) {
            final chatRoom = chatRooms[index];
            return _buildChatListItem(chatRoom, context);
          },
        );
      },
    );
  }

  Widget _buildChatListItem(DocumentSnapshot chatRoom, BuildContext context) {
    final data = chatRoom.data()! as Map<String, dynamic>;
    final participants = List<String>.from(data['participants'] ?? []);
    final otherUserId = participants.firstWhere(
      (id) => id != currentUser.id,
      orElse: () => '',
    );

    if (otherUserId.isEmpty) return Container();

    return FutureBuilder<DocumentSnapshot>(
      future:
          FirebaseFirestore.instance.collection('users').doc(otherUserId).get(),
      builder: (context, userSnapshot) {
        if (!userSnapshot.hasData || !userSnapshot.data!.exists)
          return Container();

        final userData = userSnapshot.data!.data()! as Map<String, dynamic>;

        return StreamBuilder<QuerySnapshot>(
          stream:
              FirebaseFirestore.instance
                  .collection('chat_rooms')
                  .doc(chatRoom.id)
                  .collection('messages')
                  .orderBy('timestamp', descending: true)
                  .limit(1)
                  .snapshots(),
          builder: (context, messageSnapshot) {
            String lastMessage = '';
            String time = '';

            if (messageSnapshot.hasData &&
                messageSnapshot.data!.docs.isNotEmpty) {
              final msg =
                  messageSnapshot.data!.docs.first.data()!
                      as Map<String, dynamic>;
              lastMessage = msg['message'] ?? '';
              final timestamp = msg['timestamp'] as Timestamp;
              time = TimeOfDay.fromDateTime(timestamp.toDate()).format(context);
            }

            return _listTileItem(
              userData,
              lastMessage,
              time,
              context,
              otherUserId,
            );
          },
        );
      },
    );
  }

  ListTile _listTileItem(
    Map<String, dynamic> userData,
    String lastMessage,
    String time,
    BuildContext context,
    String otherUserId,
  ) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage:
            userData['profile_picture'].toString().isEmpty
                ? AssetImage('assets/defaultProfilePicture.png')
                : NetworkImage(userData['profile_picture']),
        radius: 25,
        backgroundColor: Colors.grey[800],
      ),
      title: Text(
        userData['username'],
        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
      ),
      subtitle: Text(
        lastMessage,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(color: Colors.white70),
      ),
      trailing: Text(time, style: TextStyle(color: Colors.grey, fontSize: 12)),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (_) => ChatPage(
                  receiverUserId: otherUserId,
                  receiverUserName: userData['username'],
                  receiverUserPicture: userData['profile_picture'],
                  receiverUserState: userData['conected'],
                ),
          ),
        );
      },
    );
  }

  Widget _noChatsAlert(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.chat, color: Colors.white, size: 60),
                  const SizedBox(height: 16),
                  Text(
                    translate(context, "noChatsYet"),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    translate(context, "messageWillAppear"),
                    style: TextStyle(color: Colors.white54, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
