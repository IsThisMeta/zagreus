export enum ActionType {
  BufferWarning = 'buffer',
  PlaybackError = 'error',
  PlaybackPause = 'pause',
  PlaybackResume = 'resume',
  PlaybackStart = 'play',
  PlaybackStop = 'stop',
  PlexRemoteAccessBackUp = 'extup',
  PlexRemoteAccessDown = 'extdown',
  PlexServerBackUp = 'intup',
  PlexServerDown = 'intdown',
  PlexUpdateAvailable = 'pmsupdate',
  RecentlyAdded = 'created',
  TautulliDatabaseCorruption = 'plexpydbcorrupt',
  TautulliUpdateAvailable = 'plexpyupdate',
  TranscodeDecisionChange = 'change',
  UserConcurrentStreams = 'concurrent',
  UserNewDevice = 'newdevice',
  Watched = 'watched',
  Test = 'test',
}

export interface ActionTypePayload {
  action?: string;
  data?: ActionTypePayloadData;
}

export interface ActionTypePayloadData {
  message?: string;
  user?: string;
  user_id?: number;
  player?: string;
  title?: string;
  poster_url?: string;
  session_id?: string;
  session_key?: number;
  user_streams?: number;
  remote_access_reason?: string;
  update_version?: string;
  tautulli_update_version?: string;
}

export enum EventTypeDeprecated {
  BufferWarning = 'BufferWarning',
  PlaybackError = 'PlaybackError',
  PlaybackPause = 'PlaybackPause',
  PlaybackResume = 'PlaybackResume',
  PlaybackStart = 'PlaybackStart',
  PlaybackStop = 'PlaybackStop',
  PlexRemoteAccessBackUp = 'PlexRemoteAccessBackUp',
  PlexRemoteAccessDown = 'PlexRemoteAccessDown',
  PlexServerBackUp = 'PlexServerBackUp',
  PlexServerDown = 'PlexServerDown',
  PlexUpdateAvailable = 'PlexUpdateAvailable',
  RecentlyAdded = 'RecentlyAdded',
  TautulliDatabaseCorruption = 'TautulliDatabaseCorruption',
  TautulliUpdateAvailable = 'TautulliUpdateAvailable',
  TranscodeDecisionChange = 'TranscodeDecisionChange',
  UserConcurrentStreams = 'UserConcurrentStreams',
  UserNewDevice = 'UserNewDevice',
  Watched = 'Watched',
}

export interface BufferWarningEventTypeDeprecated {
  event_type?: EventTypeDeprecated;
  user?: string;
  user_id?: string;
  player?: string;
  title?: string;
  poster_url?: string;
  session_id?: string;
  session_key?: number;
  message?: string;
}

export interface PlaybackErrorEventTypeDeprecated {
  event_type?: EventTypeDeprecated;
  user?: string;
  user_id?: string;
  player?: string;
  title?: string;
  poster_url?: string;
  message?: string;
}

export interface PlaybackPauseEventTypeDeprecated {
  event_type?: EventTypeDeprecated;
  user?: string;
  user_id?: string;
  player?: string;
  title?: string;
  poster_url?: string;
  session_id?: string;
  session_key?: number;
  message?: string;
}

export interface PlaybackResumeEventTypeDeprecated {
  event_type?: EventTypeDeprecated;
  user?: string;
  user_id?: string;
  player?: string;
  title?: string;
  poster_url?: string;
  session_id?: string;
  session_key?: number;
  message?: string;
}

export interface PlaybackStartEventTypeDeprecated {
  event_type?: EventTypeDeprecated;
  user?: string;
  user_id?: string;
  player?: string;
  title?: string;
  poster_url?: string;
  session_id?: string;
  session_key?: number;
  message?: string;
}

export interface PlaybackStopEventTypeDeprecated {
  event_type?: EventTypeDeprecated;
  user?: string;
  user_id?: string;
  player?: string;
  title?: string;
  poster_url?: string;
  message?: string;
}

export interface PlexRemoteAccessBackUpEventTypeDeprecated {
  event_type?: EventTypeDeprecated;
  message?: string;
}

export interface PlexRemoteAccessDownEventTypeDeprecated {
  event_type?: EventTypeDeprecated;
  remote_access_reason?: string;
  message?: string;
}

export interface PlexServerDownEventTypeDeprecated {
  event_type?: EventTypeDeprecated;
  message?: string;
}

export interface PlexServerBackUpEventTypeDeprecated {
  event_type?: EventTypeDeprecated;
  message?: string;
}

export interface PlexUpdateAvailableEventTypeDeprecated {
  event_type?: EventTypeDeprecated;
  update_version?: string;
  message?: string;
}

export interface RecentlyAddedEventTypeDeprecated {
  event_type?: EventTypeDeprecated;
  title?: string;
  poster_url?: string;
  message?: string;
}

export interface TautulliUpdateAvailableEventTypeDeprecated {
  event_type?: EventTypeDeprecated;
  tautulli_update_version?: string;
  message?: string;
}

export interface TautulliDatabaseCorruptionEventTypeDeprecated {
  event_type?: EventTypeDeprecated;
  message?: string;
}

export interface TranscodeDecisionChangeEventTypeDeprecated {
  event_type?: EventTypeDeprecated;
  user?: string;
  user_id?: string;
  player?: string;
  title?: string;
  poster_url?: string;
  session_id?: string;
  session_key?: number;
  message?: string;
}

export interface UserConcurrentStreamsEventTypeDeprecated {
  event_type?: EventTypeDeprecated;
  user?: string;
  user_id?: string;
  user_streams?: string;
  message?: string;
}

export interface UserNewDeviceEventTypeDeprecated {
  event_type?: EventTypeDeprecated;
  user?: string;
  user_id?: string;
  player?: string;
  message?: string;
}

export interface WatchedEventTypeDeprecated {
  event_type?: EventTypeDeprecated;
  user?: string;
  user_id?: string;
  player?: string;
  title?: string;
  poster_url?: string;
  message?: string;
}
