// work_permit_letter.dart
class WorkPermitLetter {
  final int id;
  final String status;
  final DateTime startedAt;
  final DateTime endedAt;
  final String letterNumber;

  WorkPermitLetter({
    required this.id,
    required this.status,
    required this.startedAt,
    required this.endedAt,
    required this.letterNumber,
  });

  factory WorkPermitLetter.fromJson(Map<String, dynamic> json) {
    return WorkPermitLetter(
      id: json['id'],
      status: json['status'],
      startedAt: DateTime.parse(json['started_at']),
      endedAt: DateTime.parse(json['ended_at']),
      letterNumber: json['letter_number'] ?? '',
    );
  }
}

class WorkPermitResponse {
  final List<WorkPermitLetter> data;
  final int total;

  WorkPermitResponse({
    required this.data,
    required this.total,
  });

  factory WorkPermitResponse.fromJson(Map<String, dynamic> json) {
    final dataList = json['data']['data'] as List;
    return WorkPermitResponse(
      data: dataList.map((item) => WorkPermitLetter.fromJson(item)).toList(),
      total: json['data']['total'],
    );
  }
}