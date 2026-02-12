import 'dart:convert';
import 'dart:math';
import '../models/device.dart';
import './api_service.dart';

class DeviceService {
  /// Gera um ID único para o dispositivo
  static String generateDeviceId(String type) {
    final random = Random();
    final numbers = List.generate(6, (_) => random.nextInt(10)).join();
    return '$type-$numbers';
  }

  /// Cria um novo dispositivo
  static Future<Map<String, dynamic>> createDevice({
    required String name,
    required String type,
    required String description,
    String? token,
  }) async {
    final deviceId = generateDeviceId(type);

    final body = {
      'name': name,
      'deviceId': deviceId,
      'type': type,
      'description': description,
      'firmwareVersion': '1.0.0',
    };

    final response = await ApiService.post(
      '/api/v1/devices',
      body,
      token: token,
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return {'ok': true, 'device': Device.fromJson(data)};
    } else {
      try {
        final error = jsonDecode(response.body);
        return {
          'ok': false,
          'status': response.statusCode,
          'error': error['message'] ?? 'Erro ao criar dispositivo',
        };
      } catch (e) {
        return {
          'ok': false,
          'status': response.statusCode,
          'error': 'Erro ao criar dispositivo',
        };
      }
    }
  }

  /// Lista todos os dispositivos do usuário
  static Future<List<Device>> getDevices({String? token}) async {
    try {
      final response = await ApiService.get('/api/v1/devices', token: token);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Device.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Error fetching devices: $e');
      return [];
    }
  }

  /// Busca um dispositivo específico por ID
  static Future<Device?> getDeviceById(String id, {String? token}) async {
    try {
      final response = await ApiService.get(
        '/api/v1/devices/$id',
        token: token,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Device.fromJson(data);
      }
      return null;
    } catch (e) {
      print('Error fetching device: $e');
      return null;
    }
  }

  /// Atualiza um dispositivo
  static Future<Map<String, dynamic>> updateDevice({
    required String id,
    String? name,
    String? type,
    String? status,
    String? description,
    String? firmwareVersion,
    String? token,
  }) async {
    final body = <String, dynamic>{};
    if (name != null) body['name'] = name;
    if (type != null) body['type'] = type;
    if (status != null) body['status'] = status;
    if (description != null) body['description'] = description;
    if (firmwareVersion != null) body['firmwareVersion'] = firmwareVersion;

    final response = await ApiService.patch(
      '/api/v1/devices/$id',
      body,
      token: token,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return {'ok': true, 'device': Device.fromJson(data)};
    } else {
      try {
        final error = jsonDecode(response.body);
        return {
          'ok': false,
          'status': response.statusCode,
          'error': error['message'] ?? 'Erro ao atualizar dispositivo',
        };
      } catch (e) {
        return {
          'ok': false,
          'status': response.statusCode,
          'error': 'Erro ao atualizar dispositivo',
        };
      }
    }
  }

  /// Ativa um dispositivo após configuração via Bluetooth
  static Future<Map<String, dynamic>> activateDevice({
    required String id,
    required String token,
  }) async {
    return updateDevice(id: id, status: 'ONLINE', token: token);
  }

  /// Deleta um dispositivo
  static Future<Map<String, dynamic>> deleteDevice({
    required String id,
    String? token,
  }) async {
    final response = await ApiService.delete(
      '/api/v1/devices/$id',
      token: token,
    );

    if (response.statusCode == 200 || response.statusCode == 204) {
      return {'ok': true};
    } else {
      try {
        final error = jsonDecode(response.body);
        return {
          'ok': false,
          'status': response.statusCode,
          'error': error['message'] ?? 'Erro ao deletar dispositivo',
        };
      } catch (e) {
        return {
          'ok': false,
          'status': response.statusCode,
          'error': 'Erro ao deletar dispositivo',
        };
      }
    }
  }
}
