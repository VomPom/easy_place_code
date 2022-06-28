const String tableQrCode = 'qr_code';

class QRcodeFields {
  static final List<String> values = [
    /// Add all fields
    id, qrCodeResult, description, time
  ];

  static const String id = '_id';
  static const String qrCodeResult = 'qrCodeResult';
  static const String description = 'description';
  static const String time = 'time';
}

class QRCode {
  final int? id;
  final String qrCodeResult;
  final String description;
  final DateTime createdTime;

  const QRCode({
    this.id,
    required this.qrCodeResult,
    required this.description,
    required this.createdTime,
  });

  QRCode copy({
    int? id,
    String? qrCodeResult,
    String? description,
    DateTime? createdTime,
  }) =>
      QRCode(
        id: id ?? this.id,
        qrCodeResult: qrCodeResult ?? this.qrCodeResult,
        description: description ?? this.description,
        createdTime: createdTime ?? this.createdTime,
      );

  static QRCode fromJson(Map<String, Object?> json) => QRCode(
        id: json[QRcodeFields.id] as int?,
        qrCodeResult: json[QRcodeFields.qrCodeResult] as String,
        description: json[QRcodeFields.description] as String,
        createdTime: DateTime.parse(json[QRcodeFields.time] as String),
      );

  Map<String, Object?> toJson() => {
        QRcodeFields.id: id,
        QRcodeFields.qrCodeResult: qrCodeResult,
        QRcodeFields.description: description,
        QRcodeFields.time: createdTime.toIso8601String(),
      };
}
