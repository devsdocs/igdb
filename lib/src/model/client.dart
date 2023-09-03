part of '../igdb_base.dart';

class IGDBClient {
  IGDBClient({
    required this.clientId,
    required this.clientSecret,
  });
  final String clientId;
  final String clientSecret;

  final _tokenEndpoint = ' id.twitch.tv';
  static const _apiBase = 'api.igdb.com';

  final http = NetworkTools.client;

  String? _bearerToken;
  DateTime? _tokenExpiry;

  Uri _apiUri({
    String authority = _apiBase,
    String path = '/v4',
    Map<String, dynamic>? queryParameters,
  }) {
    return Uri.https(authority, path,
        queryParameters?..removeWhere((key, value) => value == null));
  }

  Future<void> _getBearerToken() async {
    if (_bearerToken == null) {
      final uri = _apiUri(
          authority: _tokenEndpoint,
          path: '/oauth2/token',
          queryParameters: {
            'client_id': clientId,
            'client_secret': clientSecret,
            'grant_type': 'client_credentials'
          });
      final fetch = await http.postUri(uri);
      final mapper = fetch?.toJsonObject;
      print(mapper);
    }
  }
}
