import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../common/constants.dart';
import 'gig_dto.dart';

class GigService {
  final http.Client _client;
  GigService({http.Client? client}) : _client = client ?? http.Client();

  Future<GigDto> createGig(String token, GigDto dto) async {
    final uri = Uri.parse('${Constants.baseUrl}${Constants.createGigEndpoint}');
    final res = await _client.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(dto.toJson()),
    );
    if (res.statusCode == 201 || res.statusCode == 200) {
      final body = res.body.trim();
      if (body.startsWith('{')) {
        return GigDto.fromJson(jsonDecode(body));
      }
      throw Exception('Invalid response format from server.');
    }
    if (res.statusCode == 401) {
      throw Exception(jsonDecodeSafe(res.body) ?? 'Unauthorized.');
    }
    if (res.statusCode == 400) {
      throw Exception(jsonDecodeSafe(res.body) ?? 'Invalid request data.');
    }
    throw Exception('HTTP ${res.statusCode}: ${jsonDecodeSafe(res.body) ?? 'Failed to create gig.'}');
  }

  Future<List<GigDto>> getGigsBySeller(String token, int sellerId) async {
    final uri = Uri.parse('${Constants.baseUrl}${Constants.getGigsBySellerEndpoint}/$sellerId');
    final res = await _client.get(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (res.statusCode == 200) {
      final body = res.body.trim();
      final decoded = jsonDecode(body);

      if (decoded is List) {
        return decoded.map((e) => GigDto.fromJson(e)).toList();
      }

      if (decoded is Map<String, dynamic> && decoded['data'] is List) {
        final list = decoded['data'] as List;
        return list.map((e) => GigDto.fromJson(e)).toList();
      }

      return [];
    }

    if (res.statusCode == 401) {
      throw Exception('Unauthorized.');
    }
    if (res.statusCode == 404) {
      return [];
    }

    throw Exception(
        'HTTP ${res.statusCode}: ${jsonDecodeSafe(res.body) ?? 'Failed to fetch gigs.'}');
  }


  Future<GigDto> getGigById(String token, String gigId) async {
    final uri = Uri.parse('${Constants.baseUrl}${Constants.createGigEndpoint}/$gigId');
    final res = await _client.get(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );
    if (res.statusCode == 200) {
      final body = res.body.trim();
      if (body.startsWith('{')) {
        return GigDto.fromJson(jsonDecode(body));
      }
      throw Exception('Invalid response format from server.');
    }
    if (res.statusCode == 401) {
      throw Exception('Unauthorized.');
    }
    if (res.statusCode == 404) {
      throw Exception('Gig not found.');
    }
    throw Exception('HTTP ${res.statusCode}: ${jsonDecodeSafe(res.body) ?? 'Failed to fetch gig.'}');
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

