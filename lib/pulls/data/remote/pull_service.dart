import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../common/constants.dart';
import 'pull_dto.dart';
import 'dart:developer' as developer;

class PullService {
  final http.Client _client;
  PullService({http.Client? client}) : _client = client ?? http.Client();

  Future<List<PullDto>> getPullsByRole(
      String token,
      String role,
      int userId,
      ) async {
    final uri = Uri.parse('${Constants.baseUrl}/api/Pull/by-role')
        .replace(queryParameters: {
      'role': role,
      'userId': userId.toString(),
    });

    developer.log('Llamando a: ${uri.toString()}', name: 'PullService');

    final res = await _client.get(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    developer.log('Response status: ${res.statusCode}', name: 'PullService');
    developer.log('Response body: ${res.body}', name: 'PullService');

    if (res.statusCode == 200) {
      final body = res.body.trim();
      List<dynamic> itemsList;

      if (body.startsWith('[')) {
        itemsList = jsonDecode(body) as List;
      } else if (body.startsWith('{')) {
        final obj = jsonDecode(body) as Map<String, dynamic>;
        if (obj.containsKey('data')) {
          itemsList = obj['data'] as List;
        } else if (obj.containsKey('items')) {
          itemsList = obj['items'] as List;
        } else if (obj.containsKey('results')) {
          itemsList = obj['results'] as List;
        } else {
          itemsList = [];
        }
      } else {
        itemsList = [];
      }

      return itemsList.map((e) => PullDto.fromJson(e as Map<String, dynamic>)).toList();
    }

    if (res.statusCode == 401) {
      throw Exception('Unauthorized.');
    }

    if (res.statusCode == 404) {
      final uri2 = Uri.parse('${Constants.baseUrl}/api/v1/Pull/by-role')
          .replace(queryParameters: {
        'role': role,
        'userId': userId.toString(),
      });

      developer.log('Intentando con /v1: ${uri2.toString()}', name: 'PullService');

      final res2 = await _client.get(
        uri2,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      developer.log('Response status (v1): ${res2.statusCode}', name: 'PullService');
      developer.log('Response body (v1): ${res2.body}', name: 'PullService');

      if (res2.statusCode == 200) {
        final body2 = res2.body.trim();
        List<dynamic> itemsList2;

        if (body2.startsWith('[')) {
          itemsList2 = jsonDecode(body2) as List;
        } else if (body2.startsWith('{')) {
          final obj = jsonDecode(body2) as Map<String, dynamic>;
          if (obj.containsKey('data')) {
            itemsList2 = obj['data'] as List;
          } else if (obj.containsKey('items')) {
            itemsList2 = obj['items'] as List;
          } else if (obj.containsKey('results')) {
            itemsList2 = obj['results'] as List;
          } else {
            itemsList2 = [];
          }
        } else {
          itemsList2 = [];
        }

        return itemsList2.map((e) => PullDto.fromJson(e as Map<String, dynamic>)).toList();
      }
      return [];
    }

    throw Exception('HTTP ${res.statusCode}: ${jsonDecodeSafe(res.body) ?? 'Failed to fetch pulls.'}');
  }

  /// Actualizar el precio de un pull
  Future<PullDto> updatePullPrice(String token, int pullId, double newPrice) async {
    final uri = Uri.parse('${Constants.baseUrl}/api/Pull/$pullId');

    final body = {
      'NewPrice': newPrice,
    };

    developer.log('Actualizando precio del pull $pullId a \$$newPrice', name: 'PullService');
    developer.log('URL: ${uri.toString()}', name: 'PullService');
    developer.log('Body: ${jsonEncode(body)}', name: 'PullService');

    final res = await _client.put(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode(body),
    );

    developer.log('Response status: ${res.statusCode}', name: 'PullService');
    developer.log('Response body: ${res.body}', name: 'PullService');

    if (res.statusCode == 200) {
      final json = jsonDecode(res.body) as Map<String, dynamic>;
      return PullDto.fromJson(json);
    }

    if (res.statusCode == 204) {
      throw Exception('Precio actualizado pero el servidor no retornó datos');
    }

    if (res.statusCode == 401) {
      throw Exception('No autorizado.');
    }

    throw Exception('Error al actualizar precio: HTTP ${res.statusCode} - ${jsonDecodeSafe(res.body)}');
  }

  /// Actualizar el estado de un pull
  Future<PullDto> updatePullState(String token, int pullId, String newState) async {
    final uri = Uri.parse('${Constants.baseUrl}/api/Pull/$pullId');

    final body = {
      'NewState': newState,
    };

    developer.log('Actualizando estado del pull $pullId a $newState', name: 'PullService');
    developer.log('URL: ${uri.toString()}', name: 'PullService');
    developer.log('Body: ${jsonEncode(body)}', name: 'PullService');

    final res = await _client.put(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode(body),
    );

    developer.log('Response status: ${res.statusCode}', name: 'PullService');
    developer.log('Response body: ${res.body}', name: 'PullService');

    if (res.statusCode == 200) {
      final json = jsonDecode(res.body) as Map<String, dynamic>;
      return PullDto.fromJson(json);
    }

    if (res.statusCode == 204) {
      throw Exception('Estado actualizado pero el servidor no retornó datos');
    }

    if (res.statusCode == 401) {
      throw Exception('No autorizado.');
    }

    throw Exception('Error al actualizar estado: HTTP ${res.statusCode} - ${jsonDecodeSafe(res.body)}');
  }

  String? jsonDecodeSafe(String? body) {
    if (body == null) return null;
    final t = body.trim();
    if (t.isEmpty) return null;
    try {
      final v = jsonDecode(t);
      if (v is Map && v['message'] is String) return v['message'] as String;
      if (v is String) return v;
      return t;
    } catch (_) {
      return t;
    }
  }
}