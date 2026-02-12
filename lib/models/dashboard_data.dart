class DashboardData {
  final DashboardSummary summary;
  final List<DeviceDashboard> devices;
  final GlobalAverages? globalAverages;

  DashboardData({
    required this.summary,
    required this.devices,
    this.globalAverages,
  });

  factory DashboardData.fromJson(Map<String, dynamic> json) {
    return DashboardData(
      summary: DashboardSummary.fromJson(json['summary']),
      devices: (json['devices'] as List)
          .map((d) => DeviceDashboard.fromJson(d))
          .toList(),
      globalAverages: json['globalAverages'] != null
          ? GlobalAverages.fromJson(json['globalAverages'])
          : null,
    );
  }
}

class DashboardSummary {
  final int totalDevices;
  final int onlineDevices;
  final int offlineDevices;
  final int totalReadings;
  final int recentReadings;
  final int periodHours;
  final DateTime lastUpdate;
  final Map<String, dynamic> filters;

  DashboardSummary({
    required this.totalDevices,
    required this.onlineDevices,
    required this.offlineDevices,
    required this.totalReadings,
    required this.recentReadings,
    required this.periodHours,
    required this.lastUpdate,
    required this.filters,
  });

  factory DashboardSummary.fromJson(Map<String, dynamic> json) {
    return DashboardSummary(
      totalDevices: json['totalDevices'] ?? 0,
      onlineDevices: json['onlineDevices'] ?? 0,
      offlineDevices: json['offlineDevices'] ?? 0,
      totalReadings: json['totalReadings'] ?? 0,
      recentReadings: json['recentReadings'] ?? 0,
      periodHours: json['periodHours'] ?? 24,
      lastUpdate: DateTime.parse(json['lastUpdate']),
      filters: json['filters'] ?? {},
    );
  }
}

class DeviceDashboard {
  final String id;
  final String name;
  final String deviceId;
  final String type;
  final String status;
  final String configStatus;
  final String? description;
  final String firmwareVersion;
  final String? ipAddress;
  final DateTime? lastSeen;
  final DateTime createdAt;
  final int totalReadings;
  final int totalLogs;
  final int recentReadingsCount;
  final SensorReading? latestReading;
  final AverageReadings? averageReadings;

  DeviceDashboard({
    required this.id,
    required this.name,
    required this.deviceId,
    required this.type,
    required this.status,
    required this.configStatus,
    this.description,
    required this.firmwareVersion,
    this.ipAddress,
    this.lastSeen,
    required this.createdAt,
    required this.totalReadings,
    required this.totalLogs,
    required this.recentReadingsCount,
    this.latestReading,
    this.averageReadings,
  });

  bool get isOnline => status == 'ONLINE';

  factory DeviceDashboard.fromJson(Map<String, dynamic> json) {
    return DeviceDashboard(
      id: json['id'],
      name: json['name'],
      deviceId: json['deviceId'],
      type: json['type'],
      status: json['status'],
      configStatus: json['configStatus'],
      description: json['description'],
      firmwareVersion: json['firmwareVersion'],
      ipAddress: json['ipAddress'],
      lastSeen: json['lastSeen'] != null
          ? DateTime.parse(json['lastSeen'])
          : null,
      createdAt: DateTime.parse(json['createdAt']),
      totalReadings: json['totalReadings'] ?? 0,
      totalLogs: json['totalLogs'] ?? 0,
      recentReadingsCount: json['recentReadingsCount'] ?? 0,
      latestReading: json['latestReading'] != null
          ? SensorReading.fromJson(json['latestReading'])
          : null,
      averageReadings: json['averageReadings'] != null
          ? AverageReadings.fromJson(json['averageReadings'])
          : null,
    );
  }
}

class SensorReading {
  final double? batteryLevel;
  final bool? isCharging;
  final double? voltage;
  final double? current;
  final double? latitude;
  final double? longitude;
  final double? altitude;
  final double? gpsAccuracy;
  final double? soilTemperature;
  final double? soilConductivity;
  final double? soilMoisture;
  final double? soilSalinity;
  final double? soilPh;
  final double? lightIntensity;
  final double? uvIndex;
  final double? airTemperature;
  final double? airHumidity;
  final double? airPressure;
  final double? airQuality;
  final double? co2Level;
  final double? windSpeed;
  final double? windDirection;
  final double? windGust;
  final double? noiseLevel;
  final double? particulateMatter;
  final double? rainProbability;
  final double? rainAmount;
  final double? dewPoint;
  final String? dataQuality;
  final DateTime? timestamp;

  SensorReading({
    this.batteryLevel,
    this.isCharging,
    this.voltage,
    this.current,
    this.latitude,
    this.longitude,
    this.altitude,
    this.gpsAccuracy,
    this.soilTemperature,
    this.soilConductivity,
    this.soilMoisture,
    this.soilSalinity,
    this.soilPh,
    this.lightIntensity,
    this.uvIndex,
    this.airTemperature,
    this.airHumidity,
    this.airPressure,
    this.airQuality,
    this.co2Level,
    this.windSpeed,
    this.windDirection,
    this.windGust,
    this.noiseLevel,
    this.particulateMatter,
    this.rainProbability,
    this.rainAmount,
    this.dewPoint,
    this.dataQuality,
    this.timestamp,
  });

  factory SensorReading.fromJson(Map<String, dynamic> json) {
    return SensorReading(
      batteryLevel: json['batteryLevel']?.toDouble(),
      isCharging: json['isCharging'],
      voltage: json['voltage']?.toDouble(),
      current: json['current']?.toDouble(),
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      altitude: json['altitude']?.toDouble(),
      gpsAccuracy: json['gpsAccuracy']?.toDouble(),
      soilTemperature: json['soilTemperature']?.toDouble(),
      soilConductivity: json['soilConductivity']?.toDouble(),
      soilMoisture: json['soilMoisture']?.toDouble(),
      soilSalinity: json['soilSalinity']?.toDouble(),
      soilPh: json['soilPh']?.toDouble(),
      lightIntensity: json['lightIntensity']?.toDouble(),
      uvIndex: json['uvIndex']?.toDouble(),
      airTemperature: json['airTemperature']?.toDouble(),
      airHumidity: json['airHumidity']?.toDouble(),
      airPressure: json['airPressure']?.toDouble(),
      airQuality: json['airQuality']?.toDouble(),
      co2Level: json['co2Level']?.toDouble(),
      windSpeed: json['windSpeed']?.toDouble(),
      windDirection: json['windDirection']?.toDouble(),
      windGust: json['windGust']?.toDouble(),
      noiseLevel: json['noiseLevel']?.toDouble(),
      particulateMatter: json['particulateMatter']?.toDouble(),
      rainProbability: json['rainProbability']?.toDouble(),
      rainAmount: json['rainAmount']?.toDouble(),
      dewPoint: json['dewPoint']?.toDouble(),
      dataQuality: json['dataQuality'],
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'])
          : null,
    );
  }

  // Método para converter para Map (útil para exibir dinamicamente)
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
      if (soilTemperature != null) 'soilTemperature': soilTemperature,
      if (soilConductivity != null) 'soilConductivity': soilConductivity,
      if (soilMoisture != null) 'soilMoisture': soilMoisture,
      if (soilSalinity != null) 'soilSalinity': soilSalinity,
      if (soilPh != null) 'soilPh': soilPh,
      if (lightIntensity != null) 'lightIntensity': lightIntensity,
      if (uvIndex != null) 'uvIndex': uvIndex,
      if (airTemperature != null) 'airTemperature': airTemperature,
      if (airHumidity != null) 'airHumidity': airHumidity,
      if (airPressure != null) 'airPressure': airPressure,
      if (airQuality != null) 'airQuality': airQuality,
      if (co2Level != null) 'co2Level': co2Level,
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

class AverageReadings {
  final double? airTemperature;
  final double? airHumidity;
  final double? soilMoisture;
  final double? soilTemperature;
  final double? batteryLevel;
  final double? co2Level;
  final double? windSpeed;
  final double? airPressure;

  AverageReadings({
    this.airTemperature,
    this.airHumidity,
    this.soilMoisture,
    this.soilTemperature,
    this.batteryLevel,
    this.co2Level,
    this.windSpeed,
    this.airPressure,
  });

  factory AverageReadings.fromJson(Map<String, dynamic> json) {
    return AverageReadings(
      airTemperature: json['airTemperature']?.toDouble(),
      airHumidity: json['airHumidity']?.toDouble(),
      soilMoisture: json['soilMoisture']?.toDouble(),
      soilTemperature: json['soilTemperature']?.toDouble(),
      batteryLevel: json['batteryLevel']?.toDouble(),
      co2Level: json['co2Level']?.toDouble(),
      windSpeed: json['windSpeed']?.toDouble(),
      airPressure: json['airPressure']?.toDouble(),
    );
  }
}

class GlobalAverages {
  final double? airTemperature;
  final double? airHumidity;
  final double? soilMoisture;
  final double? soilTemperature;
  final double? batteryLevel;
  final double? co2Level;
  final double? windSpeed;
  final double? airPressure;

  GlobalAverages({
    this.airTemperature,
    this.airHumidity,
    this.soilMoisture,
    this.soilTemperature,
    this.batteryLevel,
    this.co2Level,
    this.windSpeed,
    this.airPressure,
  });

  factory GlobalAverages.fromJson(Map<String, dynamic> json) {
    return GlobalAverages(
      airTemperature: json['airTemperature']?.toDouble(),
      airHumidity: json['airHumidity']?.toDouble(),
      soilMoisture: json['soilMoisture']?.toDouble(),
      soilTemperature: json['soilTemperature']?.toDouble(),
      batteryLevel: json['batteryLevel']?.toDouble(),
      co2Level: json['co2Level']?.toDouble(),
      windSpeed: json['windSpeed']?.toDouble(),
      airPressure: json['airPressure']?.toDouble(),
    );
  }
}
