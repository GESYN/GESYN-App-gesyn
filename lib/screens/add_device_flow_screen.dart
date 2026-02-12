import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:provider/provider.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'dart:convert';
import '../models/device.dart';
import '../models/device_type.dart';
import '../services/device_service.dart';
import '../stores/user_store.dart';

const kBackgroundColor = Color(0xFF0A0E27);
const kCardColor = Color(0xFF1A1F3A);
const kAccentColor = Color(0xFF00D4FF);
const kSecondaryAccent = Color(0xFF7B2FFF);

class AddDeviceFlowScreen extends StatefulWidget {
  final Device? existingDevice; // Dispositivo já criado que precisa ser ativado

  const AddDeviceFlowScreen({super.key, this.existingDevice});

  @override
  State<AddDeviceFlowScreen> createState() => _AddDeviceFlowScreenState();
}

class _AddDeviceFlowScreenState extends State<AddDeviceFlowScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  bool _isMobile = false;

  // Controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _ssidController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  DeviceType? _selectedType;
  Device? _createdDevice;
  bool _loading = false;

  // Bluetooth
  List<ScanResult> _scanResults = [];
  BluetoothDevice? _connectedDevice;
  bool _isScanning = false;
  bool _isConnected = false;

  @override
  void initState() {
    super.initState();
    _selectedType = DeviceTypes.gesynSolum;
    _checkPlatform();

    // Se há um dispositivo existente, pula para o step de Bluetooth (ativação)
    if (widget.existingDevice != null) {
      _createdDevice = widget.existingDevice;
      _nameController.text = widget.existingDevice!.name;
      _descriptionController.text = widget.existingDevice!.description ?? '';

      // Define o tipo baseado no dispositivo
      final deviceType = DeviceTypes.getById(widget.existingDevice!.type);
      if (deviceType != null) {
        _selectedType = deviceType;
      }

      // Se for mobile, vai direto para o step 1 (Bluetooth - índice 1)
      if (_isMobile) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          setState(() => _currentStep = 1);
          _pageController.jumpToPage(1);
        });
      }
    }
  }

  void _checkPlatform() {
    setState(() {
      _isMobile = !kIsWeb && (Platform.isAndroid || Platform.isIOS);
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _descriptionController.dispose();
    _ssidController.dispose();
    _passwordController.dispose();
    _connectedDevice?.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        backgroundColor: kCardColor,
        title: Text(
          widget.existingDevice != null
              ? 'Ativar Dispositivo'
              : 'Adicionar Dispositivo',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildStepIndicator(),
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildDeviceInfoStep(),
                if (_isMobile) ...[
                  _buildBluetoothStep(),
                  _buildWiFiStep(),
                  _buildActivationStep(),
                ],
                _buildSuccessStep(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepIndicator() {
    final totalSteps = _isMobile ? 5 : 2;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: kCardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: List.generate(totalSteps, (index) {
          final isActive = index <= _currentStep;
          return Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 4,
                    decoration: BoxDecoration(
                      gradient: isActive
                          ? LinearGradient(
                              colors: [kAccentColor, kSecondaryAccent],
                            )
                          : null,
                      color: isActive ? null : Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                if (index < totalSteps - 1) const SizedBox(width: 8),
              ],
            ),
          );
        }),
      ),
    );
  }

  // ========== STEP 1: Informações do Dispositivo ==========
  Widget _buildDeviceInfoStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            icon: Icons.info_outline_rounded,
            title: 'Informações do Dispositivo',
            subtitle: 'Preencha os dados básicos',
          ),
          const SizedBox(height: 24),
          _buildTextField(
            controller: _nameController,
            label: 'Nome do Dispositivo',
            icon: Icons.router_rounded,
            hint: 'Ex: Sensor Temperatura',
          ),
          const SizedBox(height: 16),
          _buildDeviceTypeSelector(),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _descriptionController,
            label: 'Descrição (opcional)',
            icon: Icons.description_rounded,
            hint: 'Adicione uma descrição',
            maxLines: 3,
          ),
          const SizedBox(height: 32),
          _buildActionButtons(
            primaryLabel: _isMobile ? 'Próximo' : 'Salvar Dispositivo',
            onPrimaryPressed: _createDevice,
            showSecondary: false,
          ),
          if (!_isMobile) ...[
            const SizedBox(height: 16),
            _buildPlatformWarning(),
          ],
        ],
      ),
    );
  }

  Widget _buildDeviceTypeSelector() {
    return Container(
      decoration: BoxDecoration(
        color: kCardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kAccentColor.withOpacity(0.2)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.category_rounded, color: kAccentColor, size: 20),
              const SizedBox(width: 12),
              const Text(
                'Tipo de Dispositivo',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...DeviceTypes.all.map((type) => _buildTypeOption(type)),
        ],
      ),
    );
  }

  Widget _buildTypeOption(DeviceType type) {
    final isSelected = _selectedType?.id == type.id;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () => setState(() => _selectedType = type),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isSelected
                ? kAccentColor.withOpacity(0.2)
                : Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? kAccentColor : Colors.transparent,
              width: 2,
            ),
          ),
          child: Row(
            children: [
              Icon(
                isSelected
                    ? Icons.radio_button_checked
                    : Icons.radio_button_off,
                color: isSelected ? kAccentColor : Colors.white54,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      type.name,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.white70,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      type.description,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlatformWarning() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: Colors.orange),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'A ativação do dispositivo deve ser feita por meio de um dispositivo móvel no app.',
              style: TextStyle(color: Colors.orange.shade200, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  // ========== STEP 2: Bluetooth ==========
  Widget _buildBluetoothStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildSectionHeader(
            icon: Icons.bluetooth_rounded,
            title: 'Conexão Bluetooth',
            subtitle: 'Conecte-se ao ESP32',
          ),
          const SizedBox(height: 24),
          if (!_isConnected) ...[
            _buildBluetoothInstructions(),
            const SizedBox(height: 24),
            _buildActionButtons(
              primaryLabel: _isScanning
                  ? 'Procurando...'
                  : 'Procurar Dispositivos',
              onPrimaryPressed: _startBluetoothScan,
              secondaryLabel: 'Já Estou Conectado',
              onSecondaryPressed: _checkExistingConnection,
            ),
            if (_scanResults.isNotEmpty) ...[
              const SizedBox(height: 24),
              _buildDevicesList(),
            ],
          ] else ...[
            _buildConnectedDevice(),
            const SizedBox(height: 24),
            _buildActionButtons(
              primaryLabel: 'Próximo',
              onPrimaryPressed: () async {
                await _detectWiFiNetwork();
                _nextStep();
              },
              secondaryLabel: 'Desconectar',
              onSecondaryPressed: _disconnectBluetooth,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBluetoothInstructions() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: kCardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kAccentColor.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: kAccentColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.lightbulb_outline, color: kAccentColor),
              ),
              const SizedBox(width: 12),
              const Text(
                'Instruções',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInstructionItem('1', 'Ligue o dispositivo ESP32'),
          _buildInstructionItem(
            '2',
            'Aguarde o LED indicar modo de pareamento',
          ),
          _buildInstructionItem('3', 'Clique em "Procurar Dispositivos"'),
          _buildInstructionItem('4', 'Selecione o ESP32 da lista'),
        ],
      ),
    );
  }

  Widget _buildInstructionItem(String number, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [kAccentColor, kSecondaryAccent],
              ),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDevicesList() {
    return Container(
      decoration: BoxDecoration(
        color: kCardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(Icons.devices_rounded, color: kAccentColor),
                const SizedBox(width: 12),
                const Text(
                  'Dispositivos Encontrados',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const Divider(color: Colors.white24, height: 1),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _scanResults.length,
            separatorBuilder: (context, index) =>
                const Divider(color: Colors.white12, height: 1),
            itemBuilder: (context, index) {
              final result = _scanResults[index];
              final device = result.device;
              final name = device.platformName.isEmpty
                  ? 'Dispositivo Desconhecido'
                  : device.platformName;
              final rssi = result.rssi;

              return ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: kAccentColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.bluetooth_rounded,
                    color: kAccentColor,
                    size: 24,
                  ),
                ),
                title: Text(
                  name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                subtitle: Text(
                  'Sinal: $rssi dBm',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 12,
                  ),
                ),
                trailing: Icon(
                  Icons.arrow_forward_ios,
                  color: kAccentColor,
                  size: 16,
                ),
                onTap: () => _connectToDevice(device),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildConnectedDevice() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            kAccentColor.withOpacity(0.2),
            kSecondaryAccent.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kAccentColor.withOpacity(0.5)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: kAccentColor.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle,
              color: Colors.white,
              size: 48,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Conectado com Sucesso!',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _connectedDevice?.platformName ?? 'ESP32',
            style: TextStyle(color: kAccentColor, fontSize: 16),
          ),
        ],
      ),
    );
  }

  // ========== STEP 3: WiFi ==========
  Widget _buildWiFiStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildSectionHeader(
            icon: Icons.wifi_rounded,
            title: 'Configuração WiFi',
            subtitle: 'Configure a conexão do dispositivo',
          ),
          const SizedBox(height: 24),
          _buildTextField(
            controller: _ssidController,
            label: 'Rede WiFi (SSID)',
            icon: Icons.wifi_rounded,
            hint: 'Nome da rede',
            suffixIcon: IconButton(
              icon: Icon(Icons.refresh, color: kAccentColor),
              onPressed: _detectWiFiNetwork,
              tooltip: 'Detectar rede atual',
            ),
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _passwordController,
            label: 'Senha WiFi',
            icon: Icons.lock_rounded,
            hint: 'Digite a senha',
            obscureText: true,
          ),
          const SizedBox(height: 24),
          _buildWiFiInfo(),
          const SizedBox(height: 24),
          _buildActionButtons(
            primaryLabel: 'Enviar Configuração',
            onPrimaryPressed: _sendWiFiConfig,
            secondaryLabel: 'Voltar',
            onSecondaryPressed: _previousStep,
          ),
        ],
      ),
    );
  }

  Widget _buildWiFiInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kSecondaryAccent.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kSecondaryAccent.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: kSecondaryAccent, size: 24),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'As credenciais serão enviadas via Bluetooth para o ESP32. O dispositivo usará essas informações para conectar à rede WiFi.',
              style: TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  // ========== STEP 4: Activation ==========
  Widget _buildActivationStep() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    kAccentColor.withOpacity(0.3),
                    kSecondaryAccent.withOpacity(0.2),
                  ],
                ),
              ),
              child: const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                strokeWidth: 3,
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'Conectando à rede WiFi...',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'O ESP32 está tentando se conectar à rede ${_ssidController.text}',
              style: const TextStyle(color: Colors.white70, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: kCardColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Isso pode levar alguns segundos...',
                style: TextStyle(color: Colors.white60, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ========== STEP 5: Success ==========
  Widget _buildSuccessStep() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [kAccentColor, kSecondaryAccent],
                ),
              ),
              child: const Icon(
                Icons.check_rounded,
                color: Colors.white,
                size: 64,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              _isMobile ? 'Dispositivo Ativado!' : 'Dispositivo Cadastrado!',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              _isMobile
                  ? 'Seu ${_selectedType!.name} está conectado e pronto para uso!'
                  : 'Para ativar o dispositivo, use o aplicativo móvel.',
              style: const TextStyle(color: Colors.white70, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            if (_createdDevice != null) ...[
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: kCardColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    _buildInfoRow('Nome', _createdDevice!.name),
                    const Divider(color: Colors.white24),
                    _buildInfoRow('Tipo', _selectedType!.name),
                    if (_createdDevice!.description != null &&
                        _createdDevice!.description!.isNotEmpty) ...[
                      const Divider(color: Colors.white24),
                      _buildInfoRow('Descrição', _createdDevice!.description!),
                    ],
                  ],
                ),
              ),
            ],
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: kAccentColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Concluir',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.white60, fontSize: 14),
          ),
          Flexible(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  // ========== HELPER WIDGETS ==========
  Widget _buildSectionHeader({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [kAccentColor, kSecondaryAccent]),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.white, size: 32),
        ),
        const SizedBox(height: 16),
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: const TextStyle(color: Colors.white60, fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String hint,
    bool obscureText = false,
    int maxLines = 1,
    Widget? suffixIcon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: kCardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kAccentColor.withOpacity(0.2)),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        maxLines: maxLines,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
          hintText: hint,
          hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
          prefixIcon: Icon(icon, color: kAccentColor),
          suffixIcon: suffixIcon,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(20),
        ),
      ),
    );
  }

  Widget _buildActionButtons({
    required String primaryLabel,
    required VoidCallback? onPrimaryPressed,
    String? secondaryLabel,
    VoidCallback? onSecondaryPressed,
    bool showSecondary = true,
  }) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: _loading ? null : onPrimaryPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: kAccentColor,
              disabledBackgroundColor: kAccentColor.withOpacity(0.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: _loading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text(
                    primaryLabel,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
          ),
        ),
        if (showSecondary && secondaryLabel != null) ...[
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: OutlinedButton(
              onPressed: _loading ? null : onSecondaryPressed,
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: kAccentColor.withOpacity(0.5)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(
                secondaryLabel,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: kAccentColor,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  // ========== BUSINESS LOGIC ==========
  Future<void> _createDevice() async {
    if (_nameController.text.isEmpty) {
      _showError('Por favor, preencha o nome do dispositivo');
      return;
    }

    setState(() => _loading = true);

    try {
      final userStore = context.read<UserStore>();
      final response = await DeviceService.createDevice(
        name: _nameController.text,
        type: _selectedType!.id,
        description: _descriptionController.text,
        token: userStore.accessToken,
      );

      if (response['ok'] == true) {
        setState(() {
          _createdDevice = response['device'] as Device;
          _loading = false;
        });

        // Mobile: Continue to Bluetooth
        // Desktop: Jump to success
        if (_isMobile) {
          _nextStep();
        } else {
          setState(() => _currentStep = 4); // Jump to success
          _pageController.animateToPage(
            1, // Only 2 pages for desktop
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        }
      } else {
        throw Exception(response['message'] ?? 'Erro ao criar dispositivo');
      }
    } catch (e) {
      setState(() => _loading = false);
      _showError('Erro ao criar dispositivo: $e');
    }
  }

  Future<void> _startBluetoothScan() async {
    // Check if Bluetooth is available and turned on
    try {
      if (!await FlutterBluePlus.isAvailable) {
        _showError('Bluetooth não está disponível neste dispositivo');
        return;
      }

      if (!await FlutterBluePlus.isOn) {
        await _showBluetoothDialog();
        return;
      }
    } catch (e) {
      _showError('Erro ao verificar Bluetooth: $e');
      return;
    }

    // Request permissions
    final hasPermission = await _requestBluetoothPermissions();
    if (!hasPermission) {
      _showError('Permissões Bluetooth necessárias');
      return;
    }

    setState(() {
      _isScanning = true;
      _scanResults.clear();
    });

    try {
      // Start scanning
      await FlutterBluePlus.startScan(timeout: const Duration(seconds: 10));

      // Listen to scan results
      FlutterBluePlus.scanResults.listen((results) {
        setState(() {
          // Filter for ESP32 or GESYN devices
          _scanResults = results.where((r) {
            final name = r.device.platformName.toLowerCase();
            return name.contains('esp') || name.contains('gesyn');
          }).toList();
        });
      });

      // Stop scanning after timeout
      await Future.delayed(const Duration(seconds: 10));
      await FlutterBluePlus.stopScan();

      setState(() => _isScanning = false);

      if (_scanResults.isEmpty) {
        _showError('Nenhum dispositivo ESP32 encontrado');
      }
    } catch (e) {
      setState(() => _isScanning = false);
      _showError('Erro ao escanear: $e');
    }
  }

  Future<bool> _requestBluetoothPermissions() async {
    if (!_isMobile) return false;

    try {
      final statuses = await [
        Permission.bluetoothScan,
        Permission.bluetoothConnect,
        Permission.location,
      ].request();

      return statuses.values.every((status) => status.isGranted);
    } catch (e) {
      return false;
    }
  }

  Future<void> _checkExistingConnection() async {
    // Check if Bluetooth is available and turned on
    try {
      if (!await FlutterBluePlus.isAvailable) {
        _showError('Bluetooth não está disponível neste dispositivo');
        return;
      }

      if (!await FlutterBluePlus.isOn) {
        await _showBluetoothDialog();
        return;
      }
    } catch (e) {
      _showError('Erro ao verificar Bluetooth: $e');
      return;
    }

    setState(() => _loading = true);

    try {
      final connectedDevices = await FlutterBluePlus.connectedSystemDevices;

      // Find ESP32 or GESYN device
      final esp32 = connectedDevices.firstWhere((device) {
        final name = device.platformName.toLowerCase();
        return name.contains('esp') || name.contains('gesyn');
      }, orElse: () => throw Exception('Nenhum ESP32 conectado'));

      setState(() {
        _connectedDevice = esp32;
        _isConnected = true;
        _loading = false;
      });

      _showSuccess('Dispositivo conectado: ${esp32.platformName}');
    } catch (e) {
      setState(() => _loading = false);
      _showError('Nenhum dispositivo ESP32 conectado');
    }
  }

  Future<void> _connectToDevice(BluetoothDevice device) async {
    setState(() => _loading = true);

    try {
      await device.connect(timeout: const Duration(seconds: 10));

      setState(() {
        _connectedDevice = device;
        _isConnected = true;
        _loading = false;
      });

      _showSuccess('Conectado a ${device.platformName}');
    } catch (e) {
      setState(() => _loading = false);
      _showError('Erro ao conectar: $e');
    }
  }

  Future<void> _disconnectBluetooth() async {
    if (_connectedDevice != null) {
      try {
        await _connectedDevice!.disconnect();
        setState(() {
          _connectedDevice = null;
          _isConnected = false;
        });
        _showSuccess('Desconectado');
      } catch (e) {
        _showError('Erro ao desconectar: $e');
      }
    }
  }

  Future<void> _detectWiFiNetwork() async {
    if (!_isMobile) return;

    try {
      final networkInfo = NetworkInfo();
      final ssid = await networkInfo.getWifiName();

      if (ssid != null) {
        // Remove quotes from SSID (Android returns "SSID")
        final cleanSsid = ssid.replaceAll('"', '');
        setState(() {
          _ssidController.text = cleanSsid;
        });
        _showSuccess('Rede detectada: $cleanSsid');
      } else {
        _showError('Não foi possível detectar a rede WiFi');
      }
    } catch (e) {
      _showError('Erro ao detectar rede: $e');
    }
  }

  Future<void> _sendWiFiConfig() async {
    if (_ssidController.text.isEmpty) {
      _showError('Digite o nome da rede WiFi');
      return;
    }

    if (_passwordController.text.isEmpty) {
      _showError('Digite a senha WiFi');
      return;
    }

    if (_connectedDevice == null) {
      _showError('Nenhum dispositivo Bluetooth conectado');
      return;
    }

    setState(() => _loading = true);

    try {
      // Prepare JSON config
      final config = {
        'ssid': _ssidController.text,
        'password': _passwordController.text,
        'deviceId': _createdDevice?.deviceId ?? '',
        'apiToken': _createdDevice?.apiToken ?? '',
      };

      final jsonString = jsonEncode(config);

      // Send via Bluetooth
      await _sendDataViaBluetooth(jsonString);

      setState(() => _loading = false);

      // Go to activation step
      _nextStep();

      // Simulate activation (wait 5 seconds)
      await Future.delayed(const Duration(seconds: 5));

      // Go to success
      _nextStep();
    } catch (e) {
      setState(() => _loading = false);
      _showError('Erro ao enviar configuração: $e');
    }
  }

  Future<void> _sendDataViaBluetooth(String data) async {
    if (_connectedDevice == null) {
      throw Exception('Nenhum dispositivo conectado');
    }

    try {
      // Discover services
      final services = await _connectedDevice!.discoverServices();

      // Find writable characteristic
      BluetoothCharacteristic? targetCharacteristic;
      for (var service in services) {
        for (var characteristic in service.characteristics) {
          if (characteristic.properties.write) {
            targetCharacteristic = characteristic;
            break;
          }
        }
        if (targetCharacteristic != null) break;
      }

      if (targetCharacteristic == null) {
        throw Exception('Nenhuma característica gravável encontrada');
      }

      // Convert string to bytes
      final bytes = utf8.encode(data);

      // Write data
      await targetCharacteristic.write(bytes);
    } catch (e) {
      throw Exception('Erro ao enviar dados via Bluetooth: $e');
    }
  }

  void _nextStep() {
    if (_currentStep < 4) {
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

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _showBluetoothDialog() async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: kCardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.bluetooth_disabled, color: kAccentColor),
            const SizedBox(width: 12),
            const Text(
              'Bluetooth Desligado',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
        content: const Text(
          'Por favor, ative o Bluetooth nas configurações do dispositivo para escanear e conectar dispositivos ESP32.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: Colors.white54),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              // Try to open Bluetooth settings
              try {
                await openAppSettings();
              } catch (e) {
                _showError('Não foi possível abrir as configurações');
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: kAccentColor),
            child: const Text('Abrir Configurações'),
          ),
        ],
      ),
    );
  }
}
