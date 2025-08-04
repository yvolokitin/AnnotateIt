class Notification {
  final int? id;
  final String message;
  final String type; // 'info', 'warning', 'error', 'success'
  final String backgroundColor; // Color as hex string
  final String textColor; // Color as hex string
  final DateTime createdAt;
  final bool isRead;

  static final List<String> fields = [
    'id',
    'message',
    'type',
    'backgroundColor',
    'textColor',
    'createdAt',
    'isRead',
  ];

  const Notification({
    this.id,
    required this.message,
    required this.type,
    required this.backgroundColor,
    required this.textColor,
    required this.createdAt,
    this.isRead = false,
  });

  Notification copyWith({
    int? id,
    String? message,
    String? type,
    String? backgroundColor,
    String? textColor,
    DateTime? createdAt,
    bool? isRead,
  }) {
    return Notification(
      id: id ?? this.id,
      message: message ?? this.message,
      type: type ?? this.type,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      textColor: textColor ?? this.textColor,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'message': message,
        'type': type,
        'backgroundColor': backgroundColor,
        'textColor': textColor,
        'createdAt': createdAt.toIso8601String(),
        'isRead': isRead ? 1 : 0,
      };

  static Notification fromMap(Map<String, dynamic> map) => Notification(
        id: map['id'],
        message: map['message'],
        type: map['type'],
        backgroundColor: map['backgroundColor'],
        textColor: map['textColor'],
        createdAt: DateTime.parse(map['createdAt']),
        isRead: map['isRead'] == 1,
      );

  @override
  String toString() {
    return 'Notification(id: $id, message: $message, type: $type, createdAt: $createdAt, isRead: $isRead)';
  }
}