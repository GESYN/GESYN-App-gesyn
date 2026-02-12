import 'package:flutter/material.dart';

/// Enum para definir o tamanho do componente de sensor
enum SensorCardSize { normal, mini }

/// Classe base para configuração de sensores
class SensorConfig {
  final String label;
  final IconData icon;
  final Color color;
  final String unit;
  final double? min;
  final double? max;

  const SensorConfig({
    required this.label,
    required this.icon,
    required this.color,
    required this.unit,
    this.min,
    this.max,
  });
}

/// Mapa de configurações para cada tipo de sensor
class SensorConfigurations {
  static const Map<String, SensorConfig> configs = {
    // Bateria e Energia
    'batteryLevel': SensorConfig(
      label: 'Bateria',
      icon: Icons.battery_charging_full,
      color: Colors.green,
      unit: '%',
      min: 0,
      max: 100,
    ),
    'voltage': SensorConfig(
      label: 'Voltagem',
      icon: Icons.bolt,
      color: Colors.amber,
      unit: 'V',
    ),
    'current': SensorConfig(
      label: 'Corrente',
      icon: Icons.electrical_services,
      color: Colors.orange,
      unit: 'mA',
    ),

    // Solo
    'soilTemperature': SensorConfig(
      label: 'Temp. Solo',
      icon: Icons.thermostat,
      color: Colors.brown,
      unit: '°C',
    ),
    'soilConductivity': SensorConfig(
      label: 'Condutividade',
      icon: Icons.waves,
      color: Colors.teal,
      unit: 'µS/cm',
    ),
    'soilMoisture': SensorConfig(
      label: 'Umidade Solo',
      icon: Icons.water_drop,
      color: Colors.blue,
      unit: '%',
      min: 0,
      max: 100,
    ),
    'soilSalinity': SensorConfig(
      label: 'Salinidade',
      icon: Icons.grain,
      color: Colors.cyan,
      unit: 'ppm',
    ),
    'soilPh': SensorConfig(
      label: 'pH Solo',
      icon: Icons.science,
      color: Colors.purple,
      unit: 'pH',
      min: 0,
      max: 14,
    ),

    // Luz e UV
    'lightIntensity': SensorConfig(
      label: 'Intensidade Luz',
      icon: Icons.wb_sunny,
      color: Colors.yellow,
      unit: 'lux',
    ),
    'uvIndex': SensorConfig(
      label: 'Índice UV',
      icon: Icons.wb_sunny_outlined,
      color: Colors.deepOrange,
      unit: '',
      min: 0,
      max: 11,
    ),

    // Ar
    'airTemperature': SensorConfig(
      label: 'Temp. Ar',
      icon: Icons.thermostat_outlined,
      color: Colors.red,
      unit: '°C',
    ),
    'airHumidity': SensorConfig(
      label: 'Umidade Ar',
      icon: Icons.water_drop_outlined,
      color: Colors.lightBlue,
      unit: '%',
      min: 0,
      max: 100,
    ),
    'airPressure': SensorConfig(
      label: 'Pressão',
      icon: Icons.compress,
      color: Colors.indigo,
      unit: 'hPa',
    ),
    'airQuality': SensorConfig(
      label: 'Qualidade Ar',
      icon: Icons.air,
      color: Colors.lightGreen,
      unit: 'AQI',
    ),
    'co2Level': SensorConfig(
      label: 'CO₂',
      icon: Icons.cloud,
      color: Colors.grey,
      unit: 'ppm',
    ),
    'dewPoint': SensorConfig(
      label: 'Ponto Orvalho',
      icon: Icons.opacity,
      color: Colors.blueGrey,
      unit: '°C',
    ),

    // Vento
    'windSpeed': SensorConfig(
      label: 'Veloc. Vento',
      icon: Icons.air,
      color: Colors.cyan,
      unit: 'm/s',
    ),
    'windDirection': SensorConfig(
      label: 'Dir. Vento',
      icon: Icons.navigation,
      color: Colors.blue,
      unit: '°',
      min: 0,
      max: 360,
    ),
    'windGust': SensorConfig(
      label: 'Rajada',
      icon: Icons.storm,
      color: Colors.deepPurple,
      unit: 'm/s',
    ),

    // Ruído e Partículas
    'noiseLevel': SensorConfig(
      label: 'Ruído',
      icon: Icons.volume_up,
      color: Colors.pink,
      unit: 'dB',
    ),
    'particulateMatter': SensorConfig(
      label: 'Material Part.',
      icon: Icons.blur_on,
      color: Colors.brown,
      unit: 'µg/m³',
    ),

    // Chuva
    'rainProbability': SensorConfig(
      label: 'Prob. Chuva',
      icon: Icons.water,
      color: Colors.blue,
      unit: '%',
      min: 0,
      max: 100,
    ),
    'rainAmount': SensorConfig(
      label: 'Quantidade Chuva',
      icon: Icons.water_damage,
      color: Colors.blueAccent,
      unit: 'mm',
    ),

    // GPS
    'altitude': SensorConfig(
      label: 'Altitude',
      icon: Icons.terrain,
      color: Colors.green,
      unit: 'm',
    ),
    'gpsAccuracy': SensorConfig(
      label: 'Precisão GPS',
      icon: Icons.gps_fixed,
      color: Colors.teal,
      unit: 'm',
    ),
  };

  static SensorConfig? getConfig(String key) => configs[key];
}

/// Função helper para obter cor baseada no valor
Color getColorForValue(double value, SensorConfig config) {
  if (config.min == null || config.max == null) return config.color;

  final percentage = ((value - config.min!) / (config.max! - config.min!))
      .clamp(0.0, 1.0);

  if (percentage < 0.3) return Colors.red;
  if (percentage < 0.7) return Colors.orange;
  return Colors.green;
}
