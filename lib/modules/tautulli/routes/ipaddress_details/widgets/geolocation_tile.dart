import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/modules/tautulli.dart';

class TautulliIPAddressDetailsGeolocationTile extends StatelessWidget {
  final TautulliGeolocationInfo geolocation;

  const TautulliIPAddressDetailsGeolocationTile({
    Key? key,
    required this.geolocation,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ZagTableCard(
      content: [
        ZagTableContent(
            title: 'country', body: geolocation.country ?? ZagUI.TEXT_EMDASH),
        ZagTableContent(
            title: 'region', body: geolocation.region ?? ZagUI.TEXT_EMDASH),
        ZagTableContent(
            title: 'city', body: geolocation.city ?? ZagUI.TEXT_EMDASH),
        ZagTableContent(
            title: 'postal',
            body: geolocation.postalCode ?? ZagUI.TEXT_EMDASH),
        ZagTableContent(
            title: 'timezone',
            body: geolocation.timezone ?? ZagUI.TEXT_EMDASH),
        ZagTableContent(
            title: 'latitude',
            body: '${geolocation.latitude ?? ZagUI.TEXT_EMDASH}'),
        ZagTableContent(
            title: 'longitude',
            body: '${geolocation.longitude ?? ZagUI.TEXT_EMDASH}'),
      ],
    );
  }
}
