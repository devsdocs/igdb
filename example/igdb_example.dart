import 'dart:io';

import 'package:igdb/igdb.dart';

void main() async {
  final clientId = Platform.environment['TWITCH_ID'];
  final clientSecret = Platform.environment['TWITCH_SECRET'];
  final client = IGDBClient(clientId!, clientSecret!);
  const igdbRequestParameters = IGDBRequestParameters(
    search: 'CS:GO',
  );

  final proto = await client.gameProto(
    igdbRequestParameters,
  );
  final countProto = await client.gameCountProto(
    igdbRequestParameters,
  );

  print(proto?.ageRatings);
  print(countProto?.toProto3Json());
}
