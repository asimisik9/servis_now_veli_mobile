class NotificationModel {
  final String id;
  final String recipientId;
  final String title;
  final String message;
  final String notificationType;
  final String? studentId;
  final String status;
  final bool isRead;
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.recipientId,
    required this.title,
    required this.message,
    required this.notificationType,
    this.studentId,
    required this.status,
    required this.isRead,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as String,
      recipientId: json['recipient_id'] as String,
      title: json['title'] as String? ?? 'Servis Now',
      message: json['message'] as String,
      notificationType: json['notification_type'] as String? ?? 'genel',
      studentId: json['student_id'] as String?,
      status: json['status'] as String,
      isRead: json['is_read'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  NotificationModel copyWith({
    String? id,
    String? recipientId,
    String? title,
    String? message,
    String? notificationType,
    String? studentId,
    String? status,
    bool? isRead,
    DateTime? createdAt,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      recipientId: recipientId ?? this.recipientId,
      title: title ?? this.title,
      message: message ?? this.message,
      notificationType: notificationType ?? this.notificationType,
      studentId: studentId ?? this.studentId,
      status: status ?? this.status,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Bildirim türüne göre ikon
  String get icon {
    switch (notificationType) {
      case 'eve_varis_eta':
        return '🚌';
      case 'evden_alim_eta':
        return '🚌';
      case 'okula_varis':
        return '✅';
      case 'eve_birakildi':
        return '🏠';
      default:
        return '📢';
    }
  }

  /// Bildirim zamanını okunabilir formata çevir
  String get timeAgo {
    final now = DateTime.now();
    final diff = now.difference(createdAt);

    if (diff.inMinutes < 1) return 'Az önce';
    if (diff.inMinutes < 60) return '${diff.inMinutes} dk önce';
    if (diff.inHours < 24) return '${diff.inHours} saat önce';
    if (diff.inDays < 7) return '${diff.inDays} gün önce';
    return '${createdAt.day}.${createdAt.month}.${createdAt.year}';
  }
}
