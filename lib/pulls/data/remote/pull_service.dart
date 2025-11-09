import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../common/constants.dart';
import 'pull_dto.dart';

class PullService {
  final http.Client _client;
  PullService({http.Client? client}) : _client = client ?? http.Client();

  Future<List<PullDto>> getPullsByRole(
    String token,
    String role,
    int userId,
  ) async {
    // Intentar primero con /api/Pull/by-role (sin v1, como en Android)
    final uri = Uri.parse('${Constants.baseUrl}/api/Pull/by-role')
        .replace(queryParameters: {
      'role': role,
      'userId': userId.toString(),
    });

    print('Llamando a: ${uri.toString()}');
    final res = await _client.get(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );
    
    print('Response status: ${res.statusCode}');
    print('Response body: ${res.body}');

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
      // Intentar con el endpoint con /v1
      final uri2 = Uri.parse('${Constants.baseUrl}/api/v1/Pull/by-role')
          .replace(queryParameters: {
        'role': role,
        'userId': userId.toString(),
      });
      
      print('Intentando con /v1: ${uri2.toString()}');
      final res2 = await _client.get(
        uri2,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );
      
      print('Response status (v1): ${res2.statusCode}');
      print('Response body (v1): ${res2.body}');
      
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

