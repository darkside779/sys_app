import 'ai_response_models.dart';

class AIMessage {
  final String id;
  final String content;
  final bool isUser;
  final DateTime timestamp;
  AIStructuredResponse? structuredData;

  AIMessage({
    required this.id,
    required this.content,
    required this.isUser,
    required this.timestamp,
    this.structuredData,
  });

  factory AIMessage.user(String content) {
    return AIMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: content,
      isUser: true,
      timestamp: DateTime.now(),
    );
  }

  factory AIMessage.assistant(String content, {AIStructuredResponse? structuredData}) {
    return AIMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: content,
      isUser: false,
      timestamp: DateTime.now(),
      structuredData: structuredData,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'isUser': isUser,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory AIMessage.fromJson(Map<String, dynamic> json) {
    return AIMessage(
      id: json['id'],
      content: json['content'],
      isUser: json['isUser'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}
