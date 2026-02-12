import 'package:flutter/material.dart';
import '../../models/dashboard_data.dart';
import 'sensor_card.dart';
import 'battery_card.dart';
import 'gps_card.dart';
import 'sensor_config.dart';

class SensorGrid extends StatelessWidget {
  final SensorReading? reading;
  final SensorCardSize size;

  const SensorGrid({
    super.key,
    required this.reading,
    this.size = SensorCardSize.normal,
  });

  @override
  Widget build(BuildContext context) {
    if (reading == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.sensors_off, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              'Sem dados de sensores',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    final sensors = _buildSensorWidgets();

    if (size == SensorCardSize.mini) {
      return ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: sensors.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) => sensors[index],
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        // Calcula colunas baseado na largura disponível
        final width = constraints.maxWidth;
        int crossAxisCount = 2;
        if (width < 600) {
          crossAxisCount = 2; // Mobile
        } else if (width < 900) {
          crossAxisCount = 3; // Tablet
        } else {
          crossAxisCount = 4; // Desktop
        }

        return GridView.count(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.1,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: sensors,
        );
      },
    );
  }

  List<Widget> _buildSensorWidgets() {
    final widgets = <Widget>[];
    final data = reading!.toMap();

    // Bateria (componente especial)
    if (reading!.batteryLevel != null || reading!.isCharging == true) {
      widgets.add(
        BatteryCard(
          batteryLevel: reading!.batteryLevel,
          isCharging: reading!.isCharging,
          size: size,
        ),
      );
    }

    // GPS (componente especial)
    if (reading!.latitude != null && reading!.longitude != null) {
      widgets.add(
        GPSCard(
          latitude: reading!.latitude,
          longitude: reading!.longitude,
          altitude: reading!.altitude,
          accuracy: reading!.gpsAccuracy,
          size: size,
        ),
      );
    }

    // Sensores genéricos (automaticamente com base na configuração)
    data.forEach((key, value) {
      // Pula bateria, carregamento e GPS (já tratados acima)
      if (key == 'batteryLevel' ||
          key == 'isCharging' ||
          key == 'latitude' ||
          key == 'longitude' ||
          key == 'altitude' ||
          key == 'gpsAccuracy' ||
          key == 'dataQuality') {
        return;
      }

      if (value != null && value is num) {
        final config = SensorConfigurations.getConfig(key);
        if (config != null) {
          widgets.add(
            SensorCard(
              label: config.label,
              value: value.toDouble(),
              icon: config.icon,
              color: config.color,
              unit: config.unit,
              size: size,
              min: config.min,
              max: config.max,
            ),
          );
        }
      }
    });

    return widgets;
  }
}
