import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/widgets.dart';
import 'stores/user_store.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/home_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/admin_screen.dart';
import 'screens/add_device_flow_screen.dart';
import 'screens/devices_screen.dart';
import 'screens/device_details_screen.dart';

class AuthRoute {
  static const home = '/';
  static const dashboard = '/dashboard';
  static const login = '/login';
  static const register = '/register';
  static const profile = '/profile';
  static const admin = '/admin';
  static const addDevice = '/add-device';
  static const devices = '/devices';
  static const deviceDetails = '/device-details';
}

class RouteGenerator {
  static Route<dynamic> generate(RouteSettings settings) {
    return MaterialPageRoute(
      builder: (context) {
        final userStore = Provider.of<UserStore>(context);
        switch (settings.name) {
          case AuthRoute.login:
            return LoginScreen();
          case AuthRoute.register:
            return RegisterScreen();
          case AuthRoute.dashboard:
            if (!userStore.isAuthenticated) return LoginScreen();
            return const DashboardScreen();
          case AuthRoute.profile:
            if (!userStore.isAuthenticated) return LoginScreen();
            return ProfileScreen();
          case AuthRoute.addDevice:
            if (!userStore.isAuthenticated) return LoginScreen();
            return const AddDeviceFlowScreen();
          case AuthRoute.devices:
            if (!userStore.isAuthenticated) return LoginScreen();
            return const DevicesScreen();
          case AuthRoute.deviceDetails:
            if (!userStore.isAuthenticated) return LoginScreen();
            final deviceId = settings.arguments as String?;
            if (deviceId == null) return const DashboardScreen();
            return DeviceDetailsScreen(deviceId: deviceId);
          case AuthRoute.admin:
            if (!userStore.isAuthenticated) return LoginScreen();
            final role = userStore.user?.role ?? 'USER';
            if (role != 'ADMIN') return const DashboardScreen();
            return AdminScreen();
          case AuthRoute.home:
          default:
            // Se usuário está logado, vai para o dashboard
            if (userStore.isAuthenticated) {
              return const DashboardScreen();
            }
            // Se não está logado, vai para a home pública
            return const HomeScreen();
        }
      },
    );
  }
}
