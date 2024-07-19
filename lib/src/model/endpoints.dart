// ignore_for_file: constant_identifier_names
part of '../igdb_base.dart';

enum IGDBEndpoints {
  ageRatings._private('age_ratings'),
  ageRatingContentDescriptions._private('age_rating_content_descriptions'),
  alternativeNames._private('alternative_names'),
  artworks._private('artworks'),
  characters._private('characters'),
  characterMugShots._private('character_mug_shots'),
  collections._private('collections'),
  companies._private('companies'),
  companyLogos._private('company_logos'),
  companyWebsites._private('company_websites'),
  covers._private('covers'),
  externalGames._private('external_games'),
  franchises._private('franchises'),
  games._private('games'),
  gameEngines._private('game_engines'),
  gameEngineLogos._private('game_engine_logos'),
  gameLocalizations._private('game_localizations'),
  gameModes._private('game_modes'),
  gameVersions._private('game_versions'),
  gameVersionFeatures._private('game_version_features'),
  gameVersionFeatureValues._private('game_version_feature_values'),
  gameVideos._private('game_videos'),
  genres._private('genres'),
  involvedCompanies._private('involved_companies'),
  keywords._private('keywords'),
  languageSupports._private('language_supports'),
  languageSupportTypes._private('language_support_types'),
  languages._private('languages'),
  multiplayerModes._private('multiplayer_modes'),
  platforms._private('platforms'),
  platformFamilies._private('platform_families'),
  platformLogos._private('platform_logos'),
  platformVersions._private('platform_versions'),
  platformVersionCompanies._private('platform_version_companies'),
  platformVersionReleaseDates._private('platform_version_release_dates'),
  platformWebsites._private('platform_websites'),
  playerPerspectives._private('player_perspectives'),
  regions._private('regions'),
  releaseDates._private('release_dates'),
  releaseDateStatuses._private('release_date_statuses'),
  screenshots._private('screenshots'),
  search._private('search'),
  websites._private('websites'),
  themes._private('themes'),
  ;

  const IGDBEndpoints._private(this.value);
  final String value;

  @override
  String toString() => value;
}

enum IGDBMultiQueryEndpoint {
  multiquery._private('multiquery'),
  ;

  const IGDBMultiQueryEndpoint._private(this.value);
  final String value;

  @override
  String toString() => value;
}
