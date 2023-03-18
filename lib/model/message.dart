import 'package:chat_app/utils/utils.dart';

class MessageField {
  static const String date = 'date';
}

class TypeMessage {
  static const text = 0;
  static const image = 1;
}

class Message {
  String id;
  final String idFrom;
  final String idTo;
  final String text;
  final DateTime date;
  final String readTime;
  final bool read;
  final int type;

  Message({
    this.id = '',
    required this.idFrom,
    required this.idTo,
    required this.text,
    required this.date,
    required this.readTime,
    required this.read,
    required this.type,
  });

  static Message fromJson(Map<String, dynamic> json) => Message(
      id: json['id'],
      idFrom: json['idFrom'],
      idTo: json['idTo'],
      text: json['text'],
      date: Utils.toDateTime(json['date'])!,
      readTime: json['readTime'],
      read: json['read'],
      type: json['type']);

  Map<String, dynamic> toJson() => {
        'id': id,
        'idFrom': idFrom,
        'idTo': idTo,
        'text': text,
        'date': Utils.fromDateTimeToJson(date),
        'readTime': readTime,
        'read': read,
        'type': type,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Message && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
