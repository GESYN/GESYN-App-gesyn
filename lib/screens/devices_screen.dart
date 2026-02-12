import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:ui';
import '../stores/user_store.dart';
import '../models/device.dart';
import '../services/device_service.dart';
import '../services/bluetooth_service.dart';
import '../widgets/app_drawer.dart';
import '../routes.dart';

const kBackgroundColor = Color(0xFF0A0E27);
const kCardColor = Color(0xFF1A1F3A);
const kAccentColor = Color(0xFF00D4FF);
const kSecondaryAccent = Color(0xFF7B2FFF);

class DevicesScreen extends StatefulWidget {
  const DevicesScreen({super.key});

  @override
  State<DevicesScreen> createState() => _DevicesScreenState();
}

class _DevicesScreenState extends State<DevicesScreen> {
  List<Device> _devices = [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loadDevices();
  }

  Future<void> _loadDevices() async {
    final userStore = Provider.of<UserStore>(context, listen: false);
    setState(() => _loading = true);

    final devices = await DeviceService.getDevices(
      token: userStore.accessToken,
    );

    setState(() {
      _devices = devices;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        title: const Text(
          'Meus Dispositivos',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: kCardColor,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded, color: Colors.white),
            onPressed: () async {
              await Navigator.of(context).pushNamed(AuthRoute.addDevice);
              _loadDevices();
            },
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: kAccentColor))
          : _devices.isEmpty
          ? _buildEmptyState()
          : RefreshIndicator(
              color: kAccentColor,
              onRefresh: _loadDevices,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _devices.length,
                itemBuilder: (context, index) {
                  return _buildDeviceCard(_devices[index]);
                },
              ),
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [kAccentColor.withOpacity(0.2), Colors.transparent],
                ),
              ),
              child: Icon(
                Icons.devices_other_rounded,
                size: 80,
                color: kAccentColor.withOpacity(0.5),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Nenhum dispositivo cadastrado',
              style: TextStyle(
                fontSize: 20,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Adicione seu primeiro dispositivo IoT e comece a monitorar',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withOpacity(0.6),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () async {
                await Navigator.of(context).pushNamed(AuthRoute.addDevice);
                _loadDevices();
              },
              icon: const Icon(Icons.add_rounded, size: 24),
              label: const Text(
                'Adicionar Dispositivo',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: kAccentColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeviceCard(Device device) {
    final isOnline = device.isOnline;
    final isActive = device.isActive;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [kCardColor, kCardColor.withOpacity(0.8)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isOnline
              ? kAccentColor.withOpacity(0.2)
              : Colors.white.withOpacity(0.05),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isOnline
                ? kAccentColor.withOpacity(0.1)
                : Colors.black.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () async {
              final result = await Navigator.of(
                context,
              ).pushNamed(AuthRoute.deviceDetails, arguments: device.id);

              // Se retornou com ação de ativar, inicia o fluxo de ativação
              if (result is Map && result['action'] == 'activate') {
                // Cria um objeto Device temporário a partir dos dados recebidos
                final deviceData = result['device'] as Map<String, dynamic>;
                final deviceToActivate = Device(
                  id: deviceData['id'],
                  name: deviceData['name'],
                  deviceId: deviceData['deviceId'],
                  apiToken: deviceData['apiToken'],
                  type: device.type,
                  status: device.status,
                  configStatus: device.configStatus,
                  firmwareVersion: device.firmwareVersion,
                  ownerId: device.ownerId,
                  createdAt: device.createdAt,
                  updatedAt: device.updatedAt,
                );
                await _activateDevice(deviceToActivate);
              }

              _loadDevices(); // Recarrega após voltar (caso tenha editado/excluído)
            },
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: isOnline
                                ? [
                                    kAccentColor.withOpacity(0.3),
                                    kAccentColor.withOpacity(0.2),
                                  ]
                                : [Colors.grey.shade700, Colors.grey.shade600],
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          Icons.router_rounded,
                          color: isOnline ? kAccentColor : Colors.grey.shade400,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              device.name,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              device.deviceId,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white.withOpacity(0.6),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: isOnline
                                ? [
                                    kAccentColor.withOpacity(0.8),
                                    kSecondaryAccent.withOpacity(0.8),
                                  ]
                                : [Colors.grey.shade700, Colors.grey.shade600],
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
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
                              isOnline ? 'ONLINE' : 'OFFLINE',
                              style: const TextStyle(
                                color: Colors.white,
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
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildInfoChip(
                        Icons.category_rounded,
                        device.type,
                        kAccentColor,
                      ),
                      _buildInfoChip(
                        Icons.settings_rounded,
                        isActive ? 'Ativo' : 'Inativo',
                        isActive ? kAccentColor : Colors.orange,
                      ),
                      _buildInfoChip(
                        Icons.update_rounded,
                        'v${device.firmwareVersion}',
                        kSecondaryAccent,
                      ),
                    ],
                  ),
                  if (device.description != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      device.description!,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.7),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  if (device.lastSeen != null) ...[
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time_rounded,
                          size: 14,
                          color: Colors.white.withOpacity(0.5),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Última vez: ${_formatDate(device.lastSeen!)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.5),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.3), color.withOpacity(0.1)],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.5), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 1) {
      return 'Agora mesmo';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes}min atrás';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h atrás';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}d atrás';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  Future<void> _activateDevice(Device device) async {
    // Primeiro, solicita as credenciais WiFi do usuário
    final wifiConfig = await _showWiFiConfigDialog();

    if (wifiConfig == null) {
      // Usuário cancelou
      return;
    }

    final userStore = Provider.of<UserStore>(context, listen: false);

    // Mostra dialog de progresso do fluxo de ativação
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(
              'Conectando ao dispositivo via Bluetooth...',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );

    try {
      // PASSO 1: Envia configuração WiFi + API Token via Bluetooth
      final bluetoothResult = await BluetoothService.sendConfigToESP32(
        ssid: wifiConfig['ssid']!,
        password: wifiConfig['password']!,
        apiToken: device.apiToken,
        deviceId: device.deviceId,
      );

      if (bluetoothResult['ok'] != true) {
        Navigator.pop(context); // Fecha dialog
        _showErrorDialog(
          'Erro na comunicação Bluetooth',
          bluetoothResult['error'] ?? 'Falha ao enviar dados ao ESP32',
        );
        return;
      }

      // Atualiza mensagem do dialog
      Navigator.pop(context);
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text(
                'ESP32 conectando à rede WiFi...\nAguardando confirmação...',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );

      // PASSO 2: Aguarda confirmação do ESP32
      if (bluetoothResult['wifiConnected'] != true) {
        Navigator.pop(context);
        _showErrorDialog(
          'Falha na conexão WiFi',
          'O ESP32 não conseguiu conectar à rede WiFi. Verifique as credenciais.',
        );
        return;
      }

      // PASSO 3: Atualiza o dispositivo na API para status ONLINE
      final updateResult = await DeviceService.updateDevice(
        id: device.id,
        status: 'ONLINE',
        token: userStore.accessToken,
      );

      Navigator.pop(context); // Fecha dialog

      if (updateResult['ok'] == true) {
        _showSuccessDialog(
          'Dispositivo Ativado!',
          'O ESP32 está conectado à rede WiFi (IP: ${bluetoothResult['ip']})\n\n'
              'Agora ele pode enviar dados ao servidor automaticamente.',
        );
        _loadDevices();
      } else {
        _showErrorDialog(
          'Erro ao atualizar status',
          updateResult['error'] ?? 'Falha ao atualizar no servidor',
        );
      }
    } catch (e) {
      Navigator.pop(context);
      _showErrorDialog('Erro', 'Erro inesperado: $e');
    }
  }

  /// Dialog para solicitar credenciais WiFi
  Future<Map<String, String>?> _showWiFiConfigDialog() async {
    final ssidController = TextEditingController();
    final passwordController = TextEditingController();

    return showDialog<Map<String, String>>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Configurar WiFi'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Digite as credenciais da rede WiFi que o ESP32 irá usar:',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: ssidController,
              decoration: const InputDecoration(
                labelText: 'SSID (Nome da Rede)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.wifi),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(
                labelText: 'Senha WiFi',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock),
              ),
              obscureText: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              if (ssidController.text.isEmpty ||
                  passwordController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Preencha todos os campos'),
                    backgroundColor: Colors.orange,
                  ),
                );
                return;
              }
              Navigator.pop(context, {
                'ssid': ssidController.text,
                'password': passwordController.text,
              });
            },
            child: const Text('Conectar'),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 28),
            const SizedBox(width: 8),
            Text(title),
          ],
        ),
        content: Text(message),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.error, color: Colors.red, size: 28),
            const SizedBox(width: 8),
            Text(title),
          ],
        ),
        content: Text(message),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }
}
