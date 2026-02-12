// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import '../models/subscription.dart';

class PlanCard extends StatelessWidget {
  final SubscriptionPlan plan;
  final VoidCallback onTap;
  final bool isRecommended;
  final int planIndex;

  const PlanCard({
    super.key,
    required this.plan,
    required this.onTap,
    this.isRecommended = false,
    this.planIndex = 0,
  });

  // Cores metálicas brilhantes suaves em sequência
  Color _getMetallicColor() {
    final colors = [
      const Color(0xFF98E4C8), // Verde metálico suave
      const Color(0xFF9DD9EA), // Azul metálico suave
      const Color(0xFFCAB4E8), // Roxo metálico suave
      const Color(0xFF7BA3D9), // Azul escuro metálico suave
      const Color(0xFFA68CC9), // Roxo escuro metálico suave
    ];
    return colors[planIndex % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    final metallicColor = _getMetallicColor();

    return Container(
      width: 200,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            metallicColor.withOpacity(0.3),
            Colors.white,
            metallicColor.withOpacity(0.2),
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: metallicColor.withOpacity(0.4), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: metallicColor.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 4),
            spreadRadius: 1,
          ),
          BoxShadow(
            color: Colors.white.withOpacity(0.8),
            blurRadius: 8,
            offset: const Offset(-2, -2),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  plan.displayName.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 18,
                    fontFamily: 'Roboto', // Substitua pelo nome da fonte desejada
                    fontWeight: FontWeight.w900,
                    color: Color.fromARGB(221, 38, 38, 38)
                  ),
                ),
                const SizedBox(height: 8),
                ...plan.features
                    .take(4)
                    .map(
                      (feature) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(
                          feature,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[700],
                          ),
                        ),
                      ),
                    ),
              ],
            ),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Custo por mês',
                  style: TextStyle(fontSize: 11, color: Colors.grey),
                ),
                const SizedBox(height: 4),
                Text(
                  plan.price == 0
                      ? 'GRÁTIS'
                      : 'R\$${plan.price.toStringAsFixed(2).replaceAll('.', ',')}',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: plan.price == 0 ? Colors.green : Colors.black,
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: onTap,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Adquirir'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
