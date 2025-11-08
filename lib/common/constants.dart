class Constants {
  static const String baseUrl =
      'https://gigu-backend-webapp-hzbrd3guaghphmam.canadacentral-01.azurewebsites.net';
  static const String signUpEndpoint = '/api/v1/User/sign-up';
  static const String loginEndpoint = '/api/v1/User/login';
  static const String meEndpoint = '/api/v1/User/me';

  static const String dbName = 'user_auth.db';
  static const int dbVersion = 1;
  static const String sessionTable = 'sessions';
}
