part of 'igdb_base.dart';

class IGDBClient {
  IGDBClient(
    this._clientId,
    this._clientSecret, {
    this.useIsolateForRequest = false,
  });
  final String _clientId;
  final String _clientSecret;

  final _tokenEndpoint = 'id.twitch.tv';

  final _http = NetworkTools.client;

  String? _bearerToken;
  DateTime? _tokenExpiryDateTime;

  bool useIsolateForRequest;

  Uri _apiUri(
    String unencodedPath, {
    String authority = 'api.igdb.com',
    String pathPrefix = '/v4/',
    Map<String, dynamic>? queryParameters,
  }) {
    return Uri.https(
      authority,
      '$pathPrefix$unencodedPath',
      queryParameters?..removeWhere((_, v) => v == null),
    );
  }

  Future<bool> _checkBearerToken([bool refresh = false]) async {
    if (_bearerToken != null && _tokenExpiryDateTime != null && !refresh) {
      final isExpired = DateTime.now().isAfter(_tokenExpiryDateTime!);
      if (!isExpired) {
        return true;
      } else {
        return _checkBearerToken(true);
      }
    } else {
      final fetch = await _fetchBearerToken();
      if (fetch == null) return false;
      _bearerToken = fetch['access_token'] as String;
      final secToExpire = fetch['expires_in'] as int;
      _tokenExpiryDateTime = DateTime.now().add(Duration(seconds: secToExpire));
      return true;
    }
  }

  Future<Map<String, dynamic>?> _fetchBearerToken() async {
    final uri = _apiUri(
      'token',
      authority: _tokenEndpoint,
      pathPrefix: '/oauth2/',
      queryParameters: {
        'client_id': _clientId,
        'client_secret': _clientSecret,
        'grant_type': 'client_credentials',
      },
    );
    final data = await _http.postUri(uri);
    return data as Map<String, dynamic>;
  }

  Future<dynamic> _rawRequest(
    String path,
    String body, {
    required bool isProto,
  }) async {
    final uri = _apiUri(path);

    final headers = {
      'Client-ID': _clientId,
      HttpHeaders.authorizationHeader: 'Bearer $_bearerToken',
      HttpHeaders.contentTypeHeader: Headers.formUrlEncodedContentType,
    };

    final options = NetworkTools.client.options
      ..headers = headers
      ..responseType = isProto ? ResponseType.bytes : ResponseType.json;

    final post = await _http.postUri(
      uri,
      options: options,
      nonMultipartFormData: body,
      useIsolate: useIsolateForRequest,
    );
    return post;
  }

  Future<dynamic> _makeJsonRequest(
    String path,
    String body,
  ) async {
    final isTokenValid = await _checkBearerToken();
    if (isTokenValid) {
      final post = await _rawRequest(path, body, isProto: false);

      return post;
    } else {
      return _makeJsonRequest(path, body);
    }
  }

  Future<Uint8List?> _makeProtoRequest(String path, String body) async {
    final isTokenValid = await _checkBearerToken();
    if (isTokenValid) {
      final post = await _rawRequest(path, body, isProto: true);

      return post as Uint8List?;
    } else {
      return _makeProtoRequest(path, body);
    }
  }

  Future<Uint8List?> _makeCountProtoRequestByEndpoint(
    IGDBEndpoints endpoints,
    IGDBRequestParameters params,
  ) async =>
      _makeProtoRequest('$endpoints/count.pb', '$params');

  Future<Uint8List?> _makeProtoRequestByEndpoint(
    IGDBEndpoints endpoints,
    IGDBRequestParameters params,
  ) async =>
      _makeProtoRequest('$endpoints.pb', '$params');

  Future<dynamic> _makeCountJsonRequestByEndpoint(
    IGDBEndpoints endpoints,
    IGDBRequestParameters params,
  ) async =>
      _makeJsonRequest('$endpoints/count', '$params');

  Future<dynamic> _makeJsonRequestByEndpoint(
    IGDBEndpoints endpoints,
    IGDBRequestParameters params,
  ) async =>
      _makeJsonRequest('$endpoints', '$params');

  Future<AgeRating?> ageRatingProto(IGDBRequestParameters params) async {
    const endpoint = IGDBEndpoints.ageRatings;
    final fetch = await _makeProtoRequestByEndpoint(endpoint, params);
    if (fetch != null) {
      return AgeRating.fromBuffer(fetch);
    } else {
      return null;
    }
  }

  Future<Count?> ageRatingCountProto(IGDBRequestParameters params) async {
    const endpoint = IGDBEndpoints.ageRatings;
    final fetch = await _makeCountProtoRequestByEndpoint(endpoint, params);
    if (fetch != null) {
      return Count.fromBuffer(fetch);
    } else {
      return null;
    }
  }

  Future<dynamic> ageRatingJson(IGDBRequestParameters params) async {
    const endpoint = IGDBEndpoints.ageRatings;
    final fetch = await _makeJsonRequestByEndpoint(endpoint, params);
    return fetch;
  }

  Future<dynamic> ageRatingCountJson(IGDBRequestParameters params) async {
    const endpoint = IGDBEndpoints.ageRatings;
    final fetch = await _makeCountJsonRequestByEndpoint(endpoint, params);
    return fetch;
  }

  Future<AgeRatingContentDescription?> ageRatingContentDescriptionProto(
    IGDBRequestParameters params,
  ) async {
    const endpoint = IGDBEndpoints.ageRatingContentDescriptions;
    final fetch = await _makeProtoRequestByEndpoint(endpoint, params);
    if (fetch != null) {
      return AgeRatingContentDescription.fromBuffer(fetch);
    } else {
      return null;
    }
  }

  Future<Count?> ageRatingContentDescriptionCountProto(
    IGDBRequestParameters params,
  ) async {
    const endpoint = IGDBEndpoints.ageRatingContentDescriptions;
    final fetch = await _makeCountProtoRequestByEndpoint(endpoint, params);
    if (fetch != null) {
      return Count.fromBuffer(fetch);
    } else {
      return null;
    }
  }

  Future<dynamic> ageRatingContentDescriptionJson(
    IGDBRequestParameters params,
  ) async {
    const endpoint = IGDBEndpoints.ageRatingContentDescriptions;
    final fetch = await _makeJsonRequestByEndpoint(endpoint, params);
    return fetch;
  }

  Future<dynamic> ageRatingContentDescriptionCountJson(
    IGDBRequestParameters params,
  ) async {
    const endpoint = IGDBEndpoints.ageRatingContentDescriptions;
    final fetch = await _makeCountJsonRequestByEndpoint(endpoint, params);
    return fetch;
  }

  Future<AlternativeName?> alternativeNameProto(
    IGDBRequestParameters params,
  ) async {
    const endpoint = IGDBEndpoints.alternativeNames;
    final fetch = await _makeProtoRequestByEndpoint(endpoint, params);
    if (fetch != null) {
      return AlternativeName.fromBuffer(fetch);
    } else {
      return null;
    }
  }

  Future<Count?> alternativeNameCountProto(IGDBRequestParameters params) async {
    const endpoint = IGDBEndpoints.alternativeNames;
    final fetch = await _makeCountProtoRequestByEndpoint(endpoint, params);
    if (fetch != null) {
      return Count.fromBuffer(fetch);
    } else {
      return null;
    }
  }

  Future<dynamic> alternativeNameJson(IGDBRequestParameters params) async {
    const endpoint = IGDBEndpoints.alternativeNames;
    final fetch = await _makeJsonRequestByEndpoint(endpoint, params);
    return fetch;
  }

  Future<dynamic> alternativeNameCountJson(IGDBRequestParameters params) async {
    const endpoint = IGDBEndpoints.alternativeNames;
    final fetch = await _makeCountJsonRequestByEndpoint(endpoint, params);
    return fetch;
  }

  Future<Artwork?> artworkProto(IGDBRequestParameters params) async {
    const endpoint = IGDBEndpoints.artworks;
    final fetch = await _makeProtoRequestByEndpoint(endpoint, params);
    if (fetch != null) {
      return Artwork.fromBuffer(fetch);
    } else {
      return null;
    }
  }

  Future<Count?> artworkCountProto(IGDBRequestParameters params) async {
    const endpoint = IGDBEndpoints.artworks;
    final fetch = await _makeCountProtoRequestByEndpoint(endpoint, params);
    if (fetch != null) {
      return Count.fromBuffer(fetch);
    } else {
      return null;
    }
  }

  Future<dynamic> artworkJson(IGDBRequestParameters params) async {
    const endpoint = IGDBEndpoints.artworks;
    final fetch = await _makeJsonRequestByEndpoint(endpoint, params);
    return fetch;
  }

  Future<dynamic> artworkCountJson(IGDBRequestParameters params) async {
    const endpoint = IGDBEndpoints.artworks;
    final fetch = await _makeCountJsonRequestByEndpoint(endpoint, params);
    return fetch;
  }

  Future<Character?> characterProto(IGDBRequestParameters params) async {
    const endpoint = IGDBEndpoints.characters;
    final fetch = await _makeProtoRequestByEndpoint(endpoint, params);
    if (fetch != null) {
      return Character.fromBuffer(fetch);
    } else {
      return null;
    }
  }

  Future<Count?> characterCountProto(IGDBRequestParameters params) async {
    const endpoint = IGDBEndpoints.characters;
    final fetch = await _makeCountProtoRequestByEndpoint(endpoint, params);
    if (fetch != null) {
      return Count.fromBuffer(fetch);
    } else {
      return null;
    }
  }

  Future<dynamic> characterJson(IGDBRequestParameters params) async {
    const endpoint = IGDBEndpoints.characters;
    final fetch = await _makeJsonRequestByEndpoint(endpoint, params);
    return fetch;
  }

  Future<dynamic> characterCountJson(IGDBRequestParameters params) async {
    const endpoint = IGDBEndpoints.characters;
    final fetch = await _makeCountJsonRequestByEndpoint(endpoint, params);
    return fetch;
  }

  Future<CharacterMugShot?> characterMugShotProto(
    IGDBRequestParameters params,
  ) async {
    const endpoint = IGDBEndpoints.characterMugShots;
    final fetch = await _makeProtoRequestByEndpoint(endpoint, params);
    if (fetch != null) {
      return CharacterMugShot.fromBuffer(fetch);
    } else {
      return null;
    }
  }

  Future<Count?> characterMugShotCountProto(
    IGDBRequestParameters params,
  ) async {
    const endpoint = IGDBEndpoints.characterMugShots;
    final fetch = await _makeCountProtoRequestByEndpoint(endpoint, params);
    if (fetch != null) {
      return Count.fromBuffer(fetch);
    } else {
      return null;
    }
  }

  Future<dynamic> characterMugShotJson(IGDBRequestParameters params) async {
    const endpoint = IGDBEndpoints.characterMugShots;
    final fetch = await _makeJsonRequestByEndpoint(endpoint, params);
    return fetch;
  }

  Future<dynamic> characterMugShotCountJson(
    IGDBRequestParameters params,
  ) async {
    const endpoint = IGDBEndpoints.characterMugShots;
    final fetch = await _makeCountJsonRequestByEndpoint(endpoint, params);
    return fetch;
  }

  Future<Collection?> collectionProto(IGDBRequestParameters params) async {
    const endpoint = IGDBEndpoints.collections;
    final fetch = await _makeProtoRequestByEndpoint(endpoint, params);
    if (fetch != null) {
      return Collection.fromBuffer(fetch);
    } else {
      return null;
    }
  }

  Future<Count?> collectionCountProto(IGDBRequestParameters params) async {
    const endpoint = IGDBEndpoints.collections;
    final fetch = await _makeCountProtoRequestByEndpoint(endpoint, params);
    if (fetch != null) {
      return Count.fromBuffer(fetch);
    } else {
      return null;
    }
  }

  Future<dynamic> collectionJson(IGDBRequestParameters params) async {
    const endpoint = IGDBEndpoints.collections;
    final fetch = await _makeJsonRequestByEndpoint(endpoint, params);
    return fetch;
  }

  Future<dynamic> collectionCountJson(IGDBRequestParameters params) async {
    const endpoint = IGDBEndpoints.collections;
    final fetch = await _makeCountJsonRequestByEndpoint(endpoint, params);
    return fetch;
  }

  Future<Company?> companyProto(IGDBRequestParameters params) async {
    const endpoint = IGDBEndpoints.companies;
    final fetch = await _makeProtoRequestByEndpoint(endpoint, params);
    if (fetch != null) {
      return Company.fromBuffer(fetch);
    } else {
      return null;
    }
  }

  Future<Count?> companyCountProto(IGDBRequestParameters params) async {
    const endpoint = IGDBEndpoints.companies;
    final fetch = await _makeCountProtoRequestByEndpoint(endpoint, params);
    if (fetch != null) {
      return Count.fromBuffer(fetch);
    } else {
      return null;
    }
  }

  Future<dynamic> companyJson(IGDBRequestParameters params) async {
    const endpoint = IGDBEndpoints.companies;
    final fetch = await _makeJsonRequestByEndpoint(endpoint, params);
    return fetch;
  }

  Future<dynamic> companyCountJson(IGDBRequestParameters params) async {
    const endpoint = IGDBEndpoints.companies;
    final fetch = await _makeCountJsonRequestByEndpoint(endpoint, params);
    return fetch;
  }

  Future<CompanyLogo?> companyLogoProto(IGDBRequestParameters params) async {
    const endpoint = IGDBEndpoints.companyLogos;
    final fetch = await _makeProtoRequestByEndpoint(endpoint, params);
    if (fetch != null) {
      return CompanyLogo.fromBuffer(fetch);
    } else {
      return null;
    }
  }

  Future<Count?> companyLogoCountProto(IGDBRequestParameters params) async {
    const endpoint = IGDBEndpoints.companyLogos;
    final fetch = await _makeCountProtoRequestByEndpoint(endpoint, params);
    if (fetch != null) {
      return Count.fromBuffer(fetch);
    } else {
      return null;
    }
  }

  Future<dynamic> companyLogoJson(IGDBRequestParameters params) async {
    const endpoint = IGDBEndpoints.companyLogos;
    final fetch = await _makeJsonRequestByEndpoint(endpoint, params);
    return fetch;
  }

  Future<dynamic> companyLogoCountJson(IGDBRequestParameters params) async {
    const endpoint = IGDBEndpoints.companyLogos;
    final fetch = await _makeCountJsonRequestByEndpoint(endpoint, params);
    return fetch;
  }

  Future<CompanyWebsite?> companyWebsiteProto(
    IGDBRequestParameters params,
  ) async {
    const endpoint = IGDBEndpoints.companyWebsites;
    final fetch = await _makeProtoRequestByEndpoint(endpoint, params);
    if (fetch != null) {
      return CompanyWebsite.fromBuffer(fetch);
    } else {
      return null;
    }
  }

  Future<Count?> companyWebsiteCountProto(IGDBRequestParameters params) async {
    const endpoint = IGDBEndpoints.companyWebsites;
    final fetch = await _makeCountProtoRequestByEndpoint(endpoint, params);
    if (fetch != null) {
      return Count.fromBuffer(fetch);
    } else {
      return null;
    }
  }

  Future<dynamic> companyWebsiteJson(IGDBRequestParameters params) async {
    const endpoint = IGDBEndpoints.companyWebsites;
    final fetch = await _makeJsonRequestByEndpoint(endpoint, params);
    return fetch;
  }

  Future<dynamic> companyWebsiteCountJson(IGDBRequestParameters params) async {
    const endpoint = IGDBEndpoints.companyWebsites;
    final fetch = await _makeCountJsonRequestByEndpoint(endpoint, params);
    return fetch;
  }

  Future<Cover?> coverProto(IGDBRequestParameters params) async {
    const endpoint = IGDBEndpoints.covers;
    final fetch = await _makeProtoRequestByEndpoint(endpoint, params);
    if (fetch != null) {
      return Cover.fromBuffer(fetch);
    } else {
      return null;
    }
  }

  Future<Count?> coverCountProto(IGDBRequestParameters params) async {
    const endpoint = IGDBEndpoints.covers;
    final fetch = await _makeCountProtoRequestByEndpoint(endpoint, params);
    if (fetch != null) {
      return Count.fromBuffer(fetch);
    } else {
      return null;
    }
  }

  Future<dynamic> coverJson(IGDBRequestParameters params) async {
    const endpoint = IGDBEndpoints.covers;
    final fetch = await _makeJsonRequestByEndpoint(endpoint, params);
    return fetch;
  }

  Future<dynamic> coverCountJson(IGDBRequestParameters params) async {
    const endpoint = IGDBEndpoints.covers;
    final fetch = await _makeCountJsonRequestByEndpoint(endpoint, params);
    return fetch;
  }

  Future<ExternalGame?> externalGameProto(IGDBRequestParameters params) async {
    const endpoint = IGDBEndpoints.externalGames;
    final fetch = await _makeProtoRequestByEndpoint(endpoint, params);
    if (fetch != null) {
      return ExternalGame.fromBuffer(fetch);
    } else {
      return null;
    }
  }

  Future<Count?> externalGameCountProto(IGDBRequestParameters params) async {
    const endpoint = IGDBEndpoints.externalGames;
    final fetch = await _makeCountProtoRequestByEndpoint(endpoint, params);
    if (fetch != null) {
      return Count.fromBuffer(fetch);
    } else {
      return null;
    }
  }

  Future<dynamic> externalGameJson(IGDBRequestParameters params) async {
    const endpoint = IGDBEndpoints.externalGames;
    final fetch = await _makeJsonRequestByEndpoint(endpoint, params);
    return fetch;
  }

  Future<dynamic> externalGameCountJson(IGDBRequestParameters params) async {
    const endpoint = IGDBEndpoints.externalGames;
    final fetch = await _makeCountJsonRequestByEndpoint(endpoint, params);
    return fetch;
  }

  Future<Franchise?> franchiseProto(IGDBRequestParameters params) async {
    const endpoint = IGDBEndpoints.franchises;
    final fetch = await _makeProtoRequestByEndpoint(endpoint, params);
    if (fetch != null) {
      return Franchise.fromBuffer(fetch);
    } else {
      return null;
    }
  }

  Future<Count?> franchiseCountProto(IGDBRequestParameters params) async {
    const endpoint = IGDBEndpoints.franchises;
    final fetch = await _makeCountProtoRequestByEndpoint(endpoint, params);
    if (fetch != null) {
      return Count.fromBuffer(fetch);
    } else {
      return null;
    }
  }

  Future<dynamic> franchiseJson(IGDBRequestParameters params) async {
    const endpoint = IGDBEndpoints.franchises;
    final fetch = await _makeJsonRequestByEndpoint(endpoint, params);
    return fetch;
  }

  Future<dynamic> franchiseCountJson(IGDBRequestParameters params) async {
    const endpoint = IGDBEndpoints.franchises;
    final fetch = await _makeCountJsonRequestByEndpoint(endpoint, params);
    return fetch;
  }

  Future<Game?> gameProto(IGDBRequestParameters params) async {
    const endpoint = IGDBEndpoints.games;
    final fetch = await _makeProtoRequestByEndpoint(endpoint, params);
    if (fetch != null) {
      return Game.fromBuffer(fetch);
    } else {
      return null;
    }
  }

  Future<Count?> gameCountProto(IGDBRequestParameters params) async {
    const endpoint = IGDBEndpoints.games;
    final fetch = await _makeCountProtoRequestByEndpoint(endpoint, params);
    if (fetch != null) {
      return Count.fromBuffer(fetch);
    } else {
      return null;
    }
  }

  Future<dynamic> gameJson(IGDBRequestParameters params) async {
    const endpoint = IGDBEndpoints.games;
    final fetch = await _makeJsonRequestByEndpoint(endpoint, params);
    return fetch;
  }

  Future<dynamic> gameCountJson(IGDBRequestParameters params) async {
    const endpoint = IGDBEndpoints.games;
    final fetch = await _makeCountJsonRequestByEndpoint(endpoint, params);
    return fetch;
  }

  Future<GameEngine?> gameEngineProto(IGDBRequestParameters params) async {
    const endpoint = IGDBEndpoints.gameEngines;
    final fetch = await _makeProtoRequestByEndpoint(endpoint, params);
    if (fetch != null) {
      return GameEngine.fromBuffer(fetch);
    } else {
      return null;
    }
  }

  Future<Count?> gameEngineCountProto(IGDBRequestParameters params) async {
    const endpoint = IGDBEndpoints.gameEngines;
    final fetch = await _makeCountProtoRequestByEndpoint(endpoint, params);
    if (fetch != null) {
      return Count.fromBuffer(fetch);
    } else {
      return null;
    }
  }

  Future<dynamic> gameEngineJson(IGDBRequestParameters params) async {
    const endpoint = IGDBEndpoints.gameEngines;
    final fetch = await _makeJsonRequestByEndpoint(endpoint, params);
    return fetch;
  }

  Future<dynamic> gameEngineCountJson(IGDBRequestParameters params) async {
    const endpoint = IGDBEndpoints.gameEngines;
    final fetch = await _makeCountJsonRequestByEndpoint(endpoint, params);
    return fetch;
  }

  Future<GameEngineLogo?> gameEngineLogoProto(
    IGDBRequestParameters params,
  ) async {
    const endpoint = IGDBEndpoints.gameEngineLogos;
    final fetch = await _makeProtoRequestByEndpoint(endpoint, params);
    if (fetch != null) {
      return GameEngineLogo.fromBuffer(fetch);
    } else {
      return null;
    }
  }

  Future<Count?> gameEngineLogoCountProto(IGDBRequestParameters params) async {
    const endpoint = IGDBEndpoints.gameEngineLogos;
    final fetch = await _makeCountProtoRequestByEndpoint(endpoint, params);
    if (fetch != null) {
      return Count.fromBuffer(fetch);
    } else {
      return null;
    }
  }

  Future<dynamic> gameEngineLogoJson(IGDBRequestParameters params) async {
    const endpoint = IGDBEndpoints.gameEngineLogos;
    final fetch = await _makeJsonRequestByEndpoint(endpoint, params);
    return fetch;
  }

  Future<dynamic> gameEngineLogoCountJson(IGDBRequestParameters params) async {
    const endpoint = IGDBEndpoints.gameEngineLogos;
    final fetch = await _makeCountJsonRequestByEndpoint(endpoint, params);
    return fetch;
  }

  Future<GameLocalization?> gameLocalizationProto(
    IGDBRequestParameters params,
  ) async {
    const endpoint = IGDBEndpoints.gameLocalizations;
    final fetch = await _makeProtoRequestByEndpoint(endpoint, params);
    if (fetch != null) {
      return GameLocalization.fromBuffer(fetch);
    } else {
      return null;
    }
  }

  Future<Count?> gameLocalizationCountProto(
    IGDBRequestParameters params,
  ) async {
    const endpoint = IGDBEndpoints.gameLocalizations;
    final fetch = await _makeCountProtoRequestByEndpoint(endpoint, params);
    if (fetch != null) {
      return Count.fromBuffer(fetch);
    } else {
      return null;
    }
  }

  Future<dynamic> gameLocalizationJson(IGDBRequestParameters params) async {
    const endpoint = IGDBEndpoints.gameLocalizations;
    final fetch = await _makeJsonRequestByEndpoint(endpoint, params);
    return fetch;
  }

  Future<dynamic> gameLocalizationCountJson(
    IGDBRequestParameters params,
  ) async {
    const endpoint = IGDBEndpoints.gameLocalizations;
    final fetch = await _makeCountJsonRequestByEndpoint(endpoint, params);
    return fetch;
  }

  Future<GameMode?> gameModeProto(IGDBRequestParameters params) async {
    const endpoint = IGDBEndpoints.gameModes;
    final fetch = await _makeProtoRequestByEndpoint(endpoint, params);
    if (fetch != null) {
      return GameMode.fromBuffer(fetch);
    } else {
      return null;
    }
  }

  Future<Count?> gameModeCountProto(IGDBRequestParameters params) async {
    const endpoint = IGDBEndpoints.gameModes;
    final fetch = await _makeCountProtoRequestByEndpoint(endpoint, params);
    if (fetch != null) {
      return Count.fromBuffer(fetch);
    } else {
      return null;
    }
  }

  Future<dynamic> gameModeJson(IGDBRequestParameters params) async {
    const endpoint = IGDBEndpoints.gameModes;
    final fetch = await _makeJsonRequestByEndpoint(endpoint, params);
    return fetch;
  }

  Future<dynamic> gameModeCountJson(IGDBRequestParameters params) async {
    const endpoint = IGDBEndpoints.gameModes;
    final fetch = await _makeCountJsonRequestByEndpoint(endpoint, params);
    return fetch;
  }

  Future<GameVersion?> gameVersionProto(IGDBRequestParameters params) async {
    const endpoint = IGDBEndpoints.gameVersions;
    final fetch = await _makeProtoRequestByEndpoint(endpoint, params);
    if (fetch != null) {
      return GameVersion.fromBuffer(fetch);
    } else {
      return null;
    }
  }

  Future<Count?> gameVersionCountProto(IGDBRequestParameters params) async {
    const endpoint = IGDBEndpoints.gameVersions;
    final fetch = await _makeCountProtoRequestByEndpoint(endpoint, params);
    if (fetch != null) {
      return Count.fromBuffer(fetch);
    } else {
      return null;
    }
  }

  Future<dynamic> gameVersionJson(IGDBRequestParameters params) async {
    const endpoint = IGDBEndpoints.gameVersions;
    final fetch = await _makeJsonRequestByEndpoint(endpoint, params);
    return fetch;
  }

  Future<dynamic> gameVersionCountJson(IGDBRequestParameters params) async {
    const endpoint = IGDBEndpoints.gameVersions;
    final fetch = await _makeCountJsonRequestByEndpoint(endpoint, params);
    return fetch;
  }

  Future<GameVersionFeature?> gameVersionFeatureProto(
    IGDBRequestParameters params,
  ) async {
    const endpoint = IGDBEndpoints.gameVersionFeatures;
    final fetch = await _makeProtoRequestByEndpoint(endpoint, params);
    if (fetch != null) {
      return GameVersionFeature.fromBuffer(fetch);
    } else {
      return null;
    }
  }

  Future<Count?> gameVersionFeatureCountProto(
    IGDBRequestParameters params,
  ) async {
    const endpoint = IGDBEndpoints.gameVersionFeatures;
    final fetch = await _makeCountProtoRequestByEndpoint(endpoint, params);
    if (fetch != null) {
      return Count.fromBuffer(fetch);
    } else {
      return null;
    }
  }

  Future<dynamic> gameVersionFeatureJson(IGDBRequestParameters params) async {
    const endpoint = IGDBEndpoints.gameVersionFeatures;
    final fetch = await _makeJsonRequestByEndpoint(endpoint, params);
    return fetch;
  }

  Future<dynamic> gameVersionFeatureCountJson(
    IGDBRequestParameters params,
  ) async {
    const endpoint = IGDBEndpoints.gameVersionFeatures;
    final fetch = await _makeCountJsonRequestByEndpoint(endpoint, params);
    return fetch;
  }

  Future<GameVersionFeatureValue?> gameVersionFeatureValueProto(
    IGDBRequestParameters params,
  ) async {
    const endpoint = IGDBEndpoints.gameVersionFeatureValues;
    final fetch = await _makeProtoRequestByEndpoint(endpoint, params);
    if (fetch != null) {
      return GameVersionFeatureValue.fromBuffer(fetch);
    } else {
      return null;
    }
  }

  Future<Count?> gameVersionFeatureValueCountProto(
    IGDBRequestParameters params,
  ) async {
    const endpoint = IGDBEndpoints.gameVersionFeatureValues;
    final fetch = await _makeCountProtoRequestByEndpoint(endpoint, params);
    if (fetch != null) {
      return Count.fromBuffer(fetch);
    } else {
      return null;
    }
  }

  Future<dynamic> gameVersionFeatureValueJson(
    IGDBRequestParameters params,
  ) async {
    const endpoint = IGDBEndpoints.gameVersionFeatureValues;
    final fetch = await _makeJsonRequestByEndpoint(endpoint, params);
    return fetch;
  }

  Future<dynamic> gameVersionFeatureValueCountJson(
    IGDBRequestParameters params,
  ) async {
    const endpoint = IGDBEndpoints.gameVersionFeatureValues;
    final fetch = await _makeCountJsonRequestByEndpoint(endpoint, params);
    return fetch;
  }

  Future<GameVideo?> gameVideoProto(IGDBRequestParameters params) async {
    const endpoint = IGDBEndpoints.gameVideos;
    final fetch = await _makeProtoRequestByEndpoint(endpoint, params);
    if (fetch != null) {
      return GameVideo.fromBuffer(fetch);
    } else {
      return null;
    }
  }

  Future<Count?> gameVideoCountProto(IGDBRequestParameters params) async {
    const endpoint = IGDBEndpoints.gameVideos;
    final fetch = await _makeCountProtoRequestByEndpoint(endpoint, params);
    if (fetch != null) {
      return Count.fromBuffer(fetch);
    } else {
      return null;
    }
  }

  Future<dynamic> gameVideoJson(IGDBRequestParameters params) async {
    const endpoint = IGDBEndpoints.gameVideos;
    final fetch = await _makeJsonRequestByEndpoint(endpoint, params);
    return fetch;
  }

  Future<dynamic> gameVideoCountJson(IGDBRequestParameters params) async {
    const endpoint = IGDBEndpoints.gameVideos;
    final fetch = await _makeCountJsonRequestByEndpoint(endpoint, params);
    return fetch;
  }

  Future<Genre?> genreProto(IGDBRequestParameters params) async {
    const endpoint = IGDBEndpoints.genres;
    final fetch = await _makeProtoRequestByEndpoint(endpoint, params);
    if (fetch != null) {
      return Genre.fromBuffer(fetch);
    } else {
      return null;
    }
  }

  Future<Count?> genreCountProto(IGDBRequestParameters params) async {
    const endpoint = IGDBEndpoints.genres;
    final fetch = await _makeCountProtoRequestByEndpoint(endpoint, params);
    if (fetch != null) {
      return Count.fromBuffer(fetch);
    } else {
      return null;
    }
  }

  Future<dynamic> genreJson(IGDBRequestParameters params) async {
    const endpoint = IGDBEndpoints.genres;
    final fetch = await _makeJsonRequestByEndpoint(endpoint, params);
    return fetch;
  }

  Future<dynamic> genreCountJson(IGDBRequestParameters params) async {
    const endpoint = IGDBEndpoints.genres;
    final fetch = await _makeCountJsonRequestByEndpoint(endpoint, params);
    return fetch;
  }

  Future<InvolvedCompany?> involvedCompanyProto(
    IGDBRequestParameters params,
  ) async {
    const endpoint = IGDBEndpoints.involvedCompanies;
    final fetch = await _makeProtoRequestByEndpoint(endpoint, params);
    if (fetch != null) {
      return InvolvedCompany.fromBuffer(fetch);
    } else {
      return null;
    }
  }

  Future<Count?> involvedCompanyCountProto(IGDBRequestParameters params) async {
    const endpoint = IGDBEndpoints.involvedCompanies;
    final fetch = await _makeCountProtoRequestByEndpoint(endpoint, params);
    if (fetch != null) {
      return Count.fromBuffer(fetch);
    } else {
      return null;
    }
  }

  Future<dynamic> involvedCompanyJson(IGDBRequestParameters params) async {
    const endpoint = IGDBEndpoints.involvedCompanies;
    final fetch = await _makeJsonRequestByEndpoint(endpoint, params);
    return fetch;
  }

  Future<dynamic> involvedCompanyCountJson(IGDBRequestParameters params) async {
    const endpoint = IGDBEndpoints.involvedCompanies;
    final fetch = await _makeCountJsonRequestByEndpoint(endpoint, params);
    return fetch;
  }

  Future<Keyword?> keywordProto(IGDBRequestParameters params) async {
    const endpoint = IGDBEndpoints.keywords;
    final fetch = await _makeProtoRequestByEndpoint(endpoint, params);
    if (fetch != null) {
      return Keyword.fromBuffer(fetch);
    } else {
      return null;
    }
  }

  Future<Count?> keywordCountProto(IGDBRequestParameters params) async {
    const endpoint = IGDBEndpoints.keywords;
    final fetch = await _makeCountProtoRequestByEndpoint(endpoint, params);
    if (fetch != null) {
      return Count.fromBuffer(fetch);
    } else {
      return null;
    }
  }

  Future<dynamic> keywordJson(IGDBRequestParameters params) async {
    const endpoint = IGDBEndpoints.keywords;
    final fetch = await _makeJsonRequestByEndpoint(endpoint, params);
    return fetch;
  }

  Future<dynamic> keywordCountJson(IGDBRequestParameters params) async {
    const endpoint = IGDBEndpoints.keywords;
    final fetch = await _makeCountJsonRequestByEndpoint(endpoint, params);
    return fetch;
  }

  Future<LanguageSupport?> languageSupportProto(
    IGDBRequestParameters params,
  ) async {
    const endpoint = IGDBEndpoints.languageSupports;
    final fetch = await _makeProtoRequestByEndpoint(endpoint, params);
    if (fetch != null) {
      return LanguageSupport.fromBuffer(fetch);
    } else {
      return null;
    }
  }

  Future<Count?> languageSupportCountProto(IGDBRequestParameters params) async {
    const endpoint = IGDBEndpoints.languageSupports;
    final fetch = await _makeCountProtoRequestByEndpoint(endpoint, params);
    if (fetch != null) {
      return Count.fromBuffer(fetch);
    } else {
      return null;
    }
  }

  Future<dynamic> languageSupportJson(IGDBRequestParameters params) async {
    const endpoint = IGDBEndpoints.languageSupports;
    final fetch = await _makeJsonRequestByEndpoint(endpoint, params);
    return fetch;
  }

  Future<dynamic> languageSupportCountJson(IGDBRequestParameters params) async {
    const endpoint = IGDBEndpoints.languageSupports;
    final fetch = await _makeCountJsonRequestByEndpoint(endpoint, params);
    return fetch;
  }

  Future<LanguageSupportType?> languageSupportTypeProto(
    IGDBRequestParameters params,
  ) async {
    const endpoint = IGDBEndpoints.languageSupportTypes;
    final fetch = await _makeProtoRequestByEndpoint(endpoint, params);
    if (fetch != null) {
      return LanguageSupportType.fromBuffer(fetch);
    } else {
      return null;
    }
  }

  Future<Count?> languageSupportTypeCountProto(
    IGDBRequestParameters params,
  ) async {
    const endpoint = IGDBEndpoints.languageSupportTypes;
    final fetch = await _makeCountProtoRequestByEndpoint(endpoint, params);
    if (fetch != null) {
      return Count.fromBuffer(fetch);
    } else {
      return null;
    }
  }

  Future<dynamic> languageSupportTypeJson(IGDBRequestParameters params) async {
    const endpoint = IGDBEndpoints.languageSupportTypes;
    final fetch = await _makeJsonRequestByEndpoint(endpoint, params);
    return fetch;
  }

  Future<dynamic> languageSupportTypeCountJson(
    IGDBRequestParameters params,
  ) async {
    const endpoint = IGDBEndpoints.languageSupportTypes;
    final fetch = await _makeCountJsonRequestByEndpoint(endpoint, params);
    return fetch;
  }

  Future<Language?> languageProto(IGDBRequestParameters params) async {
    const endpoint = IGDBEndpoints.languages;
    final fetch = await _makeProtoRequestByEndpoint(endpoint, params);
    if (fetch != null) {
      return Language.fromBuffer(fetch);
    } else {
      return null;
    }
  }

  Future<Count?> languageCountProto(IGDBRequestParameters params) async {
    const endpoint = IGDBEndpoints.languages;
    final fetch = await _makeCountProtoRequestByEndpoint(endpoint, params);
    if (fetch != null) {
      return Count.fromBuffer(fetch);
    } else {
      return null;
    }
  }

  Future<dynamic> languageJson(IGDBRequestParameters params) async {
    const endpoint = IGDBEndpoints.languages;
    final fetch = await _makeJsonRequestByEndpoint(endpoint, params);
    return fetch;
  }

  Future<dynamic> languageCountJson(IGDBRequestParameters params) async {
    const endpoint = IGDBEndpoints.languages;
    final fetch = await _makeCountJsonRequestByEndpoint(endpoint, params);
    return fetch;
  }

  Future<MultiplayerMode?> multiplayerModeProto(
    IGDBRequestParameters params,
  ) async {
    const endpoint = IGDBEndpoints.multiplayerModes;
    final fetch = await _makeProtoRequestByEndpoint(endpoint, params);
    if (fetch != null) {
      return MultiplayerMode.fromBuffer(fetch);
    } else {
      return null;
    }
  }

  Future<Count?> multiplayerModeCountProto(IGDBRequestParameters params) async {
    const endpoint = IGDBEndpoints.multiplayerModes;
    final fetch = await _makeCountProtoRequestByEndpoint(endpoint, params);
    if (fetch != null) {
      return Count.fromBuffer(fetch);
    } else {
      return null;
    }
  }

  Future<dynamic> multiplayerModeJson(IGDBRequestParameters params) async {
    const endpoint = IGDBEndpoints.multiplayerModes;
    final fetch = await _makeJsonRequestByEndpoint(endpoint, params);
    return fetch;
  }

  Future<dynamic> multiplayerModeCountJson(IGDBRequestParameters params) async {
    const endpoint = IGDBEndpoints.multiplayerModes;
    final fetch = await _makeCountJsonRequestByEndpoint(endpoint, params);
    return fetch;
  }

  Future<Platform?> platformProto(IGDBRequestParameters params) async {
    const endpoint = IGDBEndpoints.platforms;
    final fetch = await _makeProtoRequestByEndpoint(endpoint, params);
    if (fetch != null) {
      return Platform.fromBuffer(fetch);
    } else {
      return null;
    }
  }

  Future<Count?> platformCountProto(IGDBRequestParameters params) async {
    const endpoint = IGDBEndpoints.platforms;
    final fetch = await _makeCountProtoRequestByEndpoint(endpoint, params);
    if (fetch != null) {
      return Count.fromBuffer(fetch);
    } else {
      return null;
    }
  }

  Future<dynamic> platformJson(IGDBRequestParameters params) async {
    const endpoint = IGDBEndpoints.platforms;
    final fetch = await _makeJsonRequestByEndpoint(endpoint, params);
    return fetch;
  }

  Future<dynamic> platformCountJson(IGDBRequestParameters params) async {
    const endpoint = IGDBEndpoints.platforms;
    final fetch = await _makeCountJsonRequestByEndpoint(endpoint, params);
    return fetch;
  }

  Future<PlatformFamily?> platformFamilyProto(
    IGDBRequestParameters params,
  ) async {
    const endpoint = IGDBEndpoints.platformFamilies;
    final fetch = await _makeProtoRequestByEndpoint(endpoint, params);
    if (fetch != null) {
      return PlatformFamily.fromBuffer(fetch);
    } else {
      return null;
    }
  }

  Future<Count?> platformFamilyCountProto(IGDBRequestParameters params) async {
    const endpoint = IGDBEndpoints.platformFamilies;
    final fetch = await _makeCountProtoRequestByEndpoint(endpoint, params);
    if (fetch != null) {
      return Count.fromBuffer(fetch);
    } else {
      return null;
    }
  }

  Future<dynamic> platformFamilyJson(IGDBRequestParameters params) async {
    const endpoint = IGDBEndpoints.platformFamilies;
    final fetch = await _makeJsonRequestByEndpoint(endpoint, params);
    return fetch;
  }

  Future<dynamic> platformFamilyCountJson(IGDBRequestParameters params) async {
    const endpoint = IGDBEndpoints.platformFamilies;
    final fetch = await _makeCountJsonRequestByEndpoint(endpoint, params);
    return fetch;
  }

  Future<PlatformLogo?> platformLogoProto(IGDBRequestParameters params) async {
    const endpoint = IGDBEndpoints.platformLogos;
    final fetch = await _makeProtoRequestByEndpoint(endpoint, params);
    if (fetch != null) {
      return PlatformLogo.fromBuffer(fetch);
    } else {
      return null;
    }
  }

  Future<Count?> platformLogoCountProto(IGDBRequestParameters params) async {
    const endpoint = IGDBEndpoints.platformLogos;
    final fetch = await _makeCountProtoRequestByEndpoint(endpoint, params);
    if (fetch != null) {
      return Count.fromBuffer(fetch);
    } else {
      return null;
    }
  }

  Future<dynamic> platformLogoJson(IGDBRequestParameters params) async {
    const endpoint = IGDBEndpoints.platformLogos;
    final fetch = await _makeJsonRequestByEndpoint(endpoint, params);
    return fetch;
  }

  Future<dynamic> platformLogoCountJson(IGDBRequestParameters params) async {
    const endpoint = IGDBEndpoints.platformLogos;
    final fetch = await _makeCountJsonRequestByEndpoint(endpoint, params);
    return fetch;
  }

  Future<PlatformVersion?> platformVersionProto(
    IGDBRequestParameters params,
  ) async {
    const endpoint = IGDBEndpoints.platformVersions;
    final fetch = await _makeProtoRequestByEndpoint(endpoint, params);
    if (fetch != null) {
      return PlatformVersion.fromBuffer(fetch);
    } else {
      return null;
    }
  }

  Future<Count?> platformVersionCountProto(IGDBRequestParameters params) async {
    const endpoint = IGDBEndpoints.platformVersions;
    final fetch = await _makeCountProtoRequestByEndpoint(endpoint, params);
    if (fetch != null) {
      return Count.fromBuffer(fetch);
    } else {
      return null;
    }
  }

  Future<dynamic> platformVersionJson(IGDBRequestParameters params) async {
    const endpoint = IGDBEndpoints.platformVersions;
    final fetch = await _makeJsonRequestByEndpoint(endpoint, params);
    return fetch;
  }

  Future<dynamic> platformVersionCountJson(IGDBRequestParameters params) async {
    const endpoint = IGDBEndpoints.platformVersions;
    final fetch = await _makeCountJsonRequestByEndpoint(endpoint, params);
    return fetch;
  }

  Future<PlatformVersionCompany?> platformVersionCompanyProto(
    IGDBRequestParameters params,
  ) async {
    const endpoint = IGDBEndpoints.platformVersionCompanies;
    final fetch = await _makeProtoRequestByEndpoint(endpoint, params);
    if (fetch != null) {
      return PlatformVersionCompany.fromBuffer(fetch);
    } else {
      return null;
    }
  }

  Future<Count?> platformVersionCompanyCountProto(
    IGDBRequestParameters params,
  ) async {
    const endpoint = IGDBEndpoints.platformVersionCompanies;
    final fetch = await _makeCountProtoRequestByEndpoint(endpoint, params);
    if (fetch != null) {
      return Count.fromBuffer(fetch);
    } else {
      return null;
    }
  }

  Future<dynamic> platformVersionCompanyJson(
    IGDBRequestParameters params,
  ) async {
    const endpoint = IGDBEndpoints.platformVersionCompanies;
    final fetch = await _makeJsonRequestByEndpoint(endpoint, params);
    return fetch;
  }

  Future<dynamic> platformVersionCompanyCountJson(
    IGDBRequestParameters params,
  ) async {
    const endpoint = IGDBEndpoints.platformVersionCompanies;
    final fetch = await _makeCountJsonRequestByEndpoint(endpoint, params);
    return fetch;
  }

  Future<PlatformVersionReleaseDate?> platformVersionReleaseDateProto(
    IGDBRequestParameters params,
  ) async {
    const endpoint = IGDBEndpoints.platformVersionReleaseDates;
    final fetch = await _makeProtoRequestByEndpoint(endpoint, params);
    if (fetch != null) {
      return PlatformVersionReleaseDate.fromBuffer(fetch);
    } else {
      return null;
    }
  }

  Future<Count?> platformVersionReleaseDateCountProto(
    IGDBRequestParameters params,
  ) async {
    const endpoint = IGDBEndpoints.platformVersionReleaseDates;
    final fetch = await _makeCountProtoRequestByEndpoint(endpoint, params);
    if (fetch != null) {
      return Count.fromBuffer(fetch);
    } else {
      return null;
    }
  }

  Future<dynamic> platformVersionReleaseDateJson(
    IGDBRequestParameters params,
  ) async {
    const endpoint = IGDBEndpoints.platformVersionReleaseDates;
    final fetch = await _makeJsonRequestByEndpoint(endpoint, params);
    return fetch;
  }

  Future<dynamic> platformVersionReleaseDateCountJson(
    IGDBRequestParameters params,
  ) async {
    const endpoint = IGDBEndpoints.platformVersionReleaseDates;
    final fetch = await _makeCountJsonRequestByEndpoint(endpoint, params);
    return fetch;
  }

  Future<PlatformWebsite?> platformWebsiteProto(
    IGDBRequestParameters params,
  ) async {
    const endpoint = IGDBEndpoints.platformWebsites;
    final fetch = await _makeProtoRequestByEndpoint(endpoint, params);
    if (fetch != null) {
      return PlatformWebsite.fromBuffer(fetch);
    } else {
      return null;
    }
  }

  Future<Count?> platformWebsiteCountProto(IGDBRequestParameters params) async {
    const endpoint = IGDBEndpoints.platformWebsites;
    final fetch = await _makeCountProtoRequestByEndpoint(endpoint, params);
    if (fetch != null) {
      return Count.fromBuffer(fetch);
    } else {
      return null;
    }
  }

  Future<dynamic> platformWebsiteJson(IGDBRequestParameters params) async {
    const endpoint = IGDBEndpoints.platformWebsites;
    final fetch = await _makeJsonRequestByEndpoint(endpoint, params);
    return fetch;
  }

  Future<dynamic> platformWebsiteCountJson(IGDBRequestParameters params) async {
    const endpoint = IGDBEndpoints.platformWebsites;
    final fetch = await _makeCountJsonRequestByEndpoint(endpoint, params);
    return fetch;
  }

  Future<PlayerPerspective?> playerPerspectiveProto(
    IGDBRequestParameters params,
  ) async {
    const endpoint = IGDBEndpoints.playerPerspectives;
    final fetch = await _makeProtoRequestByEndpoint(endpoint, params);
    if (fetch != null) {
      return PlayerPerspective.fromBuffer(fetch);
    } else {
      return null;
    }
  }

  Future<Count?> playerPerspectiveCountProto(
    IGDBRequestParameters params,
  ) async {
    const endpoint = IGDBEndpoints.playerPerspectives;
    final fetch = await _makeCountProtoRequestByEndpoint(endpoint, params);
    if (fetch != null) {
      return Count.fromBuffer(fetch);
    } else {
      return null;
    }
  }

  Future<dynamic> playerPerspectiveJson(IGDBRequestParameters params) async {
    const endpoint = IGDBEndpoints.playerPerspectives;
    final fetch = await _makeJsonRequestByEndpoint(endpoint, params);
    return fetch;
  }

  Future<dynamic> playerPerspectiveCountJson(
    IGDBRequestParameters params,
  ) async {
    const endpoint = IGDBEndpoints.playerPerspectives;
    final fetch = await _makeCountJsonRequestByEndpoint(endpoint, params);
    return fetch;
  }

  Future<Region?> regionProto(IGDBRequestParameters params) async {
    const endpoint = IGDBEndpoints.regions;
    final fetch = await _makeProtoRequestByEndpoint(endpoint, params);
    if (fetch != null) {
      return Region.fromBuffer(fetch);
    } else {
      return null;
    }
  }

  Future<Count?> regionCountProto(IGDBRequestParameters params) async {
    const endpoint = IGDBEndpoints.regions;
    final fetch = await _makeCountProtoRequestByEndpoint(endpoint, params);
    if (fetch != null) {
      return Count.fromBuffer(fetch);
    } else {
      return null;
    }
  }

  Future<dynamic> regionJson(IGDBRequestParameters params) async {
    const endpoint = IGDBEndpoints.regions;
    final fetch = await _makeJsonRequestByEndpoint(endpoint, params);
    return fetch;
  }

  Future<dynamic> regionCountJson(IGDBRequestParameters params) async {
    const endpoint = IGDBEndpoints.regions;
    final fetch = await _makeCountJsonRequestByEndpoint(endpoint, params);
    return fetch;
  }

  Future<ReleaseDate?> releaseDateProto(IGDBRequestParameters params) async {
    const endpoint = IGDBEndpoints.releaseDates;
    final fetch = await _makeProtoRequestByEndpoint(endpoint, params);
    if (fetch != null) {
      return ReleaseDate.fromBuffer(fetch);
    } else {
      return null;
    }
  }

  Future<Count?> releaseDateCountProto(IGDBRequestParameters params) async {
    const endpoint = IGDBEndpoints.releaseDates;
    final fetch = await _makeCountProtoRequestByEndpoint(endpoint, params);
    if (fetch != null) {
      return Count.fromBuffer(fetch);
    } else {
      return null;
    }
  }

  Future<dynamic> releaseDateJson(IGDBRequestParameters params) async {
    const endpoint = IGDBEndpoints.releaseDates;
    final fetch = await _makeJsonRequestByEndpoint(endpoint, params);
    return fetch;
  }

  Future<dynamic> releaseDateCountJson(IGDBRequestParameters params) async {
    const endpoint = IGDBEndpoints.releaseDates;
    final fetch = await _makeCountJsonRequestByEndpoint(endpoint, params);
    return fetch;
  }

  Future<ReleaseDateStatus?> releaseDateStatusProto(
    IGDBRequestParameters params,
  ) async {
    const endpoint = IGDBEndpoints.releaseDateStatuses;
    final fetch = await _makeProtoRequestByEndpoint(endpoint, params);
    if (fetch != null) {
      return ReleaseDateStatus.fromBuffer(fetch);
    } else {
      return null;
    }
  }

  Future<Count?> releaseDateStatusCountProto(
    IGDBRequestParameters params,
  ) async {
    const endpoint = IGDBEndpoints.releaseDateStatuses;
    final fetch = await _makeCountProtoRequestByEndpoint(endpoint, params);
    if (fetch != null) {
      return Count.fromBuffer(fetch);
    } else {
      return null;
    }
  }

  Future<dynamic> releaseDateStatusJson(IGDBRequestParameters params) async {
    const endpoint = IGDBEndpoints.releaseDateStatuses;
    final fetch = await _makeJsonRequestByEndpoint(endpoint, params);
    return fetch;
  }

  Future<dynamic> releaseDateStatusCountJson(
    IGDBRequestParameters params,
  ) async {
    const endpoint = IGDBEndpoints.releaseDateStatuses;
    final fetch = await _makeCountJsonRequestByEndpoint(endpoint, params);
    return fetch;
  }

  Future<Screenshot?> screenshotProto(IGDBRequestParameters params) async {
    const endpoint = IGDBEndpoints.screenshots;
    final fetch = await _makeProtoRequestByEndpoint(endpoint, params);
    if (fetch != null) {
      return Screenshot.fromBuffer(fetch);
    } else {
      return null;
    }
  }

  Future<Count?> screenshotCountProto(IGDBRequestParameters params) async {
    const endpoint = IGDBEndpoints.screenshots;
    final fetch = await _makeCountProtoRequestByEndpoint(endpoint, params);
    if (fetch != null) {
      return Count.fromBuffer(fetch);
    } else {
      return null;
    }
  }

  Future<dynamic> screenshotJson(IGDBRequestParameters params) async {
    const endpoint = IGDBEndpoints.screenshots;
    final fetch = await _makeJsonRequestByEndpoint(endpoint, params);
    return fetch;
  }

  Future<dynamic> screenshotCountJson(IGDBRequestParameters params) async {
    const endpoint = IGDBEndpoints.screenshots;
    final fetch = await _makeCountJsonRequestByEndpoint(endpoint, params);
    return fetch;
  }

  Future<Search?> searchProto(IGDBRequestParameters params) async {
    const endpoint = IGDBEndpoints.search;
    final fetch = await _makeProtoRequestByEndpoint(endpoint, params);
    if (fetch != null) {
      return Search.fromBuffer(fetch);
    } else {
      return null;
    }
  }

  Future<Count?> searchCountProto(IGDBRequestParameters params) async {
    const endpoint = IGDBEndpoints.search;
    final fetch = await _makeCountProtoRequestByEndpoint(endpoint, params);
    if (fetch != null) {
      return Count.fromBuffer(fetch);
    } else {
      return null;
    }
  }

  Future<dynamic> searchJson(IGDBRequestParameters params) async {
    const endpoint = IGDBEndpoints.search;
    final fetch = await _makeJsonRequestByEndpoint(endpoint, params);
    return fetch;
  }

  Future<dynamic> searchCountJson(IGDBRequestParameters params) async {
    const endpoint = IGDBEndpoints.search;
    final fetch = await _makeCountJsonRequestByEndpoint(endpoint, params);
    return fetch;
  }

  Future<Website?> websiteProto(IGDBRequestParameters params) async {
    const endpoint = IGDBEndpoints.websites;
    final fetch = await _makeProtoRequestByEndpoint(endpoint, params);
    if (fetch != null) {
      return Website.fromBuffer(fetch);
    } else {
      return null;
    }
  }

  Future<Count?> websiteCountProto(IGDBRequestParameters params) async {
    const endpoint = IGDBEndpoints.websites;
    final fetch = await _makeCountProtoRequestByEndpoint(endpoint, params);
    if (fetch != null) {
      return Count.fromBuffer(fetch);
    } else {
      return null;
    }
  }

  Future<dynamic> websiteJson(IGDBRequestParameters params) async {
    const endpoint = IGDBEndpoints.websites;
    final fetch = await _makeJsonRequestByEndpoint(endpoint, params);
    return fetch;
  }

  Future<dynamic> websiteCountJson(IGDBRequestParameters params) async {
    const endpoint = IGDBEndpoints.websites;
    final fetch = await _makeCountJsonRequestByEndpoint(endpoint, params);
    return fetch;
  }

  Future<Theme?> themeProto(IGDBRequestParameters params) async {
    const endpoint = IGDBEndpoints.themes;
    final fetch = await _makeProtoRequestByEndpoint(endpoint, params);
    if (fetch != null) {
      return Theme.fromBuffer(fetch);
    } else {
      return null;
    }
  }

  Future<Count?> themeCountProto(IGDBRequestParameters params) async {
    const endpoint = IGDBEndpoints.themes;
    final fetch = await _makeCountProtoRequestByEndpoint(endpoint, params);
    if (fetch != null) {
      return Count.fromBuffer(fetch);
    } else {
      return null;
    }
  }

  Future<dynamic> themeJson(IGDBRequestParameters params) async {
    const endpoint = IGDBEndpoints.themes;
    final fetch = await _makeJsonRequestByEndpoint(endpoint, params);
    return fetch;
  }

  Future<dynamic> themeCountJson(IGDBRequestParameters params) async {
    const endpoint = IGDBEndpoints.themes;
    final fetch = await _makeCountJsonRequestByEndpoint(endpoint, params);
    return fetch;
  }

  Future<MultiQueryResult?> multiQueryResultProto(
    IGDBRequestParameters params,
  ) async {
    const endpoint = IGDBEndpoints.multiquery;
    final fetch = await _makeProtoRequestByEndpoint(endpoint, params);
    if (fetch != null) {
      return MultiQueryResult.fromBuffer(fetch);
    } else {
      return null;
    }
  }

  Future<Count?> multiQueryResultCountProto(
    IGDBRequestParameters params,
  ) async {
    const endpoint = IGDBEndpoints.multiquery;
    final fetch = await _makeCountProtoRequestByEndpoint(endpoint, params);
    if (fetch != null) {
      return Count.fromBuffer(fetch);
    } else {
      return null;
    }
  }

  Future<dynamic> multiQueryResultJson(IGDBRequestParameters params) async {
    const endpoint = IGDBEndpoints.multiquery;
    final fetch = await _makeJsonRequestByEndpoint(endpoint, params);
    return fetch;
  }

  Future<dynamic> multiQueryResultCountJson(
    IGDBRequestParameters params,
  ) async {
    const endpoint = IGDBEndpoints.multiquery;
    final fetch = await _makeCountJsonRequestByEndpoint(endpoint, params);
    return fetch;
  }
}
