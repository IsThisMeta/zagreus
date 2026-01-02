import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/modules/sonarr.dart';
import 'package:zagreus/modules/sonarr/routes/series_details/widgets/cast_crew_tile.dart';

class SonarrSeriesDetailsCastCrewPage extends StatefulWidget {
  final SonarrSeries? series;

  const SonarrSeriesDetailsCastCrewPage({
    Key? key,
    required this.series,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _State();
}

class _State extends State<SonarrSeriesDetailsCastCrewPage>
    with AutomaticKeepAliveClientMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<RefreshIndicatorState> _refreshKey =
      GlobalKey<RefreshIndicatorState>();

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return ZagScaffold(
      module: ZagModule.SONARR,
      scaffoldKey: _scaffoldKey,
      body: _body(),
    );
  }

  Widget _body() {
    return ZagRefreshIndicator(
      context: context,
      key: _refreshKey,
      onRefresh: () async =>
          context.read<SonarrSeriesDetailsState>().fetchCredits(context),
      child: FutureBuilder(
        future: context.watch<SonarrSeriesDetailsState>().credits,
        builder: (context, AsyncSnapshot<List<SonarrSeriesCredits>> snapshot) {
          if (snapshot.hasError) {
            ZagLogger().error(
                'Unable to fetch Sonarr credit/crew list: ${widget.series!.id}',
                snapshot.error,
                snapshot.stackTrace);
            return ZagMessage.error(onTap: _refreshKey.currentState!.show);
          }
          if (snapshot.hasData) return _list(snapshot.data);
          return const ZagLoader();
        },
      ),
    );
  }

  Widget _list(List<SonarrSeriesCredits>? credits) {
    if ((credits?.length ?? 0) == 0)
      return ZagMessage(
        text: 'sonarr.NoCreditsFound'.tr(),
        buttonText: 'zagreus.Refresh'.tr(),
        onTap: _refreshKey.currentState!.show,
      );
    List<SonarrSeriesCredits> _cast =
        credits!.where((credit) => credit.type == 'cast').toList();
    List<SonarrSeriesCredits> _crew =
        credits.where((credit) => credit.type == 'crew').toList();
    return ZagListView(
      controller: SonarrSeriesDetailsNavigationBar.scrollControllers[3],
      children: [
        ...List.generate(
            _cast.length,
            (index) =>
                SonarrSeriesDetailsCastCrewTile(credits: _cast[index])),
        ...List.generate(
            _crew.length,
            (index) =>
                SonarrSeriesDetailsCastCrewTile(credits: _crew[index])),
      ],
    );
  }
}
