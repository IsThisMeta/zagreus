export enum EventType {
  Download = 'Download',
  EpisodeFileDelete = 'EpisodeFileDelete',
  Grab = 'Grab',
  Health = 'Health',
  Rename = 'Rename',
  SeriesDelete = 'SeriesDelete',
  Test = 'Test',
}

export enum SeriesType {
  Standard = 'standard',
  Anime = 'anime',
  Daily = 'daily',
}

export interface SeriesProperties {
  id?: number;
  title?: string;
  path?: string;
  type?: SeriesType;
  tvdbId?: number;
  tvMazeId?: number;
  imdbId?: string;
}

export interface EpisodeProperties {
  id?: number;
  episodeNumber?: number;
  seasonNumber?: number;
  title?: string;
  airDate?: string;
  airDateUtc?: string;
}

export interface ReleaseProperties {
  quality?: string;
  qualityVersion?: number;
  releaseGroup?: string;
  releaseTitle?: string;
  indexer?: string;
  size?: number;
}

export interface EpisodeFileProperties {
  id?: number;
  relativePath?: string;
  path?: string;
  quality?: string;
  qualityVersion?: number;
  releaseGroup?: string;
  sceneName?: string;
  size?: number;
}

export interface GrabEventType {
  eventType?: EventType;
  series?: SeriesProperties;
  episodes?: EpisodeProperties[];
  release?: ReleaseProperties;
  downloadClient?: string;
  downloadId?: string;
}

export interface DownloadEventType {
  eventType?: EventType;
  series?: SeriesProperties;
  episodes?: EpisodeProperties[];
  episodeFile?: EpisodeFileProperties;
  isUpgrade?: boolean;
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

export interface RenameEventType {
  eventType?: EventType;
  series?: SeriesProperties;
}

export interface TestEventType {
  eventType?: EventType;
  series?: SeriesProperties;
  episodes?: EpisodeProperties[];
}

export interface SeriesDeleteEventType {
  eventType?: EventType;
  series?: SeriesProperties;
  deletedFiles?: boolean;
}

export interface EpisodeFileDeleteEventType {
  eventType?: EventType;
  series?: SeriesProperties;
  episodes?: EpisodeProperties[];
}
