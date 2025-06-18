import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:teachme/service/chat_service.dart';
import 'package:teachme/utils/config.dart';
import 'package:teachme/utils/translate.dart';

class ChatPage extends StatefulWidget {
  final String receiverUserId;
  final String receiverUserName;
  final String receiverUserPicture;
  final String receiverUserState;
  const ChatPage({
    super.key,
    required this.receiverUserId,
    required this.receiverUserName,
    required this.receiverUserPicture,
    required this.receiverUserState,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ChatService _chatService = ChatService();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void sendMessage() async {
    if (_messageController.text.isNotEmpty) {
      await _chatService.sendMessage(
        widget.receiverUserId,
        _messageController.text.trim(),
      );
      // Limpiamos el campo de texto tras enviarlo
      _messageController.clear();
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            _circleAvatar(),
            SizedBox(width: 13),
            Expanded(
              child: Text(
                widget.receiverUserName,
                style: TextStyle(fontSize: 22),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        titleSpacing: 0,
      ),

      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Expanded(child: _buildMessageList()),
            _buildMessageInput(),
          ],
        ),
      ),
    );
  }

  // Build message list
  Widget _buildMessageList() {
    return StreamBuilder(
      stream: _chatService.getMessages(widget.receiverUserId, currentUser.id),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('Error ${snapshot.error}');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Text('Loading...');
        }

        List<DocumentSnapshot> docs = snapshot.data!.docs;
        List<Widget> messageWidgets = [];

        String? lastDateLabel;

        for (var doc in docs) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          DateTime timestamp = (data['timestamp'] as Timestamp).toDate();

          String dateLabel = _getDateLabel(timestamp);

          // Si la fecha cambia, agregamos un encabezado
          if (lastDateLabel != dateLabel) {
            messageWidgets.add(
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: Center(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      dateLabel,
                      style: TextStyle(color: Colors.black, fontSize: 14),
                    ),
                  ),
                ),
              ),
            );
            lastDateLabel = dateLabel;
          }

          messageWidgets.add(_buildMessageItem(doc));
        }

        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollToBottom();
        });

        return ListView(
          controller: _scrollController,
          padding: EdgeInsets.only(bottom: 10, top: 10),
          children: messageWidgets,
        );
      },
    );
  }

  Widget _buildMessageItem(DocumentSnapshot document) {
    Map<String, dynamic> data = document.data() as Map<String, dynamic>;
    bool isMe = data['senderId'] == currentUser.id;
    DateTime time = (data['timestamp'] as Timestamp).toDate().toLocal();
    String formattedTime =
        "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
        padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: isMe ? Color.fromARGB(255, 35, 91, 180) : Colors.grey[900],
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(18),
            topRight: Radius.circular(18),
            bottomLeft: Radius.circular(isMe ? 18 : 0),
            bottomRight: Radius.circular(isMe ? 0 : 18),
          ),
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 48.0, bottom: 14.0),
              child: Text(
                data['message'] ?? '',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Text(
                formattedTime,
                style: TextStyle(fontSize: 11, color: Colors.white70),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getDateLabel(DateTime date) {
    DateTime now = DateTime.now();
    DateTime today = DateTime(now.year, now.month, now.day);
    DateTime yesterday = today.subtract(Duration(days: 1));
    DateTime messageDate = DateTime(date.year, date.month, date.day);

    if (messageDate == today) return 'Hoy';
    if (messageDate == yesterday) return 'Ayer';

    return _formatFullDate(messageDate);
  }

  String _formatFullDate(DateTime date) {
    // Ej: sábado, 8 junio
    final months = [
      "Enero",
      "Febrero",
      "Marzo",
      "Abril",
      "Mayo",
      "Junio",
      "Julio",
      "Agosto",
      "Septiembre",
      "Octubre",
      "Noviembre",
      "Diciembre",
    ];
    final weekdays = [
      "Lunes",
      "Martes",
      "Miércoles",
      "Jueves",
      "Viernes",
      "Sábado",
      "Domingo",
    ];
    return "${weekdays[date.weekday - 1]}, ${date.day} ${months[date.month - 1]}";
  }

  // Build message input
  Widget _buildMessageInput() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(25.0),
              ),
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: TextField(
                controller: _messageController,
                decoration: InputDecoration(
                  hintText: translate(context, "message"),
                  border: InputBorder.none,
                ),
                minLines: 1,
                maxLines: 10,
              ),
            ),
          ),

          SizedBox(width: 8),

          // Botón de enviar mensaje
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Color.fromARGB(255, 35, 91, 180),
            ),
            child: IconButton(
              icon: Icon(Icons.send, color: Colors.white),
              onPressed: sendMessage,
            ),
          ),
        ],
      ),
    );
  }

  // Avatar for the AppBar
  Stack _circleAvatar() {
    return Stack(
      children: [
        CircleAvatar(
          backgroundImage:
              widget.receiverUserPicture.isEmpty
                  ? AssetImage('assets/defaultProfilePicture.png')
                  : NetworkImage(widget.receiverUserPicture),

          backgroundColor: Colors.grey[800],
        ),
        Positioned(
          bottom: 2,
          right: 0,
          child: Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color:
                  widget.receiverUserState == 'yes'
                      ? Colors.green
                      : Colors.grey,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.black, width: 1),
            ),
          ),
        ),
      ],
    );
  }
}
