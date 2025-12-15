export enum ExternalSourceType {
  facebookId = 'facebook_id',
  freebaseId = 'freebase_id',
  freebaseMid = 'freebase_mid',
  imdbId = 'imdb_id',
  instagramId = 'instagram_id',
  tvdbId = 'tvdb_id',
  tvRageId = 'tvrage_id',
  twitterId = 'twitter_id',
}

export interface ContentResponse {
  backdrop_path?: string;
  poster_path?: string;
}

export interface FindContentResponse {
  movie_results: ContentResponse[];
  person_results: ContentResponse[];
  tv_results: ContentResponse[];
  tv_episode_results: ContentResponse[];
  tv_season_results: ContentResponse[];
}
