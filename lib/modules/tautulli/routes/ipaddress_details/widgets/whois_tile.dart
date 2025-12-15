import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/modules/tautulli.dart';

class TautulliIPAddressDetailsWHOISTile extends StatelessWidget {
  final TautulliWHOISInfo whois;

  const TautulliIPAddressDetailsWHOISTile({
    Key? key,
    required this.whois,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ZagTableCard(
      content: [
        ZagTableContent(title: 'host', body: whois.host ?? ZagUI.TEXT_EMDASH),
        ..._subnets(),
      ],
    );
  }

  List<ZagTableContent> _subnets() {
    if (whois.subnets?.isEmpty ?? true) return [];
    return whois.subnets!.fold<List<ZagTableContent>>([], (list, subnet) {
      list.add(ZagTableContent(
        title: 'isp',
        body: [
          subnet.description ?? ZagUI.TEXT_EMDASH,
          '\n\n${subnet.address ?? ZagUI.TEXT_EMDASH}',
          '\n${subnet.city}, ${subnet.state ?? ZagUI.TEXT_EMDASH}',
          '\n${subnet.postalCode ?? ZagUI.TEXT_EMDASH}',
          '\n${subnet.country ?? ZagUI.TEXT_EMDASH}',
        ].join(),
      ));
      return list;
    });
  }
}
