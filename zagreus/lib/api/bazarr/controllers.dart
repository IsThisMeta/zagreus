/// Library containing all logic and accessors to make calls to Bazarr's API.
library bazarr_controllers;

import 'package:dio/dio.dart';
import 'package:zagreus/api/bazarr/models.dart';

// System
part 'controllers/system.dart';
part 'controllers/system/get_status.dart';

// Movie
part 'controllers/movie.dart';
part 'controllers/movie/get_movie.dart';

// Series
part 'controllers/series.dart';
part 'controllers/series/get_series.dart';

// Episode
part 'controllers/episode.dart';
part 'controllers/episode/get_episodes.dart';

// Provider (Subtitle Search/Download)
part 'controllers/provider.dart';
part 'controllers/provider/search_movie_subtitles.dart';
part 'controllers/provider/search_episode_subtitles.dart';
part 'controllers/provider/download_movie_subtitle.dart';
part 'controllers/provider/download_episode_subtitle.dart';

// Language
part 'controllers/language.dart';
part 'controllers/language/get_profiles.dart';
