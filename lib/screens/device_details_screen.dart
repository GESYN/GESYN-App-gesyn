import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../models/device_detail.dart';
import '../models/device.dart';
import '../services/device_service.dart';
import '../stores/user_store.dart';
import 'add_device_flow_screen.dart';

const kBackgroundColor = Color(0xFF0A0E27);
const kCardColor = Color(0xFF1A1F3A);
const kAccentColor = Color(0xFF00D4FF);

class DeviceDetailsScreen extends StatefulWidget {
  final String deviceId;

  const DeviceDetailsScreen({super.key, required this.deviceId});

  @override
  State<DeviceDetailsScreen> createState() => _DeviceDetailsScreenState();
}

class _DeviceDetailsScreenState extends State<DeviceDetailsScreen> {
  DeviceDetail? _device;
  bool _isLoading = true;
  String? _errorMessage;

  // Controle de métricas visíveis - DINÂMICO!
  List<String> _visibleMetrics = [];
  List<String> _allAvailableMetrics = [];
  bool _showMetricsSelector = false;

  @override
  void initState() {
    super.initState();
    _loadDeviceDetails();
  }

  Future<void> _loadDeviceDetails() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final userStore = Provider.of<UserStore>(context, listen: false);
      final device = await DeviceService.getDeviceDetailById(
        id: widget.deviceId,
        token: userStore.accessToken,
      );

      if (mounted) {
        if (device != null && device.data.isNotEmpty) {
          // Detecta DINAMICAMENTE todas as métricas disponíveis
          _allAvailableMetrics = _detectAvailableMetrics(device.data);
          // Seleciona 3 métricas aleatórias como padrão
          _visibleMetrics = (_allAvailableMetrics.toList()..shuffle())
              .take(3)
              .toList();
        }

        setState(() {
          _device = device;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  // DETECTA métricas DINAMICAMENTE - só mostra o que o dispositivo envia
  List<String> _detectAvailableMetrics(List<DeviceReading> readings) {
    final Set<String> metrics = {};

    for (var reading in readings) {
      if (reading.batteryLevel != null) metrics.add('batteryLevel');
      if (reading.airTemperature != null) metrics.add('airTemperature');
      if (reading.airHumidity != null) metrics.add('airHumidity');
      if (reading.soilMoisture != null) metrics.add('soilMoisture');
      if (reading.soilPh != null) metrics.add('soilPh');
      if (reading.lightIntensity != null) metrics.add('lightIntensity');
      if (reading.soilTemperature != null) metrics.add('soilTemperature');
      if (reading.rainAmount != null) metrics.add('rainAmount');
      if (reading.windSpeed != null) metrics.add('windSpeed');
      if (reading.windDirection != null) metrics.add('windDirection');
      if (reading.airPressure != null) metrics.add('airPressure');
      if (reading.uvIndex != null) metrics.add('uvIndex');
    }

    return metrics.toList();
  }

  void _showOptionsMenu() {
    if (_device == null) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: kCardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.edit, color: kAccentColor),
                title: const Text(
                  'Editar Dispositivo',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _editDevice();
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.redAccent),
                title: const Text(
                  'Excluir Dispositivo',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _deleteDevice();
                },
              ),
              ListTile(
                leading: const Icon(Icons.refresh, color: kAccentColor),
                title: const Text(
                  'Atualizar',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _loadDeviceDetails();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _editDevice() async {
    if (_device == null) return;

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => _EditDeviceDialog(device: _device!),
    );

    if (result != null && result['ok'] == true) {
      await _loadDeviceDetails();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Dispositivo atualizado com sucesso')),
        );
      }
    }
  }

  Future<void> _deleteDevice() async {
    if (_device == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: kCardColor,
        title: const Text(
          'Confirmar Exclusão',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Tem certeza que deseja excluir este dispositivo? Esta ação não pode ser desfeita.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: Colors.white70),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Excluir',
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      try {
        final userStore = Provider.of<UserStore>(context, listen: false);
        final result = await DeviceService.deleteDevice(
          id: widget.deviceId,
          token: userStore.accessToken,
        );

        if (result['ok'] == true) {
          if (mounted) {
            Navigator.pop(context, true);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Dispositivo excluído com sucesso')),
            );
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(result['error'] ?? 'Erro ao excluir')),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Erro: ${e.toString()}')));
        }
      }
    }
  }

  Future<void> _activateDevice() async {
    // Converte DeviceDetail para Device
    final device = Device(
      id: _device!.id,
      name: _device!.name,
      deviceId: _device!.deviceId,
      apiToken: _device!.apiToken,
      type: _device!.type,
      status: _device!.status,
      configStatus: _device!.configStatus,
      description: _device!.description,
      firmwareVersion: _device!.firmwareVersion,
      ownerId: _device!.ownerId,
      lastSeen: _device!.lastSeen,
      ipAddress: _device!.ipAddress,
      readingInterval: _device!.readingInterval,
      createdAt: _device!.createdAt,
      updatedAt: _device!.updatedAt,
    );

    // Redireciona para o fluxo de ativação
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddDeviceFlowScreen(existingDevice: device),
      ),
    );

    // Se retornou true, recarrega os dados
    if (result == true) {
      _loadDeviceDetails();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        title: Text(_device?.name ?? 'Detalhes do Dispositivo'),
        backgroundColor: kCardColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: _showOptionsMenu,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: kAccentColor))
          : _errorMessage != null
          ? _buildErrorState()
          : _device == null
          ? _buildDeviceNotFound()
          : _buildContent(),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 80, color: Colors.redAccent),
            const SizedBox(height: 20),
            const Text(
              'Erro ao carregar dispositivo',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              _errorMessage!,
              style: const TextStyle(color: Colors.white70),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _loadDeviceDetails,
              style: ElevatedButton.styleFrom(
                backgroundColor: kAccentColor,
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 15,
                ),
              ),
              child: const Text(
                'Tentar Novamente',
                style: TextStyle(color: Colors.black),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeviceNotFound() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.devices_other_outlined,
              size: 80,
              color: Colors.white38,
            ),
            const SizedBox(height: 20),
            const Text(
              'Dispositivo não encontrado',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Este dispositivo pode ter sido removido ou está offline',
              style: TextStyle(color: Colors.white70),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: kAccentColor,
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 15,
                ),
              ),
              child: const Text(
                'Voltar',
                style: TextStyle(color: Colors.black),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    return RefreshIndicator(
      onRefresh: _loadDeviceDetails,
      color: kAccentColor,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDeviceHeader(),
            const SizedBox(height: 20),
            // Botão proeminente de ativação quando dispositivo está inativo
            if (_device!.status.toUpperCase() != 'ONLINE') ...[
              _buildActivateButton(),
              const SizedBox(height: 20),
            ],
            _buildQuickStats(),
            const SizedBox(height: 20),
            // SÓ MOSTRA se tiver métricas disponíveis
            if (_allAvailableMetrics.isNotEmpty) ...[
              _buildMetricsSection(),
              const SizedBox(height: 20),
            ],
            // SÓ MOSTRA mapa se tiver GPS
            _buildMapSection(),
            const SizedBox(height: 20),
            _buildChartsSection(),
            const SizedBox(height: 20),
            _buildDetailedHistory(),
          ],
        ),
      ),
    );
  }

  Widget _buildActivateButton() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF00D4FF), Color(0xFF0099CC)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00D4FF).withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _activateDevice,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.power_settings_new,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'ATIVAR DISPOSITIVO',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Configurar conexão e iniciar monitoramento',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDeviceHeader() {
    final device = _device!;
    final isActive = device.status.toLowerCase() == 'active';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [kCardColor, kCardColor.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  device.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: isActive
                      ? Colors.green.withOpacity(0.2)
                      : Colors.red.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isActive ? Colors.green : Colors.red,
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: isActive ? Colors.green : Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      device.status,
                      style: TextStyle(
                        color: isActive ? Colors.green : Colors.red,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoRow(Icons.tag, 'ID', device.id),
          const SizedBox(height: 12),
          _buildInfoRow(Icons.category, 'Tipo', device.type),
          const SizedBox(height: 12),
          _buildInfoRow(Icons.person, 'Proprietário', device.owner.username),
          if (device.description != null && device.description!.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Divider(color: Colors.white24),
            const SizedBox(height: 16),
            const Text(
              'Descrição',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              device.description!,
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: kAccentColor, size: 20),
        const SizedBox(width: 10),
        Text(
          '$label: ',
          style: const TextStyle(color: Colors.white70, fontSize: 14),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickStats() {
    final count = _device!.count;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Estatísticas',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                Icons.article,
                'Logs',
                count.logs.toString(),
                Colors.blue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                Icons.api,
                'API Calls',
                count.apiCalls.toString(),
                Colors.purple,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                Icons.data_usage,
                'Leituras',
                count.data.toString(),
                Colors.green,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(
    IconData icon,
    String label,
    String value,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kCardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // Sistema de métricas DINÂMICO com escolha do usuário
  Widget _buildMetricsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Métricas',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            TextButton.icon(
              onPressed: () {
                setState(() {
                  _showMetricsSelector = !_showMetricsSelector;
                });
              },
              icon: Icon(
                _showMetricsSelector ? Icons.visibility_off : Icons.visibility,
                color: kAccentColor,
                size: 18,
              ),
              label: Text(
                _showMetricsSelector ? 'Ocultar' : 'Escolher',
                style: const TextStyle(color: kAccentColor, fontSize: 12),
              ),
            ),
          ],
        ),
        if (_showMetricsSelector) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: kCardColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _allAvailableMetrics.map((metric) {
                final isVisible = _visibleMetrics.contains(metric);
                return FilterChip(
                  label: Text(_getMetricLabel(metric)),
                  selected: isVisible,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _visibleMetrics.add(metric);
                      } else {
                        if (_visibleMetrics.length > 1) {
                          _visibleMetrics.remove(metric);
                        }
                      }
                    });
                  },
                  selectedColor: kAccentColor.withOpacity(0.3),
                  checkmarkColor: kAccentColor,
                  labelStyle: TextStyle(
                    color: isVisible ? kAccentColor : Colors.white70,
                  ),
                  backgroundColor: kCardColor,
                );
              }).toList(),
            ),
          ),
        ],
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: _visibleMetrics.map((metric) {
            return _buildMetricCard(metric);
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildMetricCard(String metricKey) {
    final readings = _device!.data;
    final latestReading = readings.firstWhere(
      (r) => _getMetricValue(r, metricKey) != null,
      orElse: () => readings.first,
    );

    final value = _getMetricValue(latestReading, metricKey);
    if (value == null) return const SizedBox.shrink(); // NÃO MOSTRA se null

    final label = _getMetricLabel(metricKey);
    final icon = _getIconForKey(metricKey);
    final color = _getColorForKey(metricKey);
    final formattedValue = _formatValue(metricKey, value);

    return Container(
      width: (MediaQuery.of(context).size.width - 56) / 3,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kCardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            formattedValue,
            style: TextStyle(
              color: color,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 11),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  dynamic _getMetricValue(DeviceReading reading, String key) {
    switch (key) {
      case 'batteryLevel':
        return reading.batteryLevel;
      case 'airTemperature':
        return reading.airTemperature;
      case 'airHumidity':
        return reading.airHumidity;
      case 'soilMoisture':
        return reading.soilMoisture;
      case 'soilPh':
        return reading.soilPh;
      case 'lightIntensity':
        return reading.lightIntensity;
      case 'soilTemperature':
        return reading.soilTemperature;
      case 'rainAmount':
        return reading.rainAmount;
      case 'windSpeed':
        return reading.windSpeed;
      case 'windDirection':
        return reading.windDirection;
      case 'airPressure':
        return reading.airPressure;
      case 'uvIndex':
        return reading.uvIndex;
      default:
        return null;
    }
  }

  // NÃO MOSTRA mapa se não tem GPS!
  Widget _buildMapSection() {
    final readings = _device!.data;

    if (readings.isEmpty ||
        readings.first.latitude == null ||
        readings.first.longitude == null) {
      return const SizedBox.shrink(); // NÃO MOSTRA NADA!
    }

    final gpsPoints = readings
        .where((r) => r.latitude != null && r.longitude != null)
        .map((r) => LatLng(r.latitude!, r.longitude!))
        .toList();

    if (gpsPoints.isEmpty) return const SizedBox.shrink();

    final lastLocation = gpsPoints.first;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Localização',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          height: 250,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: kAccentColor.withOpacity(0.3)),
          ),
          clipBehavior: Clip.hardEdge,
          child: FlutterMap(
            options: MapOptions(initialCenter: lastLocation, initialZoom: 15),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.gesyn.app',
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: lastLocation,
                    width: 60,
                    height: 60,
                    child: const Icon(
                      Icons.location_on,
                      color: Colors.red,
                      size: 50,
                    ),
                  ),
                  ...gpsPoints
                      .skip(1)
                      .map(
                        (point) => Marker(
                          point: point,
                          width: 30,
                          height: 30,
                          child: const Icon(
                            Icons.location_on,
                            color: kAccentColor,
                            size: 24,
                          ),
                        ),
                      ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Gráficos DINÂMICOS - só cria para métricas que existem
  Widget _buildChartsSection() {
    final readings = _device!.data;

    if (readings.isEmpty || _allAvailableMetrics.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Gráficos',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ..._visibleMetrics.map((metric) {
          final data = readings
              .map((r) => _getMetricValue(r, metric))
              .where((v) => v != null)
              .map((v) => (v as num).toDouble())
              .toList();

          if (data.isEmpty) return const SizedBox.shrink();

          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _buildChart(
              _getMetricLabel(metric),
              data,
              _getColorForKey(metric),
              _getUnitForKey(metric),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildChart(
    String title,
    List<double> data,
    Color color,
    String unit,
  ) {
    if (data.isEmpty) return const SizedBox.shrink();

    final spots = data
        .asMap()
        .entries
        .map((e) => FlSpot(e.key.toDouble(), e.value))
        .toList();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kCardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 150,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Colors.white.withOpacity(0.1),
                      strokeWidth: 1,
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          '${value.toInt()}$unit',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 10,
                          ),
                        );
                      },
                    ),
                  ),
                  bottomTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: color,
                    barWidth: 3,
                    dotData: const FlDotData(show: true),
                    belowBarData: BarAreaData(
                      show: true,
                      color: color.withOpacity(0.2),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailedHistory() {
    final readings = _device!.data;

    if (readings.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Histórico Detalhado',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${readings.length} leituras',
                style: const TextStyle(
                  color: Colors.orange,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: readings.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            return _buildReadingCard(readings[index], index);
          },
        ),
      ],
    );
  }

  Widget _buildReadingCard(DeviceReading reading, int index) {
    final dataMap = reading.toMap();
    dataMap.removeWhere((key, value) => value == null); // Remove nulls

    return Container(
      decoration: BoxDecoration(
        color: kCardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: kAccentColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '#${index + 1}',
                style: const TextStyle(
                  color: kAccentColor,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _formatRelativeTime(reading.timestamp),
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
            ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text(
            _formatDateTime(reading.timestamp),
            style: const TextStyle(color: Colors.white54, fontSize: 12),
          ),
        ),
        iconColor: kAccentColor,
        collapsedIconColor: Colors.white54,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: dataMap.entries.map((entry) {
              return _buildDataChip(entry.key, entry.value);
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildDataChip(String key, dynamic value) {
    final icon = _getIconForKey(key);
    final label = _getLabelForKey(key);
    final formattedValue = _formatValue(key, value);
    final color = _getColorForKey(key);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 6),
          Text(
            '$label: ',
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            formattedValue,
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        ],
      ),
    );
  }

  // Helper methods
  String _formatDateTime(DateTime dt) {
    return DateFormat('dd/MM/yyyy HH:mm:ss').format(dt);
  }

  String _formatRelativeTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);

    if (diff.inMinutes < 1) return 'Agora';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m atrás';
    if (diff.inHours < 24) return '${diff.inHours}h atrás';
    if (diff.inDays < 7) return '${diff.inDays}d atrás';
    if (diff.inDays < 30) return '${(diff.inDays / 7).floor()}sem atrás';
    if (diff.inDays < 365) return '${(diff.inDays / 30).floor()}m atrás';
    return '${(diff.inDays / 365).floor()}a atrás';
  }

  IconData _getIconForKey(String key) {
    switch (key) {
      case 'batteryLevel':
        return Icons.battery_charging_full;
      case 'latitude':
      case 'longitude':
        return Icons.location_on;
      case 'airTemperature':
        return Icons.thermostat;
      case 'airHumidity':
        return Icons.water_drop;
      case 'soilMoisture':
        return Icons.grass;
      case 'soilPh':
        return Icons.science;
      case 'lightIntensity':
        return Icons.light_mode;
      case 'soilTemperature':
        return Icons.thermostat_outlined;
      case 'rainAmount':
        return Icons.water;
      case 'windSpeed':
        return Icons.air;
      case 'windDirection':
        return Icons.explore;
      case 'airPressure':
        return Icons.compress;
      case 'uvIndex':
        return Icons.wb_sunny;
      default:
        return Icons.sensors;
    }
  }

  String _getLabelForKey(String key) {
    switch (key) {
      case 'batteryLevel':
        return 'Bateria';
      case 'latitude':
        return 'Latitude';
      case 'longitude':
        return 'Longitude';
      case 'airTemperature':
        return 'Temp. Ar';
      case 'airHumidity':
        return 'Umid. Ar';
      case 'soilMoisture':
        return 'Umid. Solo';
      case 'soilPh':
        return 'pH Solo';
      case 'lightIntensity':
        return 'Luz';
      case 'soilTemperature':
        return 'Temp. Solo';
      case 'rainAmount':
        return 'Chuva';
      case 'windSpeed':
        return 'Vel. Vento';
      case 'windDirection':
        return 'Dir. Vento';
      case 'airPressure':
        return 'Pressão';
      case 'uvIndex':
        return 'UV';
      default:
        return key;
    }
  }

  String _getMetricLabel(String key) {
    return _getLabelForKey(key);
  }

  String _getUnitForKey(String key) {
    switch (key) {
      case 'batteryLevel':
      case 'airHumidity':
      case 'soilMoisture':
        return '%';
      case 'airTemperature':
      case 'soilTemperature':
        return '°C';
      case 'rainAmount':
        return 'mm';
      case 'windSpeed':
        return 'km/h';
      case 'windDirection':
        return '°';
      case 'airPressure':
        return 'hPa';
      default:
        return '';
    }
  }

  String _formatValue(String key, dynamic value) {
    if (value == null) return 'N/A';

    switch (key) {
      case 'batteryLevel':
      case 'airHumidity':
      case 'soilMoisture':
        return '$value%';
      case 'airTemperature':
      case 'soilTemperature':
        return '$value°C';
      case 'latitude':
      case 'longitude':
        if (value is num) return value.toStringAsFixed(5);
        return value.toString();
      case 'rainAmount':
        return '${value}mm';
      case 'windSpeed':
        return '${value}km/h';
      case 'windDirection':
        return '$value°';
      case 'airPressure':
        return '${value}hPa';
      default:
        return value.toString();
    }
  }

  Color _getColorForKey(String key) {
    switch (key) {
      case 'batteryLevel':
        return Colors.green;
      case 'latitude':
      case 'longitude':
        return kAccentColor;
      case 'airTemperature':
        return Colors.orange;
      case 'airHumidity':
        return Colors.blue;
      case 'soilMoisture':
        return Colors.brown;
      case 'soilPh':
        return Colors.purple;
      case 'lightIntensity':
        return Colors.yellow;
      case 'soilTemperature':
        return Colors.deepOrange;
      case 'rainAmount':
        return Colors.lightBlue;
      case 'windSpeed':
        return Colors.cyan;
      case 'windDirection':
        return Colors.teal;
      case 'airPressure':
        return Colors.indigo;
      case 'uvIndex':
        return Colors.amber;
      default:
        return Colors.grey;
    }
  }
}

// Edit Device Dialog
class _EditDeviceDialog extends StatefulWidget {
  final DeviceDetail device;

  const _EditDeviceDialog({required this.device});

  @override
  State<_EditDeviceDialog> createState() => _EditDeviceDialogState();
}

class _EditDeviceDialogState extends State<_EditDeviceDialog> {
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late String _selectedType;
  late String _selectedStatus;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.device.name);
    _descriptionController = TextEditingController(
      text: widget.device.description ?? '',
    );
    _selectedType = widget.device.type;
    _selectedStatus = widget.device.status;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nome não pode estar vazio')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final userStore = Provider.of<UserStore>(context, listen: false);

      await DeviceService.updateDevice(
        id: widget.device.id,
        name: _nameController.text.trim() != widget.device.name
            ? _nameController.text.trim()
            : null,
        type: _selectedType != widget.device.type ? _selectedType : null,
        status: _selectedStatus != widget.device.status
            ? _selectedStatus
            : null,
        description:
            _descriptionController.text.trim() !=
                (widget.device.description ?? '')
            ? _descriptionController.text.trim()
            : null,
        token: userStore.accessToken,
      );

      if (mounted) {
        Navigator.pop(context, {'ok': true});
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erro: ${e.toString()}')));
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: kCardColor,
      title: const Text(
        'Editar Dispositivo',
        style: TextStyle(color: Colors.white),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Nome',
                labelStyle: TextStyle(color: Colors.white70),
                prefixIcon: Icon(Icons.devices, color: kAccentColor),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white24),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: kAccentColor),
                ),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _selectedType,
              dropdownColor: kCardColor,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Tipo',
                labelStyle: TextStyle(color: Colors.white70),
                prefixIcon: Icon(Icons.category, color: kAccentColor),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white24),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: kAccentColor),
                ),
              ),
              items: ['sensor', 'gateway', 'actuator', 'other']
                  .map(
                    (type) => DropdownMenuItem(value: type, child: Text(type)),
                  )
                  .toList(),
              onChanged: (value) => setState(() => _selectedType = value!),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _selectedStatus,
              dropdownColor: kCardColor,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Status',
                labelStyle: TextStyle(color: Colors.white70),
                prefixIcon: Icon(Icons.info, color: kAccentColor),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white24),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: kAccentColor),
                ),
              ),
              items: ['active', 'inactive', 'maintenance']
                  .map(
                    (status) =>
                        DropdownMenuItem(value: status, child: Text(status)),
                  )
                  .toList(),
              onChanged: (value) => setState(() => _selectedStatus = value!),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              style: const TextStyle(color: Colors.white),
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Descrição',
                labelStyle: TextStyle(color: Colors.white70),
                prefixIcon: Icon(Icons.description, color: kAccentColor),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white24),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: kAccentColor),
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.pop(context),
          child: const Text(
            'Cancelar',
            style: TextStyle(color: Colors.white70),
          ),
        ),
        ElevatedButton(
          onPressed: _isSubmitting ? null : _submit,
          style: ElevatedButton.styleFrom(backgroundColor: kAccentColor),
          child: _isSubmitting
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.black,
                  ),
                )
              : const Text('Salvar', style: TextStyle(color: Colors.black)),
        ),
      ],
    );
  }
}
