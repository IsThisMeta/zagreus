export enum RedisExpirationMode {
  SECONDS = 'EX',
}

export interface RedisExpirationConfig {
  mode: RedisExpirationMode;
  ttl: number;
}

export const MESSAGE = {
  INTERNAL_SERVER_ERROR: 'Internal Server Error',
  NO_ID_SUPPLIED: 'No ID Supplied',
  NO_DEVICES_FOUND: 'No Devices Found',
  OK: 'OK',
  USER_NOT_FOUND: 'Invalid User ID',
};

export const REDIS = {
  EXPIRE: {
    DEVICES: <RedisExpirationConfig>{
      mode: RedisExpirationMode.SECONDS,
      ttl: 30,
    },
    IMAGE_CACHE: <RedisExpirationConfig>{
      mode: RedisExpirationMode.SECONDS,
      ttl: 60 * 60 * 24 * 7, // 7 Days
    },
  },
  PREFIX: {
    DEVICES: 'DEVICES',
    IMAGE_CACHE: 'IMAGE_CACHE',
  },
};

export const THE_MOVIE_DB = {
  API: {
    BASE_URL: 'https://api.themoviedb.org/3/',
  },
  IMAGE: {
    BASE_URL: 'https://image.tmdb.org/t/p/',
    SIZE: 'w780',
  },
};
