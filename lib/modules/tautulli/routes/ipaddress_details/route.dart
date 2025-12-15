import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/modules/tautulli.dart';

class IPDetailsRoute extends StatefulWidget {
  final String? ipAddress;

  const IPDetailsRoute({
    Key? key,
    required this.ipAddress,
  }) : super(key: key);

  @override
  State<IPDetailsRoute> createState() => _State();
}

class _State extends State<IPDetailsRoute> with ZagScrollControllerMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<RefreshIndicatorState> _refreshKey =
      GlobalKey<RefreshIndicatorState>();

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) =>
          TautulliIPAddressDetailsState(context, widget.ipAddress),
      builder: (context, _) => ZagScaffold(
        scaffoldKey: _scaffoldKey,
        appBar: _appBar() as PreferredSizeWidget?,
        body: _body(context),
      ),
    );
  }

  Widget _appBar() {
    return ZagAppBar(
      title: 'IP Address Details',
      scrollControllers: [scrollController],
    );
  }

  Widget _body(BuildContext context) {
    return ZagRefreshIndicator(
      context: context,
      key: _refreshKey,
      onRefresh: () async =>
          context.read<TautulliIPAddressDetailsState>().fetchAll(context),
      child: FutureBuilder(
        future: Future.wait([
          context.watch<TautulliIPAddressDetailsState>().geolocation!,
          context.watch<TautulliIPAddressDetailsState>().whois!,
        ]),
        builder: (context, AsyncSnapshot<List<Object>> snapshot) {
          if (snapshot.hasError) {
            if (snapshot.connectionState != ConnectionState.waiting)
              ZagLogger().error(
                'Unable to fetch Tautulli IP address information',
                snapshot.error,
                snapshot.stackTrace,
              );
            return ZagMessage.error(onTap: _refreshKey.currentState!.show);
          }
          if (snapshot.hasData)
            return _list(snapshot.data![0] as TautulliGeolocationInfo,
                snapshot.data![1] as TautulliWHOISInfo);
          return const ZagLoader();
        },
      ),
    );
  }

  Widget _list(TautulliGeolocationInfo geolocation, TautulliWHOISInfo whois) {
    return ZagListView(
      controller: scrollController,
      children: [
        const ZagHeader(text: 'Location'),
        TautulliIPAddressDetailsGeolocationTile(geolocation: geolocation),
        const ZagHeader(text: 'Connection'),
        TautulliIPAddressDetailsWHOISTile(whois: whois),
      ],
    );
  }
}
