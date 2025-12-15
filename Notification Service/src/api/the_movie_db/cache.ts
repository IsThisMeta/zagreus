import { Redis } from '../../services';
import { Constants } from '../../utils';

const _keyBuilderSeries = (seriesId: number): string => {
  return `${Constants.REDIS.PREFIX.IMAGE_CACHE}:THE_MOVIE_DB:SERIES:${seriesId}`;
};
const _keyBuilderMovie = (movieId: number): string => {
  return `${Constants.REDIS.PREFIX.IMAGE_CACHE}:THE_MOVIE_DB:MOVIES:${movieId}`;
};

export const getMoviePoster = async (movieId: number): Promise<string | undefined> => {
  const key = _keyBuilderMovie(movieId);
  const res = await Redis.get(key);
  if (res) return res;
  return undefined;
};

export const setMoviePoster = async (movieId: number, url: string): Promise<boolean> => {
  const key = _keyBuilderMovie(movieId);
  const res = await Redis.set(key, url, Constants.REDIS.EXPIRE.IMAGE_CACHE);
  if (res) return true;
  return false;
};

export const getSeriesPoster = async (seriesId: number): Promise<string | undefined> => {
  const key = _keyBuilderSeries(seriesId);
  const res = await Redis.get(key);
  if (res) return res;
  return undefined;
};

export const setSeriesPoster = async (seriesId: number, url: string): Promise<boolean> => {
  const key = _keyBuilderSeries(seriesId);
  const res = await Redis.set(key, url, Constants.REDIS.EXPIRE.IMAGE_CACHE);
  if (res) return true;
  return false;
};
