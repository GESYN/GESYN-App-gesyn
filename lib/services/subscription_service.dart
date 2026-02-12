import 'dart:convert';
import 'package:http/http.dart' as http;
import '../services/api_service.dart';
import '../models/subscription.dart';

class SubscriptionService {
  // Lista todos os planos disponíveis (sem necessidade de autenticação)
  static Future<List<SubscriptionPlan>> getAvailablePlans() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiService.baseUrl}/api/v1/api/v1/subscriptions/plans'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        return data.map((json) => SubscriptionPlan.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // Retorna a assinatura atual do usuário (requer autenticação)
  static Future<Map<String, dynamic>> getCurrentSubscription(
    String token,
  ) async {
    try {
      final response = await ApiService.get(
        '/api/v1/api/v1/subscriptions/current',
        token: token,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'ok': true, 'data': CurrentSubscription.fromJson(data)};
      }
      return {'ok': false, 'status': response.statusCode};
    } catch (e) {
      return {'ok': false, 'error': e.toString()};
    }
  }

  // Cria uma sessão de checkout para novo plano
  static Future<Map<String, dynamic>> createCheckout({
    required String token,
    required String planType,
    required int duration,
    int installments = 1,
  }) async {
    try {
      final response = await ApiService.post(
        '/api/v1/api/v1/subscriptions/checkout',
        {
          'planType': planType,
          'duration': duration,
          'installments': installments,
        },
        token: token,
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'ok': true, 'data': CheckoutResponse.fromJson(data)};
      }
      return {'ok': false, 'status': response.statusCode};
    } catch (e) {
      return {'ok': false, 'error': e.toString()};
    }
  }

  // Faz upgrade de plano
  static Future<Map<String, dynamic>> upgradePlan({
    required String token,
    required String newPlanType,
    required int duration,
  }) async {
    try {
      final response = await ApiService.post(
        '/api/v1/api/v1/subscriptions/upgrade',
        {'newPlanType': newPlanType, 'duration': duration},
        token: token,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'ok': true, 'data': CheckoutResponse.fromJson(data)};
      }
      return {'ok': false, 'status': response.statusCode};
    } catch (e) {
      return {'ok': false, 'error': e.toString()};
    }
  }

  // Cancela a assinatura atual
  static Future<Map<String, dynamic>> cancelSubscription(String token) async {
    try {
      final response = await ApiService.post(
        '/api/v1/api/v1/subscriptions/cancel',
        {},
        token: token,
      );

      if (response.statusCode == 200) {
        return {'ok': true};
      }
      return {'ok': false, 'status': response.statusCode};
    } catch (e) {
      return {'ok': false, 'error': e.toString()};
    }
  }
}
