import 'package:flutter/material.dart';
import '../widgets/app_drawer.dart';

class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Admin')),
      drawer: const AppDrawer(),
      body: Center(child: Text('Admin area - only for ADMIN role')),
    );
  }
}
