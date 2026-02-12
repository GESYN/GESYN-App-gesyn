import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../stores/user_store.dart';
import '../widgets/app_drawer.dart';
import '../widgets/dashboard_filters.dart';
import '../widgets/dashboard_summary_card.dart';
import '../widgets/device_card.dart';
import '../models/dashboard_data.dart';
import '../services/dashboard_service.dart';
import '../services/api_exception.dart';
import '../routes.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final PageController _devicePageController = PageController();

  DashboardData? _dashboardData;
  bool _loading = true;
  String? _error;

  // Filtros
  String? _selectedDeviceType;
  String? _selectedStatus;
  int _selectedHours = 24;
  int _currentDeviceIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  @override
  void dispose() {
    _devicePageController.dispose();
    super.dispose();
  }

  Future<void> _loadDashboard() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final userStore = Provider.of<UserStore>(context, listen: false);

    try {
      final data = await DashboardService.getDashboardData(
        token: userStore.accessToken,
        deviceType: _selectedDeviceType,
        status: _selectedStatus,
        hours: _selectedHours,
      );

      setState(() {
        _loading = false;
        if (data != null) {
          _dashboardData = data;
        } else {
          _error = 'Erro ao carregar dados do dashboard';
        }
      });
    } on UnauthorizedException {
      // Token expirado - desloga o usuário
      if (mounted) {
        userStore.logout();
        Navigator.of(context).pushReplacementNamed(AuthRoute.login);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sessão expirada. Por favor, faça login novamente.'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _loading = false;
        _error = 'Erro ao carregar dados do dashboard';
      });
    }
  }

  void _clearFilters() {
    setState(() {
      _selectedDeviceType = null;
      _selectedStatus = null;
      _selectedHours = 24;
    });
    _loadDashboard();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFF0A0E27),
      appBar: AppBar(
        title: const Text(
          'Dashboard',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
        ),
        backgroundColor: const Color(0xFF0A0E27),
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Image.asset(
              'assets/img/logo.png',
              errorBuilder: (_, __, ___) =>
                  const Icon(Icons.dashboard_rounded, color: Colors.white),
            ),
          ),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        actions: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.refresh_rounded, size: 20),
            ),
            onPressed: _loadDashboard,
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF00D4FF), Color(0xFF0066FF)],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.person_rounded, size: 20),
            ),
            onPressed: () => Navigator.of(context).pushNamed(AuthRoute.profile),
          ),
          const SizedBox(width: 16),
        ],
      ),
      drawer: const AppDrawer(),
      body: _loading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Color(0xFF00D4FF),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Carregando dashboard...',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            )
          : _error != null
          ? _buildError()
          : _buildDashboard(),
    );
  }

  Widget _buildError() {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(32),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1F3A),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.red.withOpacity(0.3), width: 2),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: 64,
                color: Colors.red[300],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Ops! Algo deu errado',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _error!,
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withOpacity(0.6),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _loadDashboard,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Tentar novamente'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00D4FF),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
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

  Widget _buildDashboard() {
    if (_dashboardData == null || _dashboardData!.devices.isEmpty) {
      return Center(
        child: Container(
          margin: const EdgeInsets.all(32),
          padding: const EdgeInsets.all(40),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [const Color(0xFF1A1F3A), const Color(0xFF0A0E27)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(32),
            border: Border.all(color: Colors.white.withOpacity(0.1), width: 2),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF00D4FF), Color(0xFF0066FF)],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF00D4FF).withOpacity(0.3),
                      blurRadius: 30,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.devices_other_rounded,
                  size: 64,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'Nenhum dispositivo encontrado',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'Comece adicionando seus dispositivos IoT',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.6),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () =>
                    Navigator.of(context).pushNamed(AuthRoute.addDevice),
                icon: const Icon(Icons.add_rounded),
                label: const Text('Adicionar Dispositivo'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00D4FF),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 20,
                  ),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: 0,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadDashboard,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final screenWidth = MediaQuery.of(context).size.width;
            final horizontalPadding = screenWidth < 600 ? 12.0 : 16.0;

            return Padding(
              padding: EdgeInsets.all(horizontalPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Card de resumo
                  DashboardSummaryCard(summary: _dashboardData!.summary),

                  const SizedBox(height: 20),

                  // Filtros
                  DashboardFilters(
                    selectedDeviceType: _selectedDeviceType,
                    selectedStatus: _selectedStatus,
                    selectedHours: _selectedHours,
                    onDeviceTypeChanged: (value) {
                      setState(() => _selectedDeviceType = value);
                      _loadDashboard();
                    },
                    onStatusChanged: (value) {
                      setState(() => _selectedStatus = value);
                      _loadDashboard();
                    },
                    onHoursChanged: (value) {
                      setState(() => _selectedHours = value);
                      _loadDashboard();
                    },
                    onClearFilters: _clearFilters,
                  ),

                  const SizedBox(height: 24),

                  // Dispositivos
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF00D4FF), Color(0xFF0066FF)],
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.devices_rounded,
                              size: 20,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'Dispositivos',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      TextButton.icon(
                        onPressed: () =>
                            Navigator.of(context).pushNamed(AuthRoute.devices),
                        icon: const Icon(Icons.list_rounded, size: 18),
                        label: const Text('Ver todos'),
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFF00D4FF),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          backgroundColor: const Color(0xFF1A1F3A),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Carrossel de dispositivos
                  LayoutBuilder(
                    builder: (context, constraints) {
                      return SizedBox(
                        height: 2000,
                        child: PageView.builder(
                          controller: _devicePageController,
                          itemCount: _dashboardData!.devices.length,
                          onPageChanged: (index) {
                            setState(() => _currentDeviceIndex = index);
                          },
                          itemBuilder: (context, index) {
                            return DeviceCard(
                              device: _dashboardData!.devices[index],
                              onTap: () {
                                // TODO: Navegar para detalhes do dispositivo
                              },
                            );
                          },
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 20),

                  // Indicador de página
                  if (_dashboardData!.devices.length > 1)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        _dashboardData!.devices.length,
                        (index) => AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.symmetric(horizontal: 6),
                          width: _currentDeviceIndex == index ? 32 : 10,
                          height: 10,
                          decoration: BoxDecoration(
                            gradient: _currentDeviceIndex == index
                                ? const LinearGradient(
                                    colors: [
                                      Color(0xFF00D4FF),
                                      Color(0xFF0066FF),
                                    ],
                                  )
                                : null,
                            color: _currentDeviceIndex == index
                                ? null
                                : Colors.white.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(5),
                            boxShadow: _currentDeviceIndex == index
                                ? [
                                    BoxShadow(
                                      color: const Color(
                                        0xFF00D4FF,
                                      ).withOpacity(0.5),
                                      blurRadius: 10,
                                      spreadRadius: 2,
                                    ),
                                  ]
                                : null,
                          ),
                        ),
                      ),
                    ),

                  const SizedBox(height: 24),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
