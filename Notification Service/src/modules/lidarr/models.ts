export enum EventType {
  Test = 'Test',
  Grab = 'Grab',
  Rename = 'Rename',
  Retag = 'Retag',
  Download = 'Download',
}

export interface ArtistProperties {
  id?: number;
  name?: string;
  path?: string;
  mbId?: string;
}

export interface AlbumProperties {
  id?: number;
  title?: string;
  quality?: string;
  qualityVersion?: number;
  releaseDate?: string;
}

export interface TrackProperties {
  id?: number;
  title?: string;
  trackNumber?: string;
  quality?: string;
  qualityVersion?: number;
}

export interface TrackFileProperties {
  id?: number;
  path?: string;
  quality?: string;
  qualityVersion?: number;
  sceneName?: string;
}

export interface ReleaseProperties {
  quality?: string;
  qualityVersion?: number;
  releaseTitle?: string;
  indexer?: string;
  size?: number;
}

export interface TestEventType {
  eventType?: EventType;
  artist?: ArtistProperties;
  albums?: AlbumProperties[];
}

export interface GrabEventType {
  eventType?: EventType;
  artist?: ArtistProperties;
  albums?: AlbumProperties[];
  release?: ReleaseProperties;
}

export interface RenameEventType {
  eventType?: EventType;
  artist?: ArtistProperties;
}

export interface RetagEventType {
  eventType?: EventType;
  artist?: ArtistProperties;
}

export interface DownloadEventType {
  eventType?: EventType;
  artist?: ArtistProperties;
  tracks?: TrackProperties[];
  trackFiles?: TrackFileProperties[];
  isUpgrade?: boolean;
}
