import 'package:equatable/equatable.dart';

class RideMessageModel extends Equatable {
  const RideMessageModel({
    required this.id,
    required this.rideId,
    required this.senderId,
    required this.body,
    this.senderName,
    this.templateKey,
    this.isMine = false,
    this.readAt,
    this.createdAt,
  });

  final int id;
  final int rideId;
  final int senderId;
  final String body;
  final String? senderName;
  final String? templateKey;
  final bool isMine;
  final DateTime? readAt;
  final DateTime? createdAt;

  factory RideMessageModel.fromJson(Map<String, dynamic> json) {
    return RideMessageModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      rideId: (json['ride_id'] as num?)?.toInt() ?? 0,
      senderId: (json['sender_id'] as num?)?.toInt() ?? 0,
      body: (json['body'] ?? '').toString(),
      senderName: json['sender_name']?.toString(),
      templateKey: json['template_key']?.toString(),
      isMine: json['is_mine'] == true,
      readAt: json['read_at'] != null
          ? DateTime.tryParse(json['read_at'].toString())
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
    );
  }

  @override
  List<Object?> get props => [id, rideId, senderId, body, isMine];
}

class RideMessageTemplate extends Equatable {
  const RideMessageTemplate({required this.key, required this.body});

  final String key;
  final String body;

  factory RideMessageTemplate.fromJson(Map<String, dynamic> json) {
    return RideMessageTemplate(
      key: (json['key'] ?? '').toString(),
      body: (json['body'] ?? '').toString(),
    );
  }

  @override
  List<Object?> get props => [key, body];
}

class MaskedCallSession extends Equatable {
  const MaskedCallSession({
    required this.sessionRef,
    required this.displayLabel,
    required this.provider,
    required this.instructions,
    this.dialNumber,
    this.expiresAt,
  });

  final String sessionRef;
  final String? dialNumber;
  final String displayLabel;
  final String provider;
  final String instructions;
  final DateTime? expiresAt;

  factory MaskedCallSession.fromJson(Map<String, dynamic> json) {
    return MaskedCallSession(
      sessionRef: (json['session_ref'] ?? '').toString(),
      dialNumber: json['dial_number']?.toString(),
      displayLabel: (json['display_label'] ?? 'Private number').toString(),
      provider: (json['provider'] ?? 'stub').toString(),
      instructions: (json['instructions'] ?? '').toString(),
      expiresAt: json['expires_at'] != null
          ? DateTime.tryParse(json['expires_at'].toString())
          : null,
    );
  }

  @override
  List<Object?> get props => [sessionRef, dialNumber, provider];
}
