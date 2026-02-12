import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:ui';
import '../stores/user_store.dart';
import '../routes.dart';

const kBackgroundColor = Color(0xFF0A0E27);
const kCardColor = Color(0xFF1A1F3A);
const kAccentColor = Color(0xFF00D4FF);
const kSecondaryAccent = Color(0xFF7B2FFF);

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final userStore = Provider.of<UserStore>(context);
    final user = userStore.user;

    return Drawer(
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              kBackgroundColor,
              kBackgroundColor.withOpacity(0.95),
              kCardColor.withOpacity(0.9),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header futurista com logo e efeito glow
              _buildHeader(context),

              const SizedBox(height: 16),

              // Informações do usuário com glassmorphism
              if (userStore.isAuthenticated) ...[
                _buildUserInfo(context, user),
                const SizedBox(height: 16),
              ],

              // Menu items com animações
              Expanded(child: _buildMenuItems(context, userStore, user)),

              // Footer com versão
              _buildFooter(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            kAccentColor.withOpacity(0.2),
            kSecondaryAccent.withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: kAccentColor.withOpacity(0.3), width: 1),
        boxShadow: [
          BoxShadow(
            color: kAccentColor.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          // Logo com efeito glow
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [kAccentColor, kSecondaryAccent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: kAccentColor.withOpacity(0.5),
                  blurRadius: 15,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: const CircleAvatar(
              radius: 28,
              backgroundColor: Colors.transparent,
              backgroundImage: AssetImage('assets/img/logo.png'),
            ),
          ),
          const SizedBox(width: 16),
          // Nome com efeito futurista
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ShaderMask(
                shaderCallback: (bounds) => LinearGradient(
                  colors: [kAccentColor, kSecondaryAccent],
                ).createShader(bounds),
                child: const Text(
                  'GESYN',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 3,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Smart Monitoring',
                style: TextStyle(
                  fontSize: 11,
                  letterSpacing: 2,
                  color: kAccentColor.withOpacity(0.7),
                  fontWeight: FontWeight.w300,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUserInfo(BuildContext context, dynamic user) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: kCardColor.withOpacity(0.5),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: kAccentColor.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                // Avatar com gradiente
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [kAccentColor, kSecondaryAccent],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: kAccentColor.withOpacity(0.4),
                        blurRadius: 10,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(2),
                  child: CircleAvatar(
                    radius: 28,
                    backgroundColor: kCardColor,
                    child: Text(
                      _initials(user?.firstName, user?.lastName),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: kAccentColor,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${user?.firstName ?? ''} ${user?.lastName ?? ''}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user?.email ?? '',
                        style: TextStyle(
                          fontSize: 12,
                          color: kAccentColor.withOpacity(0.7),
                        ),
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

  Widget _buildMenuItems(
    BuildContext context,
    UserStore userStore,
    dynamic user,
  ) {
    // Obter a rota atual
    final currentRoute = ModalRoute.of(context)?.settings.name;

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      children: [
        // Home
        _buildMenuItem(
          context: context,
          icon: Icons.home_rounded,
          label: 'Início',
          isActive: currentRoute == AuthRoute.home,
          onTap: () {
            Navigator.of(context).pop();
            Navigator.of(context).pushReplacementNamed(AuthRoute.home);
          },
        ),

        // Se usuário está logado
        if (userStore.isAuthenticated) ...[
          const SizedBox(height: 8),
          _buildMenuItem(
            context: context,
            icon: Icons.devices_rounded,
            label: 'Meus Dispositivos',
            isActive: currentRoute == AuthRoute.devices,
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushNamed(AuthRoute.devices);
            },
          ),
          const SizedBox(height: 8),
          _buildMenuItem(
            context: context,
            icon: Icons.add_circle_rounded,
            label: 'Adicionar Dispositivo',
            isActive: currentRoute == AuthRoute.addDevice,
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushNamed(AuthRoute.addDevice);
            },
          ),

          const SizedBox(height: 16),
          _buildDivider(),
          const SizedBox(height: 16),

          _buildMenuItem(
            context: context,
            icon: Icons.person_rounded,
            label: 'Perfil',
            isActive: currentRoute == AuthRoute.profile,
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushNamed(AuthRoute.profile);
            },
          ),

          // Admin (se for admin)
          if (user?.role == 'ADMIN') ...[
            const SizedBox(height: 8),
            _buildMenuItem(
              context: context,
              icon: Icons.admin_panel_settings_rounded,
              label: 'Administração',
              isActive: currentRoute == AuthRoute.admin,
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).pushNamed(AuthRoute.admin);
              },
            ),
          ],
        ],

        const SizedBox(height: 16),
        _buildDivider(),
        const SizedBox(height: 16),

        // Botões de autenticação
        if (!userStore.isAuthenticated) ...[
          _buildMenuItem(
            context: context,
            icon: Icons.login_rounded,
            label: 'Login',
            isActive: currentRoute == AuthRoute.login,
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushNamed(AuthRoute.login);
            },
          ),
          const SizedBox(height: 8),
          _buildMenuItem(
            context: context,
            icon: Icons.person_add_rounded,
            label: 'Registrar',
            isActive: currentRoute == AuthRoute.register,
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushNamed(AuthRoute.register);
            },
          ),
        ] else ...[
          _buildMenuItem(
            context: context,
            icon: Icons.logout_rounded,
            label: 'Sair',
            isLogout: true,
            onTap: () async {
              Navigator.of(context).pop();
              await userStore.logout();
              Navigator.of(context).pushReplacementNamed(AuthRoute.home);
            },
          ),
        ],
      ],
    );
  }

  Widget _buildMenuItem({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isActive = false,
    bool isLogout = false,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: isActive
                  ? kCardColor.withOpacity(0.5)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: isActive
                  ? Border.all(color: kAccentColor.withOpacity(0.3), width: 1)
                  : null,
              gradient: isActive
                  ? LinearGradient(
                      colors: [
                        kAccentColor.withOpacity(0.1),
                        kSecondaryAccent.withOpacity(0.05),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : null,
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isLogout
                        ? Colors.red.withOpacity(0.1)
                        : isActive
                        ? kAccentColor.withOpacity(0.2)
                        : Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: isLogout
                        ? Colors.red
                        : isActive
                        ? kAccentColor
                        : Colors.white70,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                      color: isLogout
                          ? Colors.red
                          : isActive
                          ? Colors.white
                          : Colors.white70,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                if (isActive)
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 14,
                    color: kAccentColor.withOpacity(0.5),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      height: 1,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.transparent,
            kAccentColor.withOpacity(0.3),
            Colors.transparent,
          ],
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: kCardColor.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kAccentColor.withOpacity(0.1), width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.info_outline_rounded,
            size: 14,
            color: kAccentColor.withOpacity(0.6),
          ),
          const SizedBox(width: 8),
          Text(
            'Versão 1.0.0',
            style: TextStyle(
              fontSize: 12,
              color: kAccentColor.withOpacity(0.6),
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }

  String _initials(String? first, String? last) {
    final a = (first ?? '').trim();
    final b = (last ?? '').trim();
    String i = '';
    if (a.isNotEmpty) i += a[0].toUpperCase();
    if (b.isNotEmpty) i += b[0].toUpperCase();
    return i.isEmpty ? '?' : i;
  }
}
