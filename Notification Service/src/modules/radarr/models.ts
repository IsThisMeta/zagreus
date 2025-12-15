export enum EventType {
  Download = 'Download',
  Grab = 'Grab',
  Health = 'Health',
  Rename = 'Rename',
  MovieDelete = 'MovieDelete',
  MovieFileDelete = 'MovieFileDelete',
  Test = 'Test',
}

export interface MovieProperties {
  id?: number;
  title?: string;
  releaseDate?: string;
  folderPath?: string;
  year?: number;
  tmdbId?: number;
  imdbId?: string;
}

export interface RemoteMovieProperties {
  tmdbId?: number;
  imdbId?: string;
  title?: string;
  year?: number;
}

export interface ReleaseProperties {
  quality?: string;
  qualityVersion?: number;
  releaseGroup?: string;
  releaseTitle?: string;
  indexer?: string;
  size?: number;
}

export interface MovieFileProperties {
  id?: number;
  relativePath?: string;
  path?: string;
  quality?: string;
  qualityVersion?: number;
  indexerFlags?: string;
  releaseGroup?: string;
  sceneName?: string;
  size?: number;
}

export interface DownloadEventType {
  eventType?: EventType;
  movie?: MovieProperties;
  remoteMovie?: RemoteMovieProperties;
  movieFile?: MovieFileProperties;
  isUpgrade?: boolean;
  downloadId?: string;
}

export interface GrabEventType {
  eventType?: EventType;
  movie?: MovieProperties;
  remoteMovie?: RemoteMovieProperties;
  release?: ReleaseProperties;
  downloadClient?: string;
  downloadId?: string;
}

export interface HealthEventType {
  eventType?: EventType;
  level?: string;
  message?: string;
  type?: string;
  wikiUrl?: string;
}

export interface MovieDeleteEventType {
  eventType?: EventType;
  movie?: MovieProperties;
  deletedFiles?: boolean;
}

export interface MovieFileDeleteEventType {
  eventType?: EventType;
  movie?: MovieProperties;
  movieFile?: MovieFileProperties;
  deleteReason?: string;
}

export interface RenameEventType {
  eventType?: EventType;
  movie?: MovieProperties;
}

export interface TestEventType {
  eventType?: EventType;
  movie?: MovieProperties;
  remoteMovie?: RemoteMovieProperties;
  release?: ReleaseProperties;
}
