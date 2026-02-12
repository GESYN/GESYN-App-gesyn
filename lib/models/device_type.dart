class DeviceType {
  final String id;
  final String name;
  final String description;
  final List<String> supportedSensors;

  DeviceType({
    required this.id,
    required this.name,
    required this.description,
    required this.supportedSensors,
  });

  factory DeviceType.fromJson(Map<String, dynamic> json) {
    return DeviceType(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      supportedSensors:
          (json['supportedSensors'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'supportedSensors': supportedSensors,
    };
  }
}

// Tipos de dispositivos predefinidos
class DeviceTypes {
  static final gesynSolum = DeviceType(
    id: 'ESP32',
    name: 'GESYN Solum',
    description: 'Sensor de temperatura e umidade do solo',
    supportedSensors: ['temperature', 'humidity', 'soil_moisture', 'ph'],
  );

  static List<DeviceType> get all => [gesynSolum];

  static DeviceType? getById(String id) {
    try {
      return all.firstWhere((type) => type.id == id);
    } catch (e) {
      return null;
    }
  }
}
