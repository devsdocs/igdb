import 'dart:io';

import 'package:igdb/igdb.dart';

void main() async {
  final clientId = Platform.environment['TWITCH_CLIENT'];
  final clientSecret = Platform.environment['TWITCH_SECRET'];
  final client = IGDBClient(clientId!, clientSecret!);
  const igdbRequestParameters = IGDBRequestParameters(
    search: 'CS:GO',
  );
  final json = await client.gameJson(
    igdbRequestParameters,
  );
  final countJson = await client.gameCountJson(
    igdbRequestParameters,
  );
  final proto = await client.gameProto(
    igdbRequestParameters,
  );
  final countProto = await client.gameCountProto(
    igdbRequestParameters,
  );
  print(json);
  print(countJson);
  print(proto?.toProto3Json());
  print(countProto?.toProto3Json());
}
