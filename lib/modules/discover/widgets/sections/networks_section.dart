import 'package:flutter/material.dart';
import 'package:zagreus/modules/discover/core/tmdb_api.dart';
import 'package:zagreus/router/routes/discover.dart';

class NetworksSection extends StatelessWidget {
  final bool showTitle;

  const NetworksSection({
    super.key,
    this.showTitle = true,
  });

  @override
  Widget build(BuildContext context) {
    final networks = TMDBApi.getNetworksList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showTitle)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Networks',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        if (showTitle) const SizedBox(height: 8),
        SizedBox(
          height: 80,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: networks.length,
            itemBuilder: (context, index) {
              final network = networks[index];
              return _NetworkCard(
                networkId: network['id'] as int,
                networkName: network['name'] as String,
                networkLogo: network['logo'] as String,
              );
            },
          ),
        ),
      ],
    );
  }
}

class _NetworkCard extends StatelessWidget {
  final int networkId;
  final String networkName;
  final String networkLogo;

  const _NetworkCard({
    required this.networkId,
    required this.networkName,
    required this.networkLogo,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: GestureDetector(
        onTap: () {
          DiscoverRoutes.NETWORK_DISCOVER.go(
            params: {'networkId': networkId.toString()},
            extra: {
              'networkName': networkName,
              'networkLogo': networkLogo,
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
                networkLogo,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Center(
                    child: Text(
                      networkName,
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
