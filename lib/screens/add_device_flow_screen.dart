import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../stores/user_store.dart';
import '../models/device.dart';
import '../models/device_type.dart';
import '../services/device_service.dart';
import '../services/bluetooth_service.dart';

/// Fluxo completo de adição de dispositivo
/// Este arquivo contém todo o processo isolado em uma única tela
class AddDeviceFlowScreen extends StatefulWidget {
  const AddDeviceFlowScreen({super.key});

  @override
  State<AddDeviceFlowScreen> createState() => _AddDeviceFlowScreenState();
}

class _AddDeviceFlowScreenState extends State<AddDeviceFlowScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0;

  // Dados do dispositivo
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  DeviceType? _selectedType;

  // Dados WiFi
  final TextEditingController _ssidController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Dispositivo criado
  Device? _createdDevice;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _selectedType = DeviceTypes.gesynSolum;
  }

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _descriptionController.dispose();
    _ssidController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < 3) {
      setState(() => _currentStep++);
      _pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      _pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _createDevice() async {
    final userStore = Provider.of<UserStore>(context, listen: false);

    if (_nameController.text.isEmpty) {
      _showError('Por favor, insira um nome para o dispositivo');
      return;
    }

    setState(() => _loading = true);

    final result = await DeviceService.createDevice(
      name: _nameController.text,
      type: _selectedType!.id,
      description: _descriptionController.text,
      token: userStore.accessToken,
    );

    setState(() => _loading = false);

    if (result['ok'] == true) {
      setState(() => _createdDevice = result['device']);
      _nextStep();
    } else {
      _showError(result['error'] ?? 'Erro ao criar dispositivo');
    }
  }

  Future<void> _configureDevice() async {
    if (_ssidController.text.isEmpty || _passwordController.text.isEmpty) {
      _showError('Por favor, preencha o SSID e a senha do WiFi');
      return;
    }

    setState(() => _loading = true);

    // Envia configuração via Bluetooth
    final bluetoothResult = await BluetoothService.sendConfigToESP32(
      ssid: _ssidController.text,
      password: _passwordController.text,
      apiToken: _createdDevice!.apiToken,
      deviceId: _createdDevice!.deviceId,
    );

    if (bluetoothResult['ok'] != true) {
      setState(() => _loading = false);
      _showError('Falha ao enviar configuração via Bluetooth');
      return;
    }

    // Aguarda confirmação do ESP32
    final confirmResult = await BluetoothService.waitForESP32Confirmation();

    if (confirmResult['ok'] != true) {
      setState(() => _loading = false);
      _showError('ESP32 não confirmou a conexão WiFi');
      return;
    }

    setState(() => _loading = false);
    _nextStep();
  }

  Future<void> _activateDevice() async {
    final userStore = Provider.of<UserStore>(context, listen: false);
    setState(() => _loading = true);

    // Atualiza status para ONLINE
    final result = await DeviceService.activateDevice(
      id: _createdDevice!.id,
      token: userStore.accessToken!,
    );

    if (result['ok'] != true) {
      setState(() => _loading = false);
      _showError('Erro ao ativar dispositivo');
      return;
    }

    // Aguarda 10 segundos e verifica status
    await Future.delayed(const Duration(seconds: 10));

    final device = await DeviceService.getDeviceById(
      _createdDevice!.id,
      token: userStore.accessToken,
    );

    setState(() => _loading = false);

    if (device != null && device.isOnline) {
      setState(() => _createdDevice = device);
      _nextStep();
    } else {
      _showError('Dispositivo não está online ainda. Verifique a conexão.');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8E8E8),
      appBar: AppBar(
        title: const Text('Adicionar Dispositivo'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Indicador de progresso
          _buildProgressIndicator(),

          // Conteúdo das etapas
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildStep1(), // Informações básicas
                _buildStep2(), // Configuração WiFi
                _buildStep3(), // Ativação
                _buildStep4(), // Conclusão
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(4, (index) {
          final isActive = index == _currentStep;
          final isCompleted = index < _currentStep;

          return Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isCompleted
                      ? Colors.green
                      : isActive
                      ? Colors.blue
                      : Colors.grey[300],
                ),
                child: Center(
                  child: isCompleted
                      ? const Icon(Icons.check, color: Colors.white, size: 20)
                      : Text(
                          '${index + 1}',
                          style: TextStyle(
                            color: isActive ? Colors.white : Colors.grey[600],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              if (index < 3)
                Container(
                  width: 40,
                  height: 2,
                  color: isCompleted ? Colors.green : Colors.grey[300],
                ),
            ],
          );
        }),
      ),
    );
  }

  // ETAPA 1: Informações básicas do dispositivo
  Widget _buildStep1() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Informações do Dispositivo',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Vamos começar registrando seu dispositivo no sistema',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          const SizedBox(height: 32),

          // Nome
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: 'Nome do Dispositivo *',
              hintText: 'Ex: Sensor Estufa 01',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              prefixIcon: const Icon(Icons.devices),
            ),
          ),
          const SizedBox(height: 16),

          // Tipo
          DropdownButtonFormField<DeviceType>(
            initialValue: _selectedType,
            decoration: InputDecoration(
              labelText: 'Tipo de Dispositivo *',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              prefixIcon: const Icon(Icons.category),
            ),
            items: DeviceTypes.all.map((type) {
              return DropdownMenuItem(value: type, child: Text(type.name));
            }).toList(),
            onChanged: (value) {
              setState(() => _selectedType = value);
            },
          ),
          const SizedBox(height: 16),

          // Descrição
          TextField(
            controller: _descriptionController,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: 'Descrição',
              hintText: 'Descreva onde o dispositivo será usado',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Info do tipo selecionado
          if (_selectedType != null)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _selectedType!.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(_selectedType!.description),
                  const SizedBox(height: 12),
                  const Text(
                    'Sensores suportados:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  ...(_selectedType!.supportedSensors.map(
                    (sensor) => Padding(
                      padding: const EdgeInsets.only(left: 8, top: 4),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.check_circle,
                            size: 16,
                            color: Colors.green,
                          ),
                          const SizedBox(width: 8),
                          Text(sensor),
                        ],
                      ),
                    ),
                  )),
                ],
              ),
            ),
          const SizedBox(height: 32),

          // Botão
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _loading ? null : _createDevice,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _loading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                      'Criar Dispositivo',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  // ETAPA 2: Configuração WiFi via Bluetooth
  Widget _buildStep2() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Configuração WiFi',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Conecte o dispositivo à sua rede WiFi via Bluetooth',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          const SizedBox(height: 32),

          // Info do dispositivo criado
          if (_createdDevice != null)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.check_circle, color: Colors.green),
                      const SizedBox(width: 8),
                      const Text(
                        'Dispositivo Registrado',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text('Nome: ${_createdDevice!.name}'),
                  Text('ID: ${_createdDevice!.deviceId}'),
                  Text('Status: ${_createdDevice!.status}'),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: SelectableText(
                      'Token: ${_createdDevice!.apiToken}',
                      style: const TextStyle(
                        fontSize: 10,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 24),

          // Instruções
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.bluetooth, color: Colors.blue[700]),
                    const SizedBox(width: 8),
                    const Text(
                      'Como configurar:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Text('1. Ligue o dispositivo ESP32'),
                const SizedBox(height: 4),
                const Text('2. Ative o Bluetooth no seu celular'),
                const SizedBox(height: 4),
                const Text('3. Insira as credenciais WiFi abaixo'),
                const SizedBox(height: 4),
                const Text('4. Clique em "Enviar Configuração"'),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // SSID
          TextField(
            controller: _ssidController,
            decoration: InputDecoration(
              labelText: 'SSID (Nome da Rede WiFi) *',
              hintText: 'Nome da sua rede WiFi',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              prefixIcon: const Icon(Icons.wifi),
            ),
          ),
          const SizedBox(height: 16),

          // Senha
          TextField(
            controller: _passwordController,
            obscureText: true,
            decoration: InputDecoration(
              labelText: 'Senha WiFi *',
              hintText: 'Senha da rede WiFi',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              prefixIcon: const Icon(Icons.lock),
            ),
          ),
          const SizedBox(height: 32),

          // Botões
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _loading ? null : _previousStep,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Voltar'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: _loading ? null : _configureDevice,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _loading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text('Enviar Configuração'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Botão pular
          TextButton(
            onPressed: _loading
                ? null
                : () {
                    // Pula para a conclusão sem ativar
                    setState(() => _currentStep = 3);
                    _pageController.jumpToPage(3);
                  },
            child: const Text('Pular e configurar depois'),
          ),
        ],
      ),
    );
  }

  // ETAPA 3: Ativação do dispositivo
  Widget _buildStep3() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 40),
          Icon(Icons.router, size: 80, color: Colors.blue[700]),
          const SizedBox(height: 24),
          const Text(
            'Ativando Dispositivo',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'Aguarde enquanto o dispositivo se conecta à rede...',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),

          const CircularProgressIndicator(),
          const SizedBox(height: 24),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Column(
              children: [
                Text('⏱️ Tempo estimado: 10-15 segundos'),
                SizedBox(height: 8),
                Text(
                  'O ESP32 está se conectando à rede WiFi e ativando...',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),

          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _loading ? null : _activateDevice,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _loading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                      'Verificar Status',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  // ETAPA 4: Conclusão
  Widget _buildStep4() {
    final isOnline = _createdDevice?.isOnline ?? false;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 40),
          Icon(
            isOnline ? Icons.check_circle : Icons.info_outline,
            size: 100,
            color: isOnline ? Colors.green : Colors.blue,
          ),
          const SizedBox(height: 24),
          Text(
            isOnline ? 'Dispositivo Ativado!' : 'Dispositivo Registrado!',
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Text(
            isOnline
                ? 'Seu dispositivo está online e pronto para uso'
                : 'O dispositivo foi registrado com sucesso',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),

          if (_createdDevice != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _createdDevice!.name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildInfoRow('ID', _createdDevice!.deviceId),
                  _buildInfoRow('Tipo', _createdDevice!.type),
                  _buildInfoRow(
                    'Status',
                    _createdDevice!.status,
                    color: isOnline ? Colors.green : Colors.orange,
                  ),
                  _buildInfoRow('Firmware', _createdDevice!.firmwareVersion),
                  if (_createdDevice!.ipAddress != null)
                    _buildInfoRow('IP', _createdDevice!.ipAddress!),
                ],
              ),
            ),

          // Mensagem informativa quando não está online
          if (!isOnline) ...[
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(Icons.lightbulb_outline, color: Colors.blue[700]),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Como ativar depois?',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    '1. Vá em "Meus Dispositivos"\n'
                    '2. Clique no dispositivo criado\n'
                    '3. Clique em "Ativar Dispositivo"\n'
                    '4. Configure via Bluetooth quando estiver pronto',
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 32),

          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Concluir',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          if (!isOnline) ...[
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: () {
                setState(() => _currentStep = 1);
                _pageController.jumpToPage(1);
              },
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Configurar Agora'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
