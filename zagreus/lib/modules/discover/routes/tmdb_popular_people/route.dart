import 'dart:async';

import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/modules/discover/core/tmdb_api.dart';
import 'package:zagreus/modules/discover/routes/person_details/route.dart';

class TMDBPopularPeopleRoute extends StatefulWidget {
  final List<Map<String, dynamic>>? initialData;

  const TMDBPopularPeopleRoute({
    Key? key,
    this.initialData,
  }) : super(key: key);

  @override
  State<TMDBPopularPeopleRoute> createState() => _State();
}

class _State extends State<TMDBPopularPeopleRoute>
    with ZagScrollControllerMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  List<Map<String, dynamic>> _people = [];
  bool _isLoading = true;
  String? _error;
  int _currentPage = 1;
  bool _hasMorePages = true;
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialData?.isNotEmpty == true) {
      _people = List<Map<String, dynamic>>.from(widget.initialData!);
      _isLoading = false;
      Future.microtask(() {
        if (mounted) {
          _loadPopularPeople(silent: true);
        }
      });
    } else {
      _loadPopularPeople();
    }

    scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    scrollController.removeListener(_scrollListener);
    super.dispose();
  }

  void _scrollListener() {
    if (scrollController.position.pixels >=
        scrollController.position.maxScrollExtent - 200) {
      if (!_isLoadingMore && _hasMorePages) {
        _loadMorePeople();
      }
    }
  }

  Future<void> _loadPopularPeople({bool silent = false}) async {
    if (!silent) {
      setState(() {
        _isLoading = true;
        _error = null;
      });
    } else {
      _error = null;
    }

    try {
      final locale = Localizations.localeOf(context);
      final region = locale.countryCode ?? 'US';

      final people = await TMDBApi.getPopularPeople(page: 1, region: region);

      if (!mounted) return;
      setState(() {
        _people = people;
        _isLoading = false;
        _currentPage = 1;
        _error = null;
      });
    } catch (e) {
      if (!mounted) return;
      if (silent && _people.isNotEmpty) {
        return;
      }
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _loadMorePeople() async {
    if (_isLoadingMore || !_hasMorePages) return;

    setState(() {
      _isLoadingMore = true;
    });

    try {
      final locale = Localizations.localeOf(context);
      final region = locale.countryCode ?? 'US';

      final nextPage = _currentPage + 1;
      final newPeople =
          await TMDBApi.getPopularPeople(page: nextPage, region: region);

      if (newPeople.isEmpty) {
        setState(() {
          _hasMorePages = false;
          _isLoadingMore = false;
        });
        return;
      }

      setState(() {
        _people.addAll(newPeople);
        _currentPage = nextPage;
        _isLoadingMore = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingMore = false;
      });
      showZagErrorSnackBar(
        title: 'Failed to load more people',
        error: e,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ZagScaffold(
      scaffoldKey: _scaffoldKey,
      appBar: _appBar(),
      body: _body(),
    );
  }

  PreferredSizeWidget _appBar() {
    return ZagAppBar(
      title: 'Popular People',
      actions: [
        IconButton(
          icon: Icon(ZagIcons.REFRESH),
          onPressed: _loadPopularPeople,
        ),
      ],
    );
  }

  Widget _body() {
    if (_isLoading) {
      return Center(
        child: ZagLoader(),
      );
    }

    if (_error != null && _people.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 48,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              Text(
                'Failed to load popular people',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                _error!,
                style: TextStyle(
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadPopularPeople,
                child: Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_people.isEmpty) {
      return Center(
        child: Text('No people found'),
      );
    }

    final screenWidth = MediaQuery.sizeOf(context).width;
    final savedColumns = ZagreusDatabase.DISCOVER_COLUMNS_PER_ROW.read() ?? 3;
    final usesThreeColumns = savedColumns == 3;
    final horizontalPadding = usesThreeColumns ? 16.0 : 12.0;
    final gridSpacing = usesThreeColumns ? 16.0 : 12.0;

    return GridView.builder(
      controller: scrollController,
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: 16,
      ),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: savedColumns,
        childAspectRatio: 0.7,
        crossAxisSpacing: gridSpacing,
        mainAxisSpacing: gridSpacing,
      ),
      itemCount: _people.length + (_isLoadingMore ? 3 : 0),
      itemBuilder: (context, index) {
        if (index >= _people.length) {
          return Center(
            child: ZagLoader(),
          );
        }

        final person = _people[index];
        return _personCard(person);
      },
    );
  }

  Widget _personCard(Map<String, dynamic> person) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => PersonDetailsRoute(
              personId: person['id'],
              personName: person['name'],
            ),
          ),
        );
      },
      child: Column(
        children: [
          // Circular avatar
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey.shade800,
              border: Border.all(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white.withOpacity(0.1)
                    : Colors.black.withOpacity(0.1),
                width: 2,
              ),
            ),
            child: ClipOval(
              child: person['profilePath'] != null
                  ? Image.network(
                      person['profilePath'],
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return _personPlaceholder();
                      },
                    )
                  : _personPlaceholder(),
            ),
          ),
          const SizedBox(height: 8),
          // Name
          Text(
            person['name'] ?? 'Unknown',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : Colors.black87,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
          // Known for (department)
          if (person['knownForDepartment'] != null)
            Text(
              person['knownForDepartment'],
              style: TextStyle(
                fontSize: 10,
                color: (Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : Colors.black)
                    .withOpacity(0.5),
              ),
            ),
        ],
      ),
    );
  }

  Widget _personPlaceholder() {
    return Container(
      color: Colors.grey.shade700,
      child: Icon(
        Icons.person_rounded,
        size: 40,
        color: Colors.grey.shade500,
      ),
    );
  }
}
