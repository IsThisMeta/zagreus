import axios from 'axios';
import { ContentResponse, ExternalSourceType, FindContentResponse } from './models';
import { Constants, Environment } from '../../utils';

const http = axios.create({
  method: 'GET',
  baseURL: Constants.THE_MOVIE_DB.API.BASE_URL,
  params: {
    api_key: Environment.THEMOVIEDB_API_KEY.read(),
  },
});

export const getMoviePoster = async (movieId: number): Promise<string | undefined> => {
  return http({
    url: `movie/${movieId}`,
  }).then((response): string | undefined => {
    const movie = response.data as ContentResponse;
    if (movie.poster_path) return movie.poster_path;
    if (movie.backdrop_path) return movie.backdrop_path;
    return undefined;
  });
};

export const getSeriesPoster = async (seriesId: number): Promise<string | undefined> => {
  return await http({
    url: `find/${seriesId}`,
    params: {
      external_source: ExternalSourceType.tvdbId,
    },
  }).then((response): string | undefined => {
    const data = response.data as FindContentResponse;
    if (data.tv_results && data.tv_results.length > 0) {
      const series = data.tv_results[0];
      if (series.poster_path) return series.poster_path;
      if (series.backdrop_path) return series.backdrop_path;
      return undefined;
    }
  });
};
