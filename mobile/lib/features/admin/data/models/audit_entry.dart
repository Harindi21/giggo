DateTime? _toDate(dynamic v) =>
    v == null ? null : DateTime.tryParse(v as String);

/// One admin audit-log entry (mirrors AuditLogResponse, P11.10).
class AuditEntry {
  final String id;
  final String? actorName;
  final String action;
  final String? targetType;
  final String? targetId;
  final String? detail;
  final DateTime? createdAt;

  const AuditEntry({
    required this.id,
    this.actorName,
    required this.action,
    this.targetType,
    this.targetId,
    this.detail,
    this.createdAt,
  });

  factory AuditEntry.fromJson(Map<String, dynamic> json) => AuditEntry(
    id: json['id'] as String,
    actorName: json['actorName'] as String?,
    action: json['action'] as String? ?? '',
    targetType: json['targetType'] as String?,
    targetId: json['targetId'] as String?,
    detail: json['detail'] as String?,
    createdAt: _toDate(json['createdAt']),
  );
}
