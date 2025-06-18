import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:teachme/models/message_model.dart';
import 'package:teachme/utils/config.dart';

class ChatService extends ChangeNotifier {
  // Instancias
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;

  // Método para enviar el mensaje
  Future<void> sendMessage(String receiverId, String message) async {
    print('ENVIANDO MENSAJE');
    // get currentUser and receiver and time of the message
    final String currentUserId = currentUser.id;
    final String currentUserName = currentUser.username;
    final Timestamp timestamp = Timestamp.now();

    print(currentUserId);

    print(receiverId);

    // Create new Message
    Message newMessage = Message(
      senderId: currentUserId,
      senderUsername: currentUserName,
      receiverId: receiverId,
      message: message,
      timestamp: timestamp,
    );

    // Create a chat room id from the id's
    List<String> ids = [currentUserId, receiverId];
    ids.sort(); // Ordenar las ids para asegurarse que la id siempre sera igual para ambar personas
    String chatRoomId = ids.join('_');

    // Referencia al chat room
    final chatRoomRef = _firebaseFirestore
        .collection('chat_rooms')
        .doc(chatRoomId);

    // Verifica si existe el chat room; si no, lo crea
    await chatRoomRef.set({
      'participants': ids,
      'last_updated':
          timestamp, // puedes usar esto para ordenar chats por actividad reciente
    }, SetOptions(merge: true)); // merge evita sobrescribir si ya existe

    // Agrega el mensaje a la subcolección
    await chatRoomRef.collection('messages').add(newMessage.toMap());
  }

  // Get messages from room
  Stream<QuerySnapshot> getMessages(String userId, String otherUserId) {
    // Get the chat room id from the id's
    List<String> ids = [userId, otherUserId];
    ids.sort(); // Ordenar las ids para asegurarse que la id siempre sera igual para ambar personas
    String chatRoomId = ids.join('_');

    return _firebaseFirestore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots();
  }

  Future<void> createEmptyChatRoom(String otherUserId) async {
    final String currentUserId = currentUser.id;
    final Timestamp timestamp = Timestamp.now();

    // Crear chatRoomId único y consistente
    List<String> ids = [currentUserId, otherUserId];
    ids.sort();
    String chatRoomId = ids.join('_');

    final chatRoomRef = _firebaseFirestore
        .collection('chat_rooms')
        .doc(chatRoomId);

    // Crear o actualizar chat_room sin mensajes
    await chatRoomRef.set({
      'participants': ids,
      'created_at': timestamp,
      'last_updated': timestamp,
    }, SetOptions(merge: true));
  }
}
