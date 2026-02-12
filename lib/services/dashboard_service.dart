import 'dart:convert';
import '../models/dashboard_data.dart';
import 'api_service.dart';

class DashboardService {
  static Future<DashboardData?> getDashboardData({
    String? token,
    String? deviceType,
    String? status,
    int? hours,
    List<String>? deviceIds,
  }) async {
    try {
      // Construir query parameters
      final queryParams = <String, String>{};
      if (deviceType != null) queryParams['deviceType'] = deviceType;
      if (status != null) queryParams['status'] = status;
      if (hours != null) queryParams['hours'] = hours.toString();
      if (deviceIds != null && deviceIds.isNotEmpty) {
        queryParams['deviceIds'] = deviceIds.join(',');
      }

      // Construir URL com query params
      String url = '/api/v1/devices/dashboard';
      if (queryParams.isNotEmpty) {
        final query = queryParams.entries
            .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
            .join('&');
        url += '?$query';
      }

      final response = await ApiService.get(url, token: token);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return DashboardData.fromJson(data);
      }

      return null;
    } catch (e) {
      print('❌ Erro ao buscar dados do dashboard: $e');
      return null;
    }
  }
}
