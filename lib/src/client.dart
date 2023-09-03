part of 'igdb_base.dart';

class IGDBClient {
  IGDBClient({
    required this.clientId,
    required this.clientSecret,
  });
  final String clientId;
  final String clientSecret;

  final _tokenEndpoint = 'id.twitch.tv';

  final _http = NetworkTools.client;

  String? _bearerToken;
  DateTime? _tokenExpiryDateTime;

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
      final mapper = fetch.toJsonObjectAsMap;
      _bearerToken = mapper['access_token'] as String;
      final secToExpire = mapper['expires_in'] as int;
      _tokenExpiryDateTime = DateTime.now().add(Duration(seconds: secToExpire));
      return true;
    }
  }

  Future<String?> _fetchBearerToken() async {
    final uri = _apiUri(
      'token',
      authority: _tokenEndpoint,
      pathPrefix: '/oauth2/',
      queryParameters: {
        'client_id': clientId,
        'client_secret': clientSecret,
        'grant_type': 'client_credentials',
      },
    );
    return _http.postUri(uri);
  }

  Future<String?> _makeRequest(String path, String body) async {
    final isTokenValid = await _checkBearerToken();
    if (isTokenValid) {
      final uri = _apiUri(path);

      final headers = {
        'Client-ID': clientId,
        HttpHeaders.authorizationHeader: 'Bearer $_bearerToken',
        HttpHeaders.contentTypeHeader: Headers.formUrlEncodedContentType,
      };

      final options = NetworkTools.client.options..headers = headers;

      final post = await _http.postUri(
        uri,
        options: options,
        nonMultipartFormData: body,
      );

      return post;
    } else {
      return null;
    }
  }

  Future<String?> _makeRequestByEndpoint(
    IGDBEndpoints endpoints,
    IGDBRequestParameters params,
  ) async =>
      _makeRequest('$endpoints', '$params');

  Future<AgeRating?> ageRatings(IGDBRequestParameters params) async {
    const endpoint = IGDBEndpoints.ageRatings;
    final fetch = await _makeRequestByEndpoint(endpoint, params);
    if (fetch != null) {
      return AgeRating.fromJson(fetch);
    } else {
      return null;
    }
  }

  Future<AgeRatingContentDescription?> ageRatingContentDescriptions(
    IGDBRequestParameters params,
  ) async {
    const endpoint = IGDBEndpoints.ageRatingContentDescriptions;
    final fetch = await _makeRequestByEndpoint(endpoint, params);
    if (fetch != null) {
      return AgeRatingContentDescription.fromJson(fetch);
    } else {
      return null;
    }
  }

  Future<AlternativeName?> alternativeNames(
    IGDBRequestParameters params,
  ) async {
    const endpoint = IGDBEndpoints.alternativeNames;
    final fetch = await _makeRequestByEndpoint(endpoint, params);
    if (fetch != null) {
      return AlternativeName.fromJson(fetch);
    } else {
      return null;
    }
  }

  Future<Artwork?> artworks(IGDBRequestParameters params) async {
    const endpoint = IGDBEndpoints.artworks;
    final fetch = await _makeRequestByEndpoint(endpoint, params);
    if (fetch != null) {
      return Artwork.fromJson(fetch);
    } else {
      return null;
    }
  }

  Future<Character?> characters(IGDBRequestParameters params) async {
    const endpoint = IGDBEndpoints.characters;
    final fetch = await _makeRequestByEndpoint(endpoint, params);
    if (fetch != null) {
      return Character.fromJson(fetch);
    } else {
      return null;
    }
  }

  Future<CharacterMugShot?> characterMugShots(
    IGDBRequestParameters params,
  ) async {
    const endpoint = IGDBEndpoints.characterMugShots;
    final fetch = await _makeRequestByEndpoint(endpoint, params);
    if (fetch != null) {
      return CharacterMugShot.fromJson(fetch);
    } else {
      return null;
    }
  }

  Future<Collection?> collections(IGDBRequestParameters params) async {
    const endpoint = IGDBEndpoints.collections;
    final fetch = await _makeRequestByEndpoint(endpoint, params);
    if (fetch != null) {
      return Collection.fromJson(fetch);
    } else {
      return null;
    }
  }

  Future<Company?> companies(IGDBRequestParameters params) async {
    const endpoint = IGDBEndpoints.companies;
    final fetch = await _makeRequestByEndpoint(endpoint, params);
    if (fetch != null) {
      return Company.fromJson(fetch);
    } else {
      return null;
    }
  }

  Future<CompanyLogo?> companyLogos(IGDBRequestParameters params) async {
    const endpoint = IGDBEndpoints.companyLogos;
    final fetch = await _makeRequestByEndpoint(endpoint, params);
    if (fetch != null) {
      return CompanyLogo.fromJson(fetch);
    } else {
      return null;
    }
  }

  Future<CompanyWebsite?> companyWebsites(IGDBRequestParameters params) async {
    const endpoint = IGDBEndpoints.companyWebsites;
    final fetch = await _makeRequestByEndpoint(endpoint, params);
    if (fetch != null) {
      return CompanyWebsite.fromJson(fetch);
    } else {
      return null;
    }
  }

  Future<Cover?> covers(IGDBRequestParameters params) async {
    const endpoint = IGDBEndpoints.covers;
    final fetch = await _makeRequestByEndpoint(endpoint, params);
    if (fetch != null) {
      return Cover.fromJson(fetch);
    } else {
      return null;
    }
  }

  Future<ExternalGame?> externalGames(IGDBRequestParameters params) async {
    const endpoint = IGDBEndpoints.externalGames;
    final fetch = await _makeRequestByEndpoint(endpoint, params);
    if (fetch != null) {
      return ExternalGame.fromJson(fetch);
    } else {
      return null;
    }
  }

  Future<Franchise?> franchises(IGDBRequestParameters params) async {
    const endpoint = IGDBEndpoints.franchises;
    final fetch = await _makeRequestByEndpoint(endpoint, params);
    if (fetch != null) {
      return Franchise.fromJson(fetch);
    } else {
      return null;
    }
  }

  Future<Game?> games(IGDBRequestParameters params) async {
    const endpoint = IGDBEndpoints.games;
    final fetch = await _makeRequestByEndpoint(endpoint, params);
    if (fetch != null) {
      return Game.fromJson(fetch);
    } else {
      return null;
    }
  }

  Future<GameEngine?> gameEngines(IGDBRequestParameters params) async {
    const endpoint = IGDBEndpoints.gameEngines;
    final fetch = await _makeRequestByEndpoint(endpoint, params);
    if (fetch != null) {
      return GameEngine.fromJson(fetch);
    } else {
      return null;
    }
  }

  Future<GameEngineLogo?> gameEngineLogos(IGDBRequestParameters params) async {
    const endpoint = IGDBEndpoints.gameEngineLogos;
    final fetch = await _makeRequestByEndpoint(endpoint, params);
    if (fetch != null) {
      return GameEngineLogo.fromJson(fetch);
    } else {
      return null;
    }
  }

  Future<GameLocalization?> gameLocalizations(
    IGDBRequestParameters params,
  ) async {
    const endpoint = IGDBEndpoints.gameLocalizations;
    final fetch = await _makeRequestByEndpoint(endpoint, params);
    if (fetch != null) {
      return GameLocalization.fromJson(fetch);
    } else {
      return null;
    }
  }

  Future<GameMode?> gameModes(IGDBRequestParameters params) async {
    const endpoint = IGDBEndpoints.gameModes;
    final fetch = await _makeRequestByEndpoint(endpoint, params);
    if (fetch != null) {
      return GameMode.fromJson(fetch);
    } else {
      return null;
    }
  }

  Future<GameVersion?> gameVersions(IGDBRequestParameters params) async {
    const endpoint = IGDBEndpoints.gameVersions;
    final fetch = await _makeRequestByEndpoint(endpoint, params);
    if (fetch != null) {
      return GameVersion.fromJson(fetch);
    } else {
      return null;
    }
  }

  Future<GameVersionFeature?> gameVersionFeatures(
    IGDBRequestParameters params,
  ) async {
    const endpoint = IGDBEndpoints.gameVersionFeatures;
    final fetch = await _makeRequestByEndpoint(endpoint, params);
    if (fetch != null) {
      return GameVersionFeature.fromJson(fetch);
    } else {
      return null;
    }
  }

  Future<GameVersionFeatureValue?> gameVersionFeatureValues(
    IGDBRequestParameters params,
  ) async {
    const endpoint = IGDBEndpoints.gameVersionFeatureValues;
    final fetch = await _makeRequestByEndpoint(endpoint, params);
    if (fetch != null) {
      return GameVersionFeatureValue.fromJson(fetch);
    } else {
      return null;
    }
  }

  Future<GameVideo?> gameVideos(IGDBRequestParameters params) async {
    const endpoint = IGDBEndpoints.gameVideos;
    final fetch = await _makeRequestByEndpoint(endpoint, params);
    if (fetch != null) {
      return GameVideo.fromJson(fetch);
    } else {
      return null;
    }
  }

  Future<Genre?> genres(IGDBRequestParameters params) async {
    const endpoint = IGDBEndpoints.genres;
    final fetch = await _makeRequestByEndpoint(endpoint, params);
    if (fetch != null) {
      return Genre.fromJson(fetch);
    } else {
      return null;
    }
  }

  Future<InvolvedCompany?> involvedCompanies(
    IGDBRequestParameters params,
  ) async {
    const endpoint = IGDBEndpoints.involvedCompanies;
    final fetch = await _makeRequestByEndpoint(endpoint, params);
    if (fetch != null) {
      return InvolvedCompany.fromJson(fetch);
    } else {
      return null;
    }
  }

  Future<Keyword?> keywords(IGDBRequestParameters params) async {
    const endpoint = IGDBEndpoints.keywords;
    final fetch = await _makeRequestByEndpoint(endpoint, params);
    if (fetch != null) {
      return Keyword.fromJson(fetch);
    } else {
      return null;
    }
  }

  Future<LanguageSupport?> languageSupports(
    IGDBRequestParameters params,
  ) async {
    const endpoint = IGDBEndpoints.languageSupports;
    final fetch = await _makeRequestByEndpoint(endpoint, params);
    if (fetch != null) {
      return LanguageSupport.fromJson(fetch);
    } else {
      return null;
    }
  }

  Future<LanguageSupportType?> languageSupportTypes(
    IGDBRequestParameters params,
  ) async {
    const endpoint = IGDBEndpoints.languageSupportTypes;
    final fetch = await _makeRequestByEndpoint(endpoint, params);
    if (fetch != null) {
      return LanguageSupportType.fromJson(fetch);
    } else {
      return null;
    }
  }

  Future<Language?> languages(IGDBRequestParameters params) async {
    const endpoint = IGDBEndpoints.languages;
    final fetch = await _makeRequestByEndpoint(endpoint, params);
    if (fetch != null) {
      return Language.fromJson(fetch);
    } else {
      return null;
    }
  }

  Future<MultiplayerMode?> multiplayerModes(
    IGDBRequestParameters params,
  ) async {
    const endpoint = IGDBEndpoints.multiplayerModes;
    final fetch = await _makeRequestByEndpoint(endpoint, params);
    if (fetch != null) {
      return MultiplayerMode.fromJson(fetch);
    } else {
      return null;
    }
  }

  Future<Platform?> platforms(IGDBRequestParameters params) async {
    const endpoint = IGDBEndpoints.platforms;
    final fetch = await _makeRequestByEndpoint(endpoint, params);
    if (fetch != null) {
      return Platform.fromJson(fetch);
    } else {
      return null;
    }
  }

  Future<PlatformFamily?> platformFamilies(
    IGDBRequestParameters params,
  ) async {
    const endpoint = IGDBEndpoints.platformFamilies;
    final fetch = await _makeRequestByEndpoint(endpoint, params);
    if (fetch != null) {
      return PlatformFamily.fromJson(fetch);
    } else {
      return null;
    }
  }

  Future<PlatformLogo?> platformLogos(IGDBRequestParameters params) async {
    const endpoint = IGDBEndpoints.platformLogos;
    final fetch = await _makeRequestByEndpoint(endpoint, params);
    if (fetch != null) {
      return PlatformLogo.fromJson(fetch);
    } else {
      return null;
    }
  }

  Future<PlatformVersion?> platformVersions(
    IGDBRequestParameters params,
  ) async {
    const endpoint = IGDBEndpoints.platformVersions;
    final fetch = await _makeRequestByEndpoint(endpoint, params);
    if (fetch != null) {
      return PlatformVersion.fromJson(fetch);
    } else {
      return null;
    }
  }

  Future<PlatformVersionCompany?> platformVersionCompanies(
    IGDBRequestParameters params,
  ) async {
    const endpoint = IGDBEndpoints.platformVersionCompanies;
    final fetch = await _makeRequestByEndpoint(endpoint, params);
    if (fetch != null) {
      return PlatformVersionCompany.fromJson(fetch);
    } else {
      return null;
    }
  }

  Future<PlatformVersionReleaseDate?> platformVersionReleaseDates(
    IGDBRequestParameters params,
  ) async {
    const endpoint = IGDBEndpoints.platformVersionReleaseDates;
    final fetch = await _makeRequestByEndpoint(endpoint, params);
    if (fetch != null) {
      return PlatformVersionReleaseDate.fromJson(fetch);
    } else {
      return null;
    }
  }

  Future<PlatformWebsite?> platformWebsites(
    IGDBRequestParameters params,
  ) async {
    const endpoint = IGDBEndpoints.platformWebsites;
    final fetch = await _makeRequestByEndpoint(endpoint, params);
    if (fetch != null) {
      return PlatformWebsite.fromJson(fetch);
    } else {
      return null;
    }
  }

  Future<PlayerPerspective?> playerPerspectives(
    IGDBRequestParameters params,
  ) async {
    const endpoint = IGDBEndpoints.playerPerspectives;
    final fetch = await _makeRequestByEndpoint(endpoint, params);
    if (fetch != null) {
      return PlayerPerspective.fromJson(fetch);
    } else {
      return null;
    }
  }

  Future<Region?> regions(IGDBRequestParameters params) async {
    const endpoint = IGDBEndpoints.regions;
    final fetch = await _makeRequestByEndpoint(endpoint, params);
    if (fetch != null) {
      return Region.fromJson(fetch);
    } else {
      return null;
    }
  }

  Future<ReleaseDate?> releaseDates(IGDBRequestParameters params) async {
    const endpoint = IGDBEndpoints.releaseDates;
    final fetch = await _makeRequestByEndpoint(endpoint, params);
    if (fetch != null) {
      return ReleaseDate.fromJson(fetch);
    } else {
      return null;
    }
  }

  Future<ReleaseDateStatus?> releaseDateStatuses(
    IGDBRequestParameters params,
  ) async {
    const endpoint = IGDBEndpoints.releaseDateStatuses;
    final fetch = await _makeRequestByEndpoint(endpoint, params);
    if (fetch != null) {
      return ReleaseDateStatus.fromJson(fetch);
    } else {
      return null;
    }
  }

  Future<Screenshot?> screenshots(IGDBRequestParameters params) async {
    const endpoint = IGDBEndpoints.screenshots;
    final fetch = await _makeRequestByEndpoint(endpoint, params);
    if (fetch != null) {
      return Screenshot.fromJson(fetch);
    } else {
      return null;
    }
  }

  Future<Search?> search(IGDBRequestParameters params) async {
    const endpoint = IGDBEndpoints.search;
    final fetch = await _makeRequestByEndpoint(endpoint, params);
    if (fetch != null) {
      return Search.fromJson(fetch);
    } else {
      return null;
    }
  }

  Future<Website?> websites(IGDBRequestParameters params) async {
    const endpoint = IGDBEndpoints.websites;
    final fetch = await _makeRequestByEndpoint(endpoint, params);
    if (fetch != null) {
      return Website.fromJson(fetch);
    } else {
      return null;
    }
  }

  Future<Theme?> themes(IGDBRequestParameters params) async {
    const endpoint = IGDBEndpoints.themes;
    final fetch = await _makeRequestByEndpoint(endpoint, params);
    if (fetch != null) {
      return Theme.fromJson(fetch);
    } else {
      return null;
    }
  }

  Future<MultiQueryResult?> multiquery(IGDBRequestParameters params) async {
    const endpoint = IGDBEndpoints.multiquery;
    final fetch = await _makeRequestByEndpoint(endpoint, params);
    if (fetch != null) {
      return MultiQueryResult.fromJson(fetch);
    } else {
      return null;
    }
  }
}
