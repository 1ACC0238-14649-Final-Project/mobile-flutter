import 'dart:convert';
import '../../domain/model/gig.dart';
import '../remote/gig_service.dart';
import '../remote/gig_dto.dart';
import '../../../user/data/repository/user_repository.dart';

class GigRepository {
  final GigService _remote;
  final UserRepository _userRepository;

  GigRepository({GigService? remote, UserRepository? userRepository})
      : _remote = remote ?? GigService(),
        _userRepository = userRepository ?? UserRepository();

  /// Extracts the userId from JWT token
  String? _getUserIdFromToken(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;

      // Decode the payload (second part of the JWT)
      final payload = parts[1];
     // Add padding if necessary for Base64URL
      var normalizedPayload = payload;
      final remainder = payload.length % 4;
      if (remainder > 0) {
        normalizedPayload = payload.padRight(payload.length + (4 - remainder), '=');
      }
      
      final decodedBytes = base64Url.decode(normalizedPayload);
      final decodedString = utf8.decode(decodedBytes);
      final jsonPayload = jsonDecode(decodedString) as Map<String, dynamic>;

      // Extract the sid (user ID) from the claim
      const sidClaim = 'http://schemas.xmlsoap.org/ws/2005/05/identity/claims/sid';
      if (jsonPayload.containsKey(sidClaim)) {
        return jsonPayload[sidClaim]?.toString();
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<Gig> createGig({
    required String title,
    required String description,
    String? category,
    String? image,
    List<String> tags = const [],
    double? price,
  }) async {
    // Get the current user's token
    final user = await _userRepository.getCachedUser();
    if (user == null) {
      throw Exception('No user session. Please login first.');
    }

    // Extract the sellerId from the JWT token
    final sellerId = _getUserIdFromToken(user.token);
    if (sellerId == null) {
      throw Exception('No se pudo obtener el ID del usuario desde el token. Por favor, inicia sesión nuevamente.');
    }

    final dto = GigDto(
      title: title,
      description: description,
      category: category,
      image: image,
      tags: tags,
      price: price,
      sellerId: sellerId,
    );

    final createdDto = await _remote.createGig(user.token, dto);

    return Gig(
      title: createdDto.title,
      description: createdDto.description,
      category: createdDto.category,
      image: createdDto.image,
      tags: createdDto.tags,
    );
  }

  Future<List<Gig>> getGigsBySeller(int sellerId) async {
    // Get the current user's token
    final user = await _userRepository.getCachedUser();
    if (user == null) {
      throw Exception('No user session. Please login first.');
    }

    final dtos = await _remote.getGigsBySeller(user.token, sellerId);

    return dtos.map((dto) => Gig(
          title: dto.title,
          description: dto.description,
          category: dto.category,
          image: dto.image,
          tags: dto.tags,
        )).toList();
  }

  Future<Gig> getGigById(String gigId) async {
    // Get the current user's token
    final user = await _userRepository.getCachedUser();
    if (user == null) {
      throw Exception('No user session. Please login first.');
    }

    final dto = await _remote.getGigById(user.token, gigId);

    return Gig(
      title: dto.title,
      description: dto.description,
      category: dto.category,
      image: dto.image,
      tags: dto.tags,
    );
  }
}

