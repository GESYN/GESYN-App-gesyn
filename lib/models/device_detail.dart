class DeviceDetail {
  final String id;
  final String name;
  final String deviceId;
  final String apiToken;
  final String type;
  final String status;
  final String configStatus;
  final DateTime? lastSeen;
  final String? ipAddress;
  final String firmwareVersion;
  final String? description;
  final int? readingInterval;
  final String ownerId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DeviceOwner owner;
  final List<dynamic> logs;
  final List<DeviceReading> data;
  final DeviceCount count;

  DeviceDetail({
    required this.id,
    required this.name,
    required this.deviceId,
    required this.apiToken,
    required this.type,
    required this.status,
    required this.configStatus,
    this.lastSeen,
    this.ipAddress,
    required this.firmwareVersion,
    this.description,
    this.readingInterval,
    required this.ownerId,
    required this.createdAt,
    required this.updatedAt,
    required this.owner,
    required this.logs,
    required this.data,
    required this.count,
  });

  bool get isOnline => status == 'ONLINE';

  factory DeviceDetail.fromJson(Map<String, dynamic> json) {
    return DeviceDetail(
      id: json['id'],
      name: json['name'],
      deviceId: json['deviceId'],
      apiToken: json['apiToken'],
      type: json['type'],
      status: json['status'],
      configStatus: json['configStatus'],
      lastSeen: json['lastSeen'] != null
          ? DateTime.parse(json['lastSeen'])
          : null,
      ipAddress: json['ipAddress'],
      firmwareVersion: json['firmwareVersion'],
      description: json['description'],
      readingInterval: json['readingInterval'],
      ownerId: json['ownerId'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      owner: DeviceOwner.fromJson(json['owner']),
      logs: json['logs'] ?? [],
      data: (json['data'] as List)
          .map((d) => DeviceReading.fromJson(d))
          .toList(),
      count: DeviceCount.fromJson(json['_count']),
    );
  }
}

class DeviceOwner {
  final String id;
  final String email;
  final String username;

  DeviceOwner({required this.id, required this.email, required this.username});

  factory DeviceOwner.fromJson(Map<String, dynamic> json) {
    return DeviceOwner(
      id: json['id'],
      email: json['email'],
      username: json['username'],
    );
  }
}

class DeviceReading {
  final String id;
  final String deviceId;
  final double? batteryLevel;
  final bool? isCharging;
  final double? voltage;
  final double? current;
  final double? latitude;
  final double? longitude;
  final double? altitude;
  final double? gpsAccuracy;
  final double? lightIntensity;
  final double? uvIndex;
  final double? airTemperature;
  final double? airHumidity;
  final double? airPressure;
  final double? airQuality;
  final double? co2Level;
  final double? soilTemperature;
  final double? soilConductivity;
  final double? soilMoisture;
  final double? soilSalinity;
  final double? soilPh;
  final double? windSpeed;
  final double? windDirection;
  final double? windGust;
  final double? noiseLevel;
  final double? particulateMatter;
  final double? rainProbability;
  final double? rainAmount;
  final double? dewPoint;
  final DateTime timestamp;
  final String? dataQuality;

  DeviceReading({
    required this.id,
    required this.deviceId,
    this.batteryLevel,
    this.isCharging,
    this.voltage,
    this.current,
    this.latitude,
    this.longitude,
    this.altitude,
    this.gpsAccuracy,
    this.lightIntensity,
    this.uvIndex,
    this.airTemperature,
    this.airHumidity,
    this.airPressure,
    this.airQuality,
    this.co2Level,
    this.soilTemperature,
    this.soilConductivity,
    this.soilMoisture,
    this.soilSalinity,
    this.soilPh,
    this.windSpeed,
    this.windDirection,
    this.windGust,
    this.noiseLevel,
    this.particulateMatter,
    this.rainProbability,
    this.rainAmount,
    this.dewPoint,
    required this.timestamp,
    this.dataQuality,
  });

  factory DeviceReading.fromJson(Map<String, dynamic> json) {
    return DeviceReading(
      id: json['id'],
      deviceId: json['deviceId'],
      batteryLevel: json['batteryLevel']?.toDouble(),
      isCharging: json['isCharging'],
      voltage: json['voltage']?.toDouble(),
      current: json['current']?.toDouble(),
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      altitude: json['altitude']?.toDouble(),
      gpsAccuracy: json['gpsAccuracy']?.toDouble(),
      lightIntensity: json['lightIntensity']?.toDouble(),
      uvIndex: json['uvIndex']?.toDouble(),
      airTemperature: json['airTemperature']?.toDouble(),
      airHumidity: json['airHumidity']?.toDouble(),
      airPressure: json['airPressure']?.toDouble(),
      airQuality: json['airQuality']?.toDouble(),
      co2Level: json['co2Level']?.toDouble(),
      soilTemperature: json['soilTemperature']?.toDouble(),
      soilConductivity: json['soilConductivity']?.toDouble(),
      soilMoisture: json['soilMoisture']?.toDouble(),
      soilSalinity: json['soilSalinity']?.toDouble(),
      soilPh: json['soilPh']?.toDouble(),
      windSpeed: json['windSpeed']?.toDouble(),
      windDirection: json['windDirection']?.toDouble(),
      windGust: json['windGust']?.toDouble(),
      noiseLevel: json['noiseLevel']?.toDouble(),
      particulateMatter: json['particulateMatter']?.toDouble(),
      rainProbability: json['rainProbability']?.toDouble(),
      rainAmount: json['rainAmount']?.toDouble(),
      dewPoint: json['dewPoint']?.toDouble(),
      timestamp: DateTime.parse(json['timestamp']),
      dataQuality: json['dataQuality'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (batteryLevel != null) 'batteryLevel': batteryLevel,
      if (isCharging != null) 'isCharging': isCharging,
      if (voltage != null) 'voltage': voltage,
      if (current != null) 'current': current,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (altitude != null) 'altitude': altitude,
      if (gpsAccuracy != null) 'gpsAccuracy': gpsAccuracy,
      if (lightIntensity != null) 'lightIntensity': lightIntensity,
      if (uvIndex != null) 'uvIndex': uvIndex,
      if (airTemperature != null) 'airTemperature': airTemperature,
      if (airHumidity != null) 'airHumidity': airHumidity,
      if (airPressure != null) 'airPressure': airPressure,
      if (airQuality != null) 'airQuality': airQuality,
      if (co2Level != null) 'co2Level': co2Level,
      if (soilTemperature != null) 'soilTemperature': soilTemperature,
      if (soilConductivity != null) 'soilConductivity': soilConductivity,
      if (soilMoisture != null) 'soilMoisture': soilMoisture,
      if (soilSalinity != null) 'soilSalinity': soilSalinity,
      if (soilPh != null) 'soilPh': soilPh,
      if (windSpeed != null) 'windSpeed': windSpeed,
      if (windDirection != null) 'windDirection': windDirection,
      if (windGust != null) 'windGust': windGust,
      if (noiseLevel != null) 'noiseLevel': noiseLevel,
      if (particulateMatter != null) 'particulateMatter': particulateMatter,
      if (rainProbability != null) 'rainProbability': rainProbability,
      if (rainAmount != null) 'rainAmount': rainAmount,
      if (dewPoint != null) 'dewPoint': dewPoint,
      if (dataQuality != null) 'dataQuality': dataQuality,
    };
  }
}

class DeviceCount {
  final int logs;
  final int apiCalls;
  final int data;

  DeviceCount({required this.logs, required this.apiCalls, required this.data});

  factory DeviceCount.fromJson(Map<String, dynamic> json) {
    return DeviceCount(
      logs: json['logs'] ?? 0,
      apiCalls: json['apiCalls'] ?? 0,
      data: json['data'] ?? 0,
    );
  }
}
