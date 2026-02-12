class Device {
  final String id;
  final String name;
  final String deviceId;
  final String apiToken;
  final String type;
  final String status; // ONLINE, OFFLINE
  final String configStatus; // ACTIVE, INACTIVE
  final String? description;
  final String firmwareVersion;
  final String ownerId;
  final DateTime? lastSeen;
  final String? ipAddress;
  final int? readingInterval;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic>? owner;
  final int? logsCount;

  Device({
    required this.id,
    required this.name,
    required this.deviceId,
    required this.apiToken,
    required this.type,
    required this.status,
    required this.configStatus,
    this.description,
    required this.firmwareVersion,
    required this.ownerId,
    this.lastSeen,
    this.ipAddress,
    this.readingInterval,
    required this.createdAt,
    required this.updatedAt,
    this.owner,
    this.logsCount,
  });

  factory Device.fromJson(Map<String, dynamic> json) {
    return Device(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      deviceId: json['deviceId'] ?? '',
      apiToken: json['apiToken'] ?? '',
      type: json['type'] ?? '',
      status: json['status'] ?? 'OFFLINE',
      configStatus: json['configStatus'] ?? 'INACTIVE',
      description: json['description'],
      firmwareVersion: json['firmwareVersion'] ?? '1.0.0',
      ownerId: json['ownerId'] ?? '',
      lastSeen: json['lastSeen'] != null
          ? DateTime.parse(json['lastSeen'])
          : null,
      ipAddress: json['ipAddress'],
      readingInterval: json['readingInterval'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      owner: json['owner'],
      logsCount: json['_count']?['logs'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'deviceId': deviceId,
      'apiToken': apiToken,
      'type': type,
      'status': status,
      'configStatus': configStatus,
      'description': description,
      'firmwareVersion': firmwareVersion,
      'ownerId': ownerId,
      'lastSeen': lastSeen?.toIso8601String(),
      'ipAddress': ipAddress,
      'readingInterval': readingInterval,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'owner': owner,
    };
  }

  Device copyWith({
    String? id,
    String? name,
    String? deviceId,
    String? apiToken,
    String? type,
    String? status,
    String? configStatus,
    String? description,
    String? firmwareVersion,
    String? ownerId,
    DateTime? lastSeen,
    String? ipAddress,
    int? readingInterval,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? owner,
    int? logsCount,
  }) {
    return Device(
      id: id ?? this.id,
      name: name ?? this.name,
      deviceId: deviceId ?? this.deviceId,
      apiToken: apiToken ?? this.apiToken,
      type: type ?? this.type,
      status: status ?? this.status,
      configStatus: configStatus ?? this.configStatus,
      description: description ?? this.description,
      firmwareVersion: firmwareVersion ?? this.firmwareVersion,
      ownerId: ownerId ?? this.ownerId,
      lastSeen: lastSeen ?? this.lastSeen,
      ipAddress: ipAddress ?? this.ipAddress,
      readingInterval: readingInterval ?? this.readingInterval,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      owner: owner ?? this.owner,
      logsCount: logsCount ?? this.logsCount,
    );
  }

  bool get isOnline => status == 'ONLINE';
  bool get isActive => configStatus == 'ACTIVE';
}
