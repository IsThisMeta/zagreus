import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/modules/lidarr.dart';

class LidarrRecentlyDownloadedAlbum {
  final int albumId;
  final int artistId;
  final String albumTitle;
  final String artistName;
  final String? coverUrl;
  final DateTime downloadedAt;

  LidarrRecentlyDownloadedAlbum({
    required this.albumId,
    required this.artistId,
    required this.albumTitle,
    required this.artistName,
    this.coverUrl,
    required this.downloadedAt,
  });
}

class LidarrRecentlyDownloadedCard extends StatelessWidget {
  final List<LidarrRecentlyDownloadedAlbum> albums;
  final VoidCallback? onSeeAll;
  final Function(LidarrRecentlyDownloadedAlbum)? onAlbumTap;

  const LidarrRecentlyDownloadedCard({
    Key? key,
    required this.albums,
    this.onSeeAll,
    this.onAlbumTap,
  }) : super(key: key);

  Color _sectionIconColor(BuildContext context) {
    final theme = Theme.of(context);
    return theme.brightness == Brightness.light ? Colors.black54 : Colors.white70;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLightTheme = theme.brightness == Brightness.light;
    const lidarrColor = Color(0xFF8B43E8); // Lidarr purple

    return Container(
      margin: const EdgeInsets.only(
        left: ZagUI.DEFAULT_MARGIN_SIZE,
        right: ZagUI.DEFAULT_MARGIN_SIZE,
        bottom: ZagUI.DEFAULT_MARGIN_SIZE,
      ),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(8),
        border: isLightTheme ? Border.all(color: Colors.black12) : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(
                ZagIcons.LIDARR,
                size: 18,
                color: lidarrColor,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'lidarr.RecentlyDownloadedAlbums'.tr(),
                  style: (theme.textTheme.titleMedium ?? const TextStyle()).copyWith(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: theme.textTheme.titleMedium?.color,
                  ),
                ),
              ),
              if (onSeeAll != null)
                TextButton(
                  onPressed: onSeeAll,
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    'lidarr.SeeAll'.tr(),
                    style: TextStyle(
                      color: lidarrColor,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          // Album list
          if (albums.isEmpty)
            SizedBox(
              height: 100,
              child: Center(
                child: Text(
                  'lidarr.NoRecentlyDownloadedAlbums'.tr(),
                  style: TextStyle(
                    color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
                    fontSize: 13,
                  ),
                ),
              ),
            )
          else
            SizedBox(
              height: 150,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: albums.length,
                itemBuilder: (context, index) {
                  final album = albums[index];
                  return _AlbumCard(
                    album: album,
                    onTap: onAlbumTap != null ? () => onAlbumTap!(album) : null,
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

class _AlbumCard extends StatelessWidget {
  final LidarrRecentlyDownloadedAlbum album;
  final VoidCallback? onTap;

  const _AlbumCard({
    Key? key,
    required this.album,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 110,
        margin: const EdgeInsets.only(right: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Album cover
            Container(
              height: 110,
              width: 110,
              decoration: BoxDecoration(
                color: Colors.grey.shade800,
                borderRadius: BorderRadius.circular(8),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: album.coverUrl != null
                    ? Image.network(
                        album.coverUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return _placeholder(theme);
                        },
                      )
                    : _placeholder(theme),
              ),
            ),
            const SizedBox(height: 6),
            // Album title
            Text(
              album.albumTitle,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: theme.textTheme.bodyMedium?.color,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            // Artist name
            Text(
              album.artistName,
              style: TextStyle(
                fontSize: 11,
                color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder(ThemeData theme) {
    return Container(
      color: Colors.grey.shade800,
      child: Center(
        child: Icon(
          Icons.album_rounded,
          size: 40,
          color: Colors.grey.shade600,
        ),
      ),
    );
  }
}
