
class NotificationFactory {
  static Map<String, dynamic> create({
    required String userId,
    required String senderId,
    required int fileId,
    required String data,
    required String type,
  }) {
    return {
      'user_id': userId,
      'sender_id': senderId,
      'file_id': fileId,
      'data': data,
      'type': type,
      'read': false,
      'timestamp': DateTime.now().toIso8601String(),
    };
  }
}
