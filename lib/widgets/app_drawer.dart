import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../stores/user_store.dart';
import '../routes.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final userStore = Provider.of<UserStore>(context);
    final user = userStore.user;

    return Drawer(
      child: Container(
        color: const Color.fromARGB(255, 0, 0, 0),
        child: SafeArea(
          child: Column(
            children: [
              // Header com logo
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(color: Colors.grey[100]),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.transparent,
                      backgroundImage: AssetImage('assets/img/logo.png'),
                    ),
                    const SizedBox(width: 16),
                    const Text(
                      'GESYN',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // Informações do usuário (se logado)
              if (userStore.isAuthenticated) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 25,
                        backgroundColor: Colors.grey[300],
                        child: Text(
                          _initials(user?.firstName, user?.lastName),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
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
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              user?.email ?? '',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(),
              ],

              // Menu items
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    // Home
                    ListTile(
                      leading: const Icon(Icons.home_outlined),
                      title: const Text('Início'),
                      onTap: () {
                        Navigator.of(context).pop();
                        Navigator.of(
                          context,
                        ).pushReplacementNamed(AuthRoute.home);
                      },
                    ),

                    // Se usuário está logado
                    if (userStore.isAuthenticated) ...[
                      ListTile(
                        leading: const Icon(Icons.devices),
                        title: const Text('Meus Dispositivos'),
                        onTap: () {
                          Navigator.of(context).pop();
                          Navigator.of(context).pushNamed(AuthRoute.devices);
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.add_circle_outline),
                        title: const Text('Adicionar Dispositivo'),
                        onTap: () {
                          Navigator.of(context).pop();
                          Navigator.of(context).pushNamed(AuthRoute.addDevice);
                        },
                      ),
                      const Divider(),
                      ListTile(
                        leading: const Icon(Icons.person_outline),
                        title: const Text('Perfil'),
                        onTap: () {
                          Navigator.of(context).pop();
                          Navigator.of(context).pushNamed(AuthRoute.profile);
                        },
                      ),

                      // Admin (se for admin)
                      if (user?.role == 'ADMIN')
                        ListTile(
                          leading: const Icon(
                            Icons.admin_panel_settings_outlined,
                          ),
                          title: const Text('Administração'),
                          onTap: () {
                            Navigator.of(context).pop();
                            Navigator.of(context).pushNamed(AuthRoute.admin);
                          },
                        ),
                    ],

                    const Divider(),

                    // Botões de autenticação
                    if (!userStore.isAuthenticated) ...[
                      ListTile(
                        leading: const Icon(Icons.login),
                        title: const Text('Login'),
                        onTap: () {
                          Navigator.of(context).pop();
                          Navigator.of(context).pushNamed(AuthRoute.login);
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.person_add),
                        title: const Text('Registrar'),
                        onTap: () {
                          Navigator.of(context).pop();
                          Navigator.of(context).pushNamed(AuthRoute.register);
                        },
                      ),
                    ] else ...[
                      ListTile(
                        leading: const Icon(Icons.logout, color: Colors.red),
                        title: const Text(
                          'Sair',
                          style: TextStyle(color: Colors.red),
                        ),
                        onTap: () async {
                          Navigator.of(context).pop();
                          await userStore.logout();
                          Navigator.of(
                            context,
                          ).pushReplacementNamed(AuthRoute.home);
                        },
                      ),
                    ],
                  ],
                ),
              ),

              // Footer
              Container(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Versão 1.0.0',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ),
            ],
          ),
        ),
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
