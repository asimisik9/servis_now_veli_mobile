import 'dart:convert';

String parseErrorMessage(
  dynamic raw, {
  required String fallbackMessage,
}) {
  final map = _toMap(raw);
  if (map.isEmpty) {
    return fallbackMessage;
  }

  final detail = map['detail'];
  if (detail is String && detail.trim().isNotEmpty) {
    return detail;
  }

  if (detail is List) {
    final messages = detail
        .map((item) {
          final itemMap = _toMap(item);
          if (itemMap.isEmpty) {
            return null;
          }
          final message = itemMap['msg'] ?? itemMap['message'];
          if (message is String && message.trim().isNotEmpty) {
            return message;
          }
          return null;
        })
        .whereType<String>()
        .toList();
    if (messages.isNotEmpty) {
      return messages.join(' | ');
    }
  }

  final message = map['message'];
  if (message is String && message.trim().isNotEmpty) {
    return message;
  }

  return fallbackMessage;
}

Map<String, dynamic> _toMap(dynamic data) {
  if (data is Map<String, dynamic>) {
    return data;
  }
  if (data is Map) {
    return Map<String, dynamic>.from(data);
  }
  if (data is String) {
    try {
      final decoded = jsonDecode(data);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      if (decoded is Map) {
        return Map<String, dynamic>.from(decoded);
      }
    } catch (_) {
      // ignored
    }
  }
  return <String, dynamic>{};
}
