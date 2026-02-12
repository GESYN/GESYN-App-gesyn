import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../stores/user_store.dart';
import '../models/device.dart';
import '../services/device_service.dart';
import '../services/bluetooth_service.dart';
import '../widgets/app_drawer.dart';
import '../routes.dart';

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
      backgroundColor: const Color(0xFFE8E8E8),
      appBar: AppBar(
        title: const Text('Meus Dispositivos'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              await Navigator.of(context).pushNamed(AuthRoute.addDevice);
              _loadDevices(); // Recarrega após adicionar
            },
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _devices.isEmpty
          ? _buildEmptyState()
          : RefreshIndicator(
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
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.devices_other, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Nenhum dispositivo cadastrado',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Adicione seu primeiro dispositivo',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () async {
              await Navigator.of(context).pushNamed(AuthRoute.addDevice);
              _loadDevices();
            },
            icon: const Icon(Icons.add),
            label: const Text('Adicionar Dispositivo'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeviceCard(Device device) {
    final isOnline = device.isOnline;
    final isActive = device.isActive;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          // TODO: Navegar para detalhes do dispositivo
          _showDeviceDetails(device);
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isOnline ? Colors.green[50] : Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.router,
                      color: isOnline ? Colors.green : Colors.grey,
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
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          device.deviceId,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
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
                      color: isOnline ? Colors.green : Colors.grey,
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
              Row(
                children: [
                  _buildInfoChip(Icons.category, device.type, Colors.blue),
                  const SizedBox(width: 8),
                  _buildInfoChip(
                    Icons.settings,
                    isActive ? 'Ativo' : 'Inativo',
                    isActive ? Colors.green : Colors.orange,
                  ),
                  const SizedBox(width: 8),
                  _buildInfoChip(
                    Icons.update,
                    'v${device.firmwareVersion}',
                    Colors.purple,
                  ),
                ],
              ),
              if (device.description != null) ...[
                const SizedBox(height: 12),
                Text(
                  device.description!,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              if (device.lastSeen != null) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.access_time, size: 14, color: Colors.grey[500]),
                    const SizedBox(width: 4),
                    Text(
                      'Última vez: ${_formatDate(device.lastSeen!)}',
                      style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
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

  void _showDeviceDetails(Device device) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        device.name,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _buildDetailRow('ID do Dispositivo', device.deviceId),
                _buildDetailRow('Tipo', device.type),
                _buildDetailRow('Status', device.status),
                _buildDetailRow('Config Status', device.configStatus),
                _buildDetailRow('Firmware', device.firmwareVersion),
                if (device.ipAddress != null)
                  _buildDetailRow('Endereço IP', device.ipAddress!),
                if (device.description != null)
                  _buildDetailRow('Descrição', device.description!),

                // Botão Ativar (se estiver OFFLINE)
                if (device.status == 'OFFLINE') ...[
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        Navigator.pop(context);
                        await _activateDevice(device);
                      },
                      icon: const Icon(Icons.power_settings_new),
                      label: const Text('Ativar Dispositivo'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          _showEditDialog(device);
                        },
                        icon: const Icon(Icons.edit),
                        label: const Text('Editar'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          Navigator.pop(context);
                          await _deleteDevice(device);
                        },
                        icon: const Icon(Icons.delete),
                        label: const Text('Deletar'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteDevice(Device device) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Deletar Dispositivo'),
        content: Text(
          'Tem certeza que deseja deletar "${device.name}"?\nEsta ação não pode ser desfeita.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Deletar'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final userStore = Provider.of<UserStore>(context, listen: false);
      final result = await DeviceService.deleteDevice(
        id: device.id,
        token: userStore.accessToken,
      );

      if (result['ok'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Dispositivo deletado com sucesso'),
            backgroundColor: Colors.green,
          ),
        );
        _loadDevices();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['error'] ?? 'Erro ao deletar'),
            backgroundColor: Colors.red,
          ),
        );
      }
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

  void _showEditDialog(Device device) {
    final nameController = TextEditingController(text: device.name);
    final descriptionController = TextEditingController(
      text: device.description,
    );
    final firmwareController = TextEditingController(
      text: device.firmwareVersion,
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar Dispositivo'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Nome',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Descrição',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: firmwareController,
                decoration: const InputDecoration(
                  labelText: 'Versão do Firmware',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _updateDevice(
                device,
                nameController.text,
                descriptionController.text,
                firmwareController.text,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
            ),
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  Future<void> _updateDevice(
    Device device,
    String name,
    String description,
    String firmware,
  ) async {
    final userStore = Provider.of<UserStore>(context, listen: false);

    final result = await DeviceService.updateDevice(
      id: device.id,
      name: name.isNotEmpty ? name : null,
      description: description.isNotEmpty ? description : null,
      firmwareVersion: firmware.isNotEmpty ? firmware : null,
      token: userStore.accessToken,
    );

    if (result['ok'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Dispositivo atualizado com sucesso'),
          backgroundColor: Colors.green,
        ),
      );
      _loadDevices();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['error'] ?? 'Erro ao atualizar dispositivo'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
