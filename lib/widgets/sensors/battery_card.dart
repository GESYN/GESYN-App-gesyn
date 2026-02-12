import 'package:flutter/material.dart';
import 'sensor_config.dart';

class BatteryCard extends StatelessWidget {
  final double? batteryLevel;
  final bool? isCharging;
  final SensorCardSize size;
  final VoidCallback? onTap;

  const BatteryCard({
    super.key,
    this.batteryLevel,
    this.isCharging,
    this.size = SensorCardSize.normal,
    this.onTap,
  });

  IconData get _batteryIcon {
    if (isCharging == true) return Icons.battery_charging_full;

    if (batteryLevel == null) return Icons.battery_unknown;

    if (batteryLevel! >= 90) return Icons.battery_full;
    if (batteryLevel! >= 70) return Icons.battery_6_bar;
    if (batteryLevel! >= 50) return Icons.battery_5_bar;
    if (batteryLevel! >= 30) return Icons.battery_3_bar;
    if (batteryLevel! >= 10) return Icons.battery_2_bar;
    return Icons.battery_alert;
  }

  Color get _batteryColor {
    if (isCharging == true) return Colors.green;

    if (batteryLevel == null) return Colors.grey;

    if (batteryLevel! >= 50) return Colors.green;
    if (batteryLevel! >= 20) return Colors.orange;
    return Colors.red;
  }

  String get _statusText {
    if (isCharging == true && batteryLevel != null) {
      return 'Carregando';
    } else if (isCharging == true) {
      return 'Em Carregamento';
    } else if (batteryLevel != null) {
      return '${batteryLevel!.toStringAsFixed(0)}%';
    }
    return 'N/A';
  }

  @override
  Widget build(BuildContext context) {
    return size == SensorCardSize.mini ? _buildMini() : _buildNormal();
  }

  Widget _buildNormal() {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [const Color(0xFF1A1F3A), const Color(0xFF141829)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _batteryColor.withOpacity(0.3), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: _batteryColor.withOpacity(0.15),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _batteryColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(_batteryIcon, color: _batteryColor, size: 22),
                ),
                if (batteryLevel != null) _buildCircularProgress(),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              'Bateria',
              style: TextStyle(
                fontSize: 11,
                color: Colors.white.withOpacity(0.6),
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 6),
            Flexible(
              child: Text(
                _statusText,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      color: _batteryColor.withOpacity(0.5),
                      blurRadius: 10,
                    ),
                  ],
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (isCharging == true && batteryLevel != null) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.flash_on, size: 12, color: Colors.amber[700]),
                  const SizedBox(width: 3),
                  Flexible(
                    child: Text(
                      'Carregando',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.amber[700],
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMini() {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [const Color(0xFF1A1F3A), const Color(0xFF141829)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _batteryColor.withOpacity(0.3), width: 1),
          boxShadow: [
            BoxShadow(
              color: _batteryColor.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _batteryColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(_batteryIcon, color: _batteryColor, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Bateria',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.white.withOpacity(0.6),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        _statusText,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      if (isCharging == true) ...[
                        const SizedBox(width: 4),
                        Icon(
                          Icons.flash_on,
                          size: 12,
                          color: Colors.amber[700],
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCircularProgress() {
    if (batteryLevel == null) return const SizedBox();

    final percentage = (batteryLevel! / 100).clamp(0.0, 1.0);

    return SizedBox(
      width: 40,
      height: 40,
      child: Stack(
        children: [
          CircularProgressIndicator(
            value: percentage,
            strokeWidth: 3,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(_batteryColor),
          ),
          Center(
            child: Text(
              '${batteryLevel!.toInt()}%',
              style: const TextStyle(fontSize: 8, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
