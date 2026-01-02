import 'package:flutter/material.dart';
import 'package:zagreus/modules/discover/core/tmdb_api.dart';
import 'package:zagreus/router/routes/discover.dart';

class StudiosSection extends StatelessWidget {
  final bool showTitle;

  const StudiosSection({
    super.key,
    this.showTitle = true,
  });

  @override
  Widget build(BuildContext context) {
    final studios = TMDBApi.getStudiosList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showTitle)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Studios',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        if (showTitle) const SizedBox(height: 12),
        SizedBox(
          height: 80,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: studios.length,
            itemBuilder: (context, index) {
              final studio = studios[index];
              return _StudioCard(
                studioId: studio['id'] as int,
                studioName: studio['name'] as String,
                studioLogo: studio['logo'] as String,
              );
            },
          ),
        ),
      ],
    );
  }
}

class _StudioCard extends StatelessWidget {
  final int studioId;
  final String studioName;
  final String studioLogo;

  const _StudioCard({
    required this.studioId,
    required this.studioName,
    required this.studioLogo,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: GestureDetector(
        onTap: () {
          DiscoverRoutes.STUDIO_DISCOVER.go(
            params: {'studioId': studioId.toString()},
            extra: {
              'studioName': studioName,
              'studioLogo': studioLogo,
            },
          );
        },
        child: Container(
          width: 120,
          height: 70,
          decoration: BoxDecoration(
            color: Colors.grey.shade900,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.grey.shade800,
              width: 1,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Image.network(
                studioLogo,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Center(
                    child: Text(
                      studioName,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
