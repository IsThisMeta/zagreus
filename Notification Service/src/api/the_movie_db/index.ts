import { Constants, Logger } from '../../utils';
import * as API from './api';
import * as Cache from './cache';

const logger = Logger.child({ module: 'the_movie_db' });

const _constructImageURL = (path: string): string => {
  return `${Constants.THE_MOVIE_DB.IMAGE.BASE_URL}${Constants.THE_MOVIE_DB.IMAGE.SIZE}${path}`;
};

export const getMoviePoster = async (movieId: number): Promise<string | undefined> => {
  try {
    // Cache
    const cache = await Cache.getMoviePoster(movieId);
    if (cache) return _constructImageURL(cache);

    // API
    const api = await API.getMoviePoster(movieId);
    if (api) {
      Cache.setMoviePoster(movieId, api);
      return _constructImageURL(api);
    }
  } catch (error) {
    logger.error(error);
  }
  return undefined;
};

export const getSeriesPoster = async (seriesId: number): Promise<string | undefined> => {
  try {
    // Cache
    const cache = await Cache.getSeriesPoster(seriesId);
    if (cache) return _constructImageURL(cache);

    // API
    const api = await API.getSeriesPoster(seriesId);
    if (api) {
      Cache.setSeriesPoster(seriesId, api);
      return _constructImageURL(api);
    }
  } catch (error) {
    logger.error(error);
  }
  return undefined;
};
