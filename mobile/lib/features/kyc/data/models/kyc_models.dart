/// A provider's KYC submission (P2). Mirrors the backend KycSubmissionResponse.
class KycSubmission {
  final String id;
  final String fullName;
  final String documentType; // NIC | PASSPORT | DRIVING_LICENSE
  final String documentNumber;
  final String? documentImageUrl;
  final String status; // PENDING | APPROVED | REJECTED
  final String? reviewNote;
  final DateTime? submittedAt;
  final DateTime? reviewedAt;

  const KycSubmission({
    required this.id,
    required this.fullName,
    required this.documentType,
    required this.documentNumber,
    this.documentImageUrl,
    required this.status,
    this.reviewNote,
    this.submittedAt,
    this.reviewedAt,
  });

  bool get isApproved => status == 'APPROVED';
  bool get isPending => status == 'PENDING';
  bool get isRejected => status == 'REJECTED';

  factory KycSubmission.fromJson(Map<String, dynamic> json) => KycSubmission(
    id: json['id'] as String,
    fullName: json['fullName'] as String,
    documentType: json['documentType'] as String,
    documentNumber: json['documentNumber'] as String,
    documentImageUrl: json['documentImageUrl'] as String?,
    status: json['status'] as String,
    reviewNote: json['reviewNote'] as String?,
    submittedAt: json['submittedAt'] != null
        ? DateTime.tryParse(json['submittedAt'] as String)
        : null,
    reviewedAt: json['reviewedAt'] != null
        ? DateTime.tryParse(json['reviewedAt'] as String)
        : null,
  );
}
