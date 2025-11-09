import 'dart:convert';
import '../../domain/model/pull.dart';
import '../remote/pull_service.dart';
import '../remote/pull_dto.dart';
import '../../../user/data/repository/user_repository.dart';

class PullRepository {
  final PullService _remote;
  final UserRepository _userRepository;

  PullRepository({
    PullService? remote,
    UserRepository? userRepository,
  })  : _remote = remote ?? PullService(),
        _userRepository = userRepository ?? UserRepository();

  /// Extrae el userId del JWT token
  String? _getUserIdFromToken(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;

      // Decodificar el payload (segunda parte del JWT)
      final payload = parts[1];
      // Agregar padding si es necesario para Base64URL
      var normalizedPayload = payload;
      final remainder = payload.length % 4;
      if (remainder > 0) {
        normalizedPayload = payload.padRight(payload.length + (4 - remainder), '=');
      }

      final decodedBytes = base64Url.decode(normalizedPayload);
      final decodedString = utf8.decode(decodedBytes);
      final jsonPayload = jsonDecode(decodedString) as Map<String, dynamic>;

      // Extraer el sid (user ID) del claim
      const sidClaim = 'http://schemas.xmlsoap.org/ws/2005/05/identity/claims/sid';
      if (jsonPayload.containsKey(sidClaim)) {
        return jsonPayload[sidClaim]?.toString();
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<List<Pull>> getPullsBySellerId() async {
    try {
      // Obtener el token del usuario actual
      final user = await _userRepository.getCachedUser();
      if (user == null) {
        throw Exception('No user session. Please login first.');
      }

      // Extraer el sellerId del token JWT
      final sellerIdStr = _getUserIdFromToken(user.token);
      if (sellerIdStr == null) {
        throw Exception('No se pudo obtener el ID del usuario desde el token. Por favor, inicia sesión nuevamente.');
      }

      final sellerId = int.tryParse(sellerIdStr);
      if (sellerId == null) {
        throw Exception('ID de usuario inválido: $sellerIdStr');
      }

      print('🔍 Buscando pulls para sellerId: $sellerId con role: seller');
      final dtos = await _remote.getPullsByRole(user.token, 'seller', sellerId);
      print('✅ Pulls encontrados: ${dtos.length}');
      
      if (dtos.isEmpty) {
        print('⚠️ No se encontraron pulls para sellerId: $sellerId');
      } else {
        print('📋 Pulls: ${dtos.map((d) => 'ID=${d.id}, sellerId=${d.sellerId}, gigId=${d.gigId}').join(', ')}');
      }
      
      return dtos.map((dto) => dto.toDomain()).toList();
    } catch (e, stackTrace) {
      print('❌ Error en getPullsBySellerId: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }
}

