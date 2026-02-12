import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:ui';
import '../stores/user_store.dart';
import '../widgets/app_drawer.dart';

const kBackgroundColor = Color(0xFF0A0E27);
const kCardColor = Color(0xFF1A1F3A);
const kAccentColor = Color(0xFF00D4FF);
const kSecondaryAccent = Color(0xFF7B2FFF);

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userStore = Provider.of<UserStore>(context);
    final user = userStore.user;

    return Scaffold(
      backgroundColor: kBackgroundColor,
      drawer: const AppDrawer(),
      body: user == null
          ? const Center(
              child: Text(
                'Usuário não encontrado',
                style: TextStyle(color: Colors.white70),
              ),
            )
          : CustomScrollView(
              slivers: [
                // AppBar com efeito parallax
                _buildSliverAppBar(context, user),

                // Conteúdo
                SliverList(
                  delegate: SliverChildListDelegate([
                    const SizedBox(height: 20),

                    // Cards de estatísticas
                    _buildStatsCards(context),

                    const SizedBox(height: 24),

                    // Informações pessoais
                    _buildSection(
                      context: context,
                      title: 'Informações Pessoais',
                      icon: Icons.person_rounded,
                      children: [
                        _buildInfoTile(
                          icon: Icons.badge_rounded,
                          label: 'Nome Completo',
                          value: '${user.firstName} ${user.lastName}',
                          gradient: true,
                        ),
                        _buildInfoTile(
                          icon: Icons.alternate_email_rounded,
                          label: 'Email',
                          value: user.email,
                        ),
                        _buildInfoTile(
                          icon: Icons.account_circle_rounded,
                          label: 'Username',
                          value: user.username,
                        ),
                        _buildInfoTile(
                          icon: Icons.shield_rounded,
                          label: 'Função',
                          value: _getRoleLabel(user.role),
                          valueColor: _getRoleColor(user.role),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Informações adicionais
                    _buildSection(
                      context: context,
                      title: 'Informações Adicionais',
                      icon: Icons.info_rounded,
                      children: [
                        _buildInfoTile(
                          icon: Icons.public_rounded,
                          label: 'Nacionalidade',
                          value: user.nationality.isEmpty
                              ? 'Não informado'
                              : user.nationality,
                        ),
                        _buildInfoTile(
                          icon: Icons.description_rounded,
                          label: 'Documento',
                          value: user.document.isEmpty
                              ? 'Não informado'
                              : user.document,
                        ),
                        _buildInfoTile(
                          icon: Icons.location_on_rounded,
                          label: 'Endereço',
                          value: user.address.isEmpty
                              ? 'Não informado'
                              : user.address,
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Botões de ação
                    _buildActionButtons(context, userStore),

                    const SizedBox(height: 40),
                  ]),
                ),
              ],
            ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context, dynamic user) {
    final initials = _getInitials(user.firstName, user.lastName);

    return SliverAppBar(
      expandedHeight: 320,
      floating: false,
      pinned: true,
      backgroundColor: kCardColor,
      iconTheme: const IconThemeData(color: Colors.white),
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          children: [
            // Background com gradiente
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [kCardColor, kBackgroundColor],
                ),
              ),
            ),

            // Efeitos decorativos
            Positioned(
              top: -50,
              right: -50,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [kAccentColor.withOpacity(0.2), Colors.transparent],
                  ),
                ),
              ),
            ),

            Positioned(
              bottom: -30,
              left: -30,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      kSecondaryAccent.withOpacity(0.15),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            // Conteúdo
            Positioned.fill(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 70),

                    // Avatar com efeito glow
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: kAccentColor.withOpacity(0.5),
                            blurRadius: 30,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [kAccentColor, kSecondaryAccent],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: kCardColor,
                          ),
                          child: Center(
                            child: Text(
                              initials,
                              style: TextStyle(
                                fontSize: 38,
                                fontWeight: FontWeight.bold,
                                foreground: Paint()
                                  ..shader =
                                      LinearGradient(
                                        colors: [
                                          kAccentColor,
                                          kSecondaryAccent,
                                        ],
                                      ).createShader(
                                        const Rect.fromLTWH(0, 0, 200, 70),
                                      ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 14),

                    // Nome
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width - 40,
                      ),
                      child: Text(
                        '${user.firstName} ${user.lastName}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),

                    const SizedBox(height: 4),

                    // Email
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width - 40,
                      ),
                      child: Text(
                        user.email,
                        style: TextStyle(
                          color: kAccentColor.withOpacity(0.8),
                          fontSize: 13,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),

                    const SizedBox(height: 10),

                    // Badge de role
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            _getRoleColor(user.role).withOpacity(0.3),
                            _getRoleColor(user.role).withOpacity(0.1),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: _getRoleColor(user.role).withOpacity(0.5),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _getRoleIcon(user.role),
                            size: 16,
                            color: _getRoleColor(user.role),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _getRoleLabel(user.role),
                            style: TextStyle(
                              color: _getRoleColor(user.role),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
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

  Widget _buildStatsCards(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              icon: Icons.devices_rounded,
              label: 'Dispositivos',
              value: '5',
              color: kAccentColor,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              icon: Icons.access_time_rounded,
              label: 'Último Acesso',
              value: 'Hoje',
              color: kSecondaryAccent,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [kCardColor.withOpacity(0.8), kCardColor.withOpacity(0.4)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(color: Colors.white54, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required BuildContext context,
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: kCardColor.withOpacity(0.5),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: kAccentColor.withOpacity(0.2), width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header da seção
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [kAccentColor, kSecondaryAccent],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: Colors.white, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            // Divider
            Container(
              height: 1,
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    kAccentColor.withOpacity(0.3),
                    Colors.transparent,
                  ],
                ),
              ),
            ),

            // Conteúdo
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(children: children),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String label,
    required String value,
    bool gradient = false,
    Color? valueColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: gradient
            ? kCardColor.withOpacity(0.5)
            : Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(12),
        border: gradient
            ? Border.all(color: kAccentColor.withOpacity(0.3), width: 1)
            : null,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: gradient
                  ? kAccentColor.withOpacity(0.2)
                  : Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: gradient ? kAccentColor : Colors.white54,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    color: valueColor ?? Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, UserStore userStore) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // Botão de editar perfil
          _buildActionButton(
            context: context,
            label: 'Editar Perfil',
            icon: Icons.edit_rounded,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Funcionalidade em desenvolvimento'),
                  backgroundColor: kAccentColor,
                ),
              );
            },
            gradient: true,
          ),

          const SizedBox(height: 12),

          // Botão de logout
          _buildActionButton(
            context: context,
            label: 'Sair da Conta',
            icon: Icons.logout_rounded,
            onTap: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  backgroundColor: kCardColor,
                  title: const Text(
                    'Confirmar Saída',
                    style: TextStyle(color: Colors.white),
                  ),
                  content: const Text(
                    'Deseja realmente sair da sua conta?',
                    style: TextStyle(color: Colors.white70),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text(
                        'Cancelar',
                        style: TextStyle(color: Colors.white54),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      child: const Text('Sair'),
                    ),
                  ],
                ),
              );

              if (confirm == true) {
                await userStore.logout();
                if (context.mounted) {
                  Navigator.of(context).pushReplacementNamed('/');
                }
              }
            },
            isLogout: true,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required BuildContext context,
    required String label,
    required IconData icon,
    required VoidCallback onTap,
    bool gradient = false,
    bool isLogout = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          decoration: BoxDecoration(
            gradient: gradient
                ? LinearGradient(
                    colors: [kAccentColor, kSecondaryAccent],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            color: isLogout
                ? Colors.red.withOpacity(0.1)
                : kCardColor.withOpacity(0.5),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: gradient
                  ? Colors.transparent
                  : isLogout
                  ? Colors.red.withOpacity(0.3)
                  : kAccentColor.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: gradient
                    ? Colors.white
                    : isLogout
                    ? Colors.red
                    : kAccentColor,
                size: 22,
              ),
              const SizedBox(width: 12),
              Text(
                label,
                style: TextStyle(
                  color: gradient
                      ? Colors.white
                      : isLogout
                      ? Colors.red
                      : Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getInitials(String firstName, String lastName) {
    final first = firstName.trim();
    final last = lastName.trim();
    String initials = '';
    if (first.isNotEmpty) initials += first[0].toUpperCase();
    if (last.isNotEmpty) initials += last[0].toUpperCase();
    return initials.isEmpty ? '?' : initials;
  }

  String _getRoleLabel(String role) {
    switch (role.toUpperCase()) {
      case 'ADMIN':
        return 'Administrador';
      case 'USER':
        return 'Usuário';
      default:
        return role;
    }
  }

  Color _getRoleColor(String role) {
    switch (role.toUpperCase()) {
      case 'ADMIN':
        return const Color(0xFFFF6B6B);
      case 'USER':
        return kAccentColor;
      default:
        return Colors.grey;
    }
  }

  IconData _getRoleIcon(String role) {
    switch (role.toUpperCase()) {
      case 'ADMIN':
        return Icons.admin_panel_settings_rounded;
      case 'USER':
        return Icons.person_rounded;
      default:
        return Icons.help_rounded;
    }
  }
}
