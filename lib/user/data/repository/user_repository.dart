import '../../domain/model/user.dart';
import '../local/session_dao.dart';
import '../local/session_entity.dart';
import '../remote/auth_service.dart';
import '../remote/user_dto.dart';

class UserRepository {
  final AuthService _remote;
  final SessionDao _sessions;

  UserRepository({AuthService? remote, SessionDao? sessions})
      : _remote = remote ?? AuthService(),
        _sessions = sessions ?? SessionDao();

  Future<void> register({
    required String name,
    required String lastname,
    required String email,
    required String password,
    String? role,
    String? image,
  }) async {
    final dto = UserDto(name: name, lastname: lastname, email: email, role: role, image: image);
    await _remote.signUp(dto, password);
  }

  Future<User> login({required String email, required String password}) async {
    final token = await _remote.login(email: email, password: password);
    final me = await _remote.me(token);
    final entity = SessionEntity(
      token: token,
      name: me.name,
      lastname: me.lastname,
      email: me.email,
      role: me.role,
      image: me.image,
      createdAt: DateTime.now().millisecondsSinceEpoch,
    );
    await _sessions.upsert(entity);
    return User(
      token: token,
      name: me.name,
      lastname: me.lastname,
      email: me.email,
      role: me.role,
      image: me.image,
    );
  }

  Future<User?> getCachedUser() async {
    final s = await _sessions.getLatest();
    if (s == null) return null;
    return User(
      token: s.token,
      name: s.name,
      lastname: s.lastname,
      email: s.email ?? '',
      role: s.role,
      image: s.image,
    );
  }

  Future<User> refreshMe() async {
    final s = await _sessions.getLatest();
    if (s == null) throw Exception('No session.');
    final me = await _remote.me(s.token);
    final entity = SessionEntity(
      id: s.id,
      token: s.token,
      name: me.name,
      lastname: me.lastname,
      email: me.email,
      role: me.role,
      image: me.image,
      createdAt: DateTime.now().millisecondsSinceEpoch,
    );
    await _sessions.upsert(entity);
    return User(
      token: s.token,
      name: me.name,
      lastname: me.lastname,
      email: me.email,
      role: me.role,
      image: me.image,
    );
  }

  Future<void> logout() => _sessions.clear();
}
