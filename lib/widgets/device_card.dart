import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../models/dashboard_data.dart';
import 'sensors/sensor_card.dart';
import 'sensors/battery_card.dart';
import 'sensors/sensor_config.dart';

class DeviceCard extends StatelessWidget {
  final DeviceDashboard device;
  final VoidCallback? onTap;

  const DeviceCard({super.key, required this.device, this.onTap});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final margin = screenWidth < 600 ? 4.0 : 8.0;
    final hasGPS =
        device.latestReading?.latitude != null &&
        device.latestReading?.longitude != null;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: margin),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1F3A),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: device.isOnline
                ? const Color.fromARGB(255, 26, 55, 123).withOpacity(0.5)
                : const Color.fromARGB(255, 250, 250, 250).withOpacity(0.1),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: device.isOnline
                  ? const Color.fromARGB(255, 44, 17, 119).withOpacity(0.2)
                  : Colors.black.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            if (hasGPS) _buildMapSection(context),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(screenWidth < 600 ? 12 : 16),
                child: device.latestReading != null
                    ? _buildSensorData(context)
                    : _buildNoData(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmall = screenWidth < 600;

    return Container(
      padding: EdgeInsets.all(isSmall ? 16 : 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: device.isOnline
              ? [
                  const Color.fromARGB(255, 18, 40, 149),
                  const Color(0xFF0066FF),
                ]
              : [const Color(0xFF4A5568), const Color(0xFF2D3748)],
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
        boxShadow: device.isOnline
            ? [
                BoxShadow(
                  color: const Color.fromARGB(
                    255,
                    22,
                    57,
                    161,
                  ).withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ]
            : [],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.devices_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      device.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      device.deviceId,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      device.isOnline ? 'ONLINE' : 'OFFLINE',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildInfoChip(Icons.memory, device.type),
              const SizedBox(width: 8),
              _buildInfoChip(Icons.code, device.firmwareVersion),
              const SizedBox(width: 8),
              _buildInfoChip(
                Icons.analytics,
                '${device.totalReadings} leituras',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 255, 255, 255).withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 12),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapSection(BuildContext context) {
    final reading = device.latestReading!;
    final screenWidth = MediaQuery.of(context).size.width;
    final mapHeight = screenWidth < 600 ? 180.0 : 220.0;

    return Container(
      height: mapHeight,
      margin: EdgeInsets.fromLTRB(
        screenWidth < 600 ? 12 : 16,
        0,
        screenWidth < 600 ? 12 : 16,
        screenWidth < 600 ? 12 : 16,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF00D4FF).withOpacity(0.3),
          width: 2,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Stack(
          children: [
            FlutterMap(
              options: MapOptions(
                initialCenter: LatLng(reading.latitude!, reading.longitude!),
                initialZoom: 15,
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.none,
                ),
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.gesyn.app',
                  tileBuilder: (context, widget, tile) {
                    return ColorFiltered(
                      colorFilter: const ColorFilter.mode(
                        Colors.black,
                        BlendMode.saturation,
                      ),
                      child: widget,
                    );
                  },
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: LatLng(reading.latitude!, reading.longitude!),
                      width: 40,
                      height: 40,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF00D4FF), Color(0xFF0066FF)],
                          ),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF00D4FF).withOpacity(0.6),
                              blurRadius: 15,
                              spreadRadius: 3,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.devices_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Positioned(
              top: 8,
              left: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.black.withOpacity(0.8),
                      Colors.black.withOpacity(0.6),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: const Color(0xFF00D4FF).withOpacity(0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.location_on_rounded,
                      color: Color(0xFF00D4FF),
                      size: 14,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Lat: ${reading.latitude!.toStringAsFixed(4)}, Lon: ${reading.longitude!.toStringAsFixed(4)}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (reading.altitude != null)
              Positioned(
                bottom: 8,
                left: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.white.withOpacity(0.2)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.terrain_rounded,
                        color: Colors.white,
                        size: 12,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${reading.altitude!.toStringAsFixed(1)}m',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSensorData(BuildContext context) {
    final reading = device.latestReading!;
    final screenWidth = MediaQuery.of(context).size.width;
    final widgets = <Widget>[];
    final data = reading.toMap();

    // Bateria (se houver)
    if (reading.batteryLevel != null || reading.isCharging == true) {
      widgets.add(
        BatteryCard(
          batteryLevel: reading.batteryLevel,
          isCharging: reading.isCharging,
          size: SensorCardSize.normal,
        ),
      );
    }

    // Sensores genéricos
    data.forEach((key, value) {
      // Pula dados especiais já tratados
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
              size: SensorCardSize.normal,
              min: config.min,
              max: config.max,
            ),
          );
        }
      }
    });

    // Calcula colunas baseado na largura
    int crossAxisCount = 2;
    double childAspectRatio = 0.9;

    if (screenWidth >= 900) {
      crossAxisCount = 4;
      childAspectRatio = 0.95;
    } else if (screenWidth >= 600) {
      crossAxisCount = 3;
      childAspectRatio = 0.92;
    } else {
      // Mobile - mais altura para evitar overflow
      crossAxisCount = 2;
      childAspectRatio = 0.85;
    }

    return GridView.count(
      crossAxisCount: crossAxisCount,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: childAspectRatio,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: widgets,
    );
  }

  Widget _buildNoData() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                shape: BoxShape.circle,
              ),
              child: Icon(
                device.isOnline
                    ? Icons.pending_outlined
                    : Icons.cloud_off_outlined,
                size: 64,
                color: Colors.white.withOpacity(0.3),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              device.isOnline
                  ? 'Aguardando primeira leitura'
                  : 'Dispositivo offline',
              style: TextStyle(
                fontSize: 18,
                color: Colors.white.withOpacity(0.8),
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            if (!device.isOnline && device.lastSeen != null) ...[
              const SizedBox(height: 12),
              Text(
                'Última vez visto: ${_formatDate(device.lastSeen!)}',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.white.withOpacity(0.5),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 1) return 'agora mesmo';
    if (diff.inMinutes < 60) return '${diff.inMinutes} minutos atrás';
    if (diff.inHours < 24) return '${diff.inHours} horas atrás';
    if (diff.inDays < 30) return '${diff.inDays} dias atrás';
    return '${date.day}/${date.month}/${date.year}';
  }
}
