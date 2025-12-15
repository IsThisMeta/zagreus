import { Models } from './';
import { Notifications } from '../../utils';

const createTitle = (profile: string, body: string): string =>
  Notifications.generateTitle('Tautulli', profile, body);
const moduleKey = 'tautulli';

export const bufferWarning = async (
  payload: Models.ActionTypePayload,
  profile: string,
): Promise<Notifications.Payload> => {
  const user = payload?.data?.user ?? 'Unknown User';
  const player = payload?.data?.player ?? 'Unknown Player';
  const title = payload?.data?.title ?? 'Unknown Content';
  const body = !payload?.data?.message?.length
    ? `${user} (${player}) is buffering ${title}`
    : payload?.data?.message;
  return <Notifications.Payload>{
    title: createTitle(profile, 'Buffer Warning'),
    body: body,
    image: !payload?.data?.poster_url ? undefined : payload?.data?.poster_url,
    data: {
      module: moduleKey,
      profile: profile,
      event: Models.EventTypeDeprecated.BufferWarning,
      user_id: String(payload?.data?.user_id ?? ''),
      session_id: payload?.data?.session_id ?? '',
      session_key: payload?.data?.session_key ?? '',
    },
  };
};

export const playbackError = async (
  payload: Models.ActionTypePayload,
  profile: string,
): Promise<Notifications.Payload> => {
  const user = payload?.data?.user ?? 'Unknown User';
  const player = payload?.data?.player ?? 'Unknown Player';
  const title = payload?.data?.title ?? 'Unknown Content';
  const body = !payload?.data?.message?.length
    ? `${user} (${player}) encountered an error trying to play ${title}`
    : payload?.data?.message;
  return <Notifications.Payload>{
    title: createTitle(profile, 'Playback Error'),
    body: body,
    image: !payload?.data?.poster_url ? undefined : payload?.data?.poster_url,
    data: {
      module: moduleKey,
      profile: profile,
      event: Models.EventTypeDeprecated.PlaybackError,
      user_id: String(payload?.data?.user_id ?? ''),
    },
  };
};

export const playbackPause = async (
  payload: Models.ActionTypePayload,
  profile: string,
): Promise<Notifications.Payload> => {
  const user = payload?.data?.user ?? 'Unknown User';
  const player = payload?.data?.player ?? 'Unknown Player';
  const title = payload?.data?.title ?? 'Unknown Content';
  const body = !payload?.data?.message?.length
    ? `${user} (${player}) has paused ${title}`
    : payload?.data?.message;
  return <Notifications.Payload>{
    title: createTitle(profile, 'Playback Paused'),
    body: body,
    image: !payload?.data?.poster_url ? undefined : payload?.data?.poster_url,
    data: {
      module: moduleKey,
      profile: profile,
      event: Models.EventTypeDeprecated.PlaybackPause,
      user_id: String(payload?.data?.user_id ?? ''),
      session_id: payload?.data?.session_id ?? '',
      session_key: payload?.data?.session_key ?? '',
    },
  };
};

export const playbackResume = async (
  payload: Models.ActionTypePayload,
  profile: string,
): Promise<Notifications.Payload> => {
  const user = payload?.data?.user ?? 'Unknown User';
  const player = payload?.data?.player ?? 'Unknown Player';
  const title = payload?.data?.title ?? 'Unknown Content';
  const body = !payload?.data?.message?.length
    ? `${user} (${player}) has resumed ${title}`
    : payload?.data?.message;
  return <Notifications.Payload>{
    title: createTitle(profile, 'Playback Resumed'),
    body: body,
    image: !payload?.data?.poster_url ? undefined : payload?.data?.poster_url,
    data: {
      module: moduleKey,
      profile: profile,
      event: Models.EventTypeDeprecated.PlaybackResume,
      user_id: String(payload?.data?.user_id ?? ''),
      session_id: payload?.data?.session_id ?? '',
      session_key: payload?.data?.session_key ?? '',
    },
  };
};

export const playbackStart = async (
  payload: Models.ActionTypePayload,
  profile: string,
): Promise<Notifications.Payload> => {
  const user = payload?.data?.user ?? 'Unknown User';
  const player = payload?.data?.player ?? 'Unknown Player';
  const title = payload?.data?.title ?? 'Unknown Content';
  const body = !payload?.data?.message?.length
    ? `${user} (${player}) started playing ${title}`
    : payload?.data?.message;
  return <Notifications.Payload>{
    title: createTitle(profile, 'Playback Started'),
    body: body,
    image: !payload?.data?.poster_url ? undefined : payload?.data?.poster_url,
    data: {
      module: moduleKey,
      profile: profile,
      event: Models.EventTypeDeprecated.PlaybackStart,
      user_id: String(payload?.data?.user_id ?? ''),
      session_id: payload?.data?.session_id ?? '',
      session_key: payload?.data?.session_key ?? '',
    },
  };
};

export const playbackStop = async (
  payload: Models.ActionTypePayload,
  profile: string,
): Promise<Notifications.Payload> => {
  const user = payload?.data?.user ?? 'Unknown User';
  const player = payload?.data?.player ?? 'Unknown Player';
  const title = payload?.data?.title ?? 'Unknown Content';
  const body = !payload?.data?.message?.length
    ? `${user} (${player}) has stopped ${title}`
    : payload?.data?.message;
  return <Notifications.Payload>{
    title: createTitle(profile, 'Playback Stopped'),
    body: body,
    image: !payload?.data?.poster_url ? undefined : payload?.data?.poster_url,
    data: {
      module: moduleKey,
      profile: profile,
      event: Models.EventTypeDeprecated.PlaybackStop,
      user_id: String(payload?.data?.user_id ?? ''),
      session_id: payload?.data?.session_id ?? '',
      session_key: payload?.data?.session_key ?? '',
    },
  };
};

export const plexRemoteAccessBackUp = async (
  payload: Models.ActionTypePayload,
  profile: string,
): Promise<Notifications.Payload> => {
  const body = !payload?.data?.message?.length
    ? 'The Plex Media Server remote access is back up'
    : payload?.data?.message;
  return <Notifications.Payload>{
    title: createTitle(profile, 'Plex Remote Access Back Up'),
    body: body,
    data: {
      module: moduleKey,
      profile: profile,
      event: Models.EventTypeDeprecated.PlexRemoteAccessBackUp,
    },
  };
};

export const plexRemoteAccessDown = async (
  payload: Models.ActionTypePayload,
  profile: string,
): Promise<Notifications.Payload> => {
  const reason = payload?.data?.remote_access_reason ?? 'Unknown Reason';
  const body = !payload?.data?.message?.length
    ? `The Plex Media Server remote access is down (${reason})`
    : payload?.data?.message;
  return <Notifications.Payload>{
    title: createTitle(profile, 'Plex Remote Access Down'),
    body: body,
    data: {
      module: moduleKey,
      profile: profile,
      event: Models.EventTypeDeprecated.PlexRemoteAccessDown,
    },
  };
};

export const plexServerBackUp = async (
  payload: Models.ActionTypePayload,
  profile: string,
): Promise<Notifications.Payload> => {
  const body = !payload?.data?.message?.length
    ? 'The Plex Media Server is back up'
    : payload?.data?.message;
  return <Notifications.Payload>{
    title: createTitle(profile, 'Plex Server Back Up'),
    body: body,
    data: {
      module: moduleKey,
      profile: profile,
      event: Models.EventTypeDeprecated.PlexServerBackUp,
    },
  };
};

export const plexServerDown = async (
  payload: Models.ActionTypePayload,
  profile: string,
): Promise<Notifications.Payload> => {
  const body = !payload?.data?.message?.length
    ? 'The Plex Media Server is down'
    : payload?.data?.message;
  return <Notifications.Payload>{
    title: createTitle(profile, 'Plex Server Down'),
    body: body,
    data: {
      module: moduleKey,
      profile: profile,
      event: Models.EventTypeDeprecated.PlexServerDown,
    },
  };
};

export const plexUpdateAvailable = async (
  payload: Models.ActionTypePayload,
  profile: string,
): Promise<Notifications.Payload> => {
  const version = payload?.data?.update_version ?? 'Unknown Version';
  const body = !payload?.data?.message?.length
    ? `An update is available for the Plex Media Server (version ${version})`
    : payload?.data?.message;
  return <Notifications.Payload>{
    title: createTitle(profile, 'Plex Update Available'),
    body: body,
    data: {
      module: moduleKey,
      profile: profile,
      event: Models.EventTypeDeprecated.PlexUpdateAvailable,
    },
  };
};

export const recentlyAdded = async (
  payload: Models.ActionTypePayload,
  profile: string,
): Promise<Notifications.Payload> => {
  const title = payload?.data?.title ?? 'Unknown Content';
  const body = !payload?.data?.message?.length
    ? `${title} was recently added to Plex`
    : payload?.data?.message;
  return <Notifications.Payload>{
    title: createTitle(profile, 'Recently Added'),
    body: body,
    image: !payload?.data?.poster_url ? undefined : payload?.data?.poster_url,
    data: {
      module: moduleKey,
      profile: profile,
      event: Models.EventTypeDeprecated.RecentlyAdded,
    },
  };
};

export const tautulliDatabaseCorruption = async (
  payload: Models.ActionTypePayload,
  profile: string,
): Promise<Notifications.Payload> => {
  const body = !payload?.data?.message?.length
    ? `Tautulli database corruption detected: Automatic cleanup of database backups is suspended`
    : payload?.data?.message;
  return <Notifications.Payload>{
    title: createTitle(profile, 'Tautulli Database Corruption'),
    body: body,
    data: {
      module: moduleKey,
      profile: profile,
      event: Models.EventTypeDeprecated.TautulliDatabaseCorruption,
    },
  };
};

export const tautulliUpdateAvailable = async (
  payload: Models.ActionTypePayload,
  profile: string,
): Promise<Notifications.Payload> => {
  const version = payload?.data?.tautulli_update_version ?? 'Unknown Version';
  const body = !payload?.data?.message?.length
    ? `An update is available for Tautulli (version ${version})`
    : payload?.data?.message;
  return <Notifications.Payload>{
    title: createTitle(profile, 'Tautulli Update Available'),
    body: body,
    data: {
      module: moduleKey,
      profile: profile,
      event: Models.EventTypeDeprecated.TautulliUpdateAvailable,
    },
  };
};

export const test = async (
  payload: Models.ActionTypePayload,
  profile: string,
): Promise<Notifications.Payload> => {
  return <Notifications.Payload>{
    title: createTitle(profile, 'Connection Test'),
    body: 'Zagreus is ready for Tautulli notifications!',
    image: !payload?.data?.poster_url ? undefined : payload?.data?.poster_url,
    data: {
      module: moduleKey,
      profile: profile,
      event: Models.EventTypeDeprecated.PlaybackStop,
      user_id: 'test',
    },
  };
};

export const transcodeDecisionChange = async (
  payload: Models.ActionTypePayload,
  profile: string,
): Promise<Notifications.Payload> => {
  const user = payload?.data?.user ?? 'Unknown User';
  const player = payload?.data?.player ?? 'Unknown Player';
  const title = payload?.data?.title ?? 'Unknown Content';
  const body = !payload?.data?.message?.length
    ? `${user} (${player}) has changed transcode decision for ${title}`
    : payload?.data?.message;
  return <Notifications.Payload>{
    title: createTitle(profile, 'Transcode Decision Changed'),
    body: body,
    image: !payload?.data?.poster_url ? undefined : payload?.data?.poster_url,
    data: {
      module: moduleKey,
      profile: profile,
      event: Models.EventTypeDeprecated.TranscodeDecisionChange,
      user_id: String(payload?.data?.user_id ?? ''),
      session_id: payload?.data?.session_id ?? '',
      session_key: payload?.data?.session_key ?? '',
    },
  };
};

export const userConcurrentStreams = async (
  payload: Models.ActionTypePayload,
  profile: string,
): Promise<Notifications.Payload> => {
  const user = payload?.data?.user ?? 'Unknown User';
  const streams = payload?.data?.user_streams ?? '??';
  const body = !payload?.data?.message?.length
    ? `${user} has ${streams} concurrent streams`
    : payload?.data?.message;
  return <Notifications.Payload>{
    title: createTitle(profile, 'User Concurrent Streams'),
    body: body,
    data: {
      module: moduleKey,
      profile: profile,
      event: Models.EventTypeDeprecated.UserConcurrentStreams,
      user_id: String(payload?.data?.user_id ?? ''),
    },
  };
};

export const userNewDevice = async (
  payload: Models.ActionTypePayload,
  profile: string,
): Promise<Notifications.Payload> => {
  const user = payload?.data?.user ?? 'Unknown User';
  const player = payload?.data?.player ?? 'Unknown Player';
  const body = !payload?.data?.message?.length
    ? `${user} is streaming from a new device: ${player}`
    : payload?.data?.message;
  return <Notifications.Payload>{
    title: createTitle(profile, 'User New Device'),
    body: body,
    data: {
      module: moduleKey,
      profile: profile,
      event: Models.EventTypeDeprecated.UserNewDevice,
      user_id: String(payload?.data?.user_id ?? ''),
    },
  };
};

export const watched = async (
  payload: Models.ActionTypePayload,
  profile: string,
): Promise<Notifications.Payload> => {
  const user = payload?.data?.user ?? 'Unknown User';
  const player = payload?.data?.player ?? 'Unknown Player';
  const title = payload?.data?.title ?? 'Unknown Content';
  const body = !payload?.data?.message?.length
    ? `${user} (${player}) has watched ${title}`
    : payload?.data?.message;
  return <Notifications.Payload>{
    title: createTitle(profile, 'Watched'),
    body: body,
    image: !payload?.data?.poster_url ? undefined : payload?.data?.poster_url,
    data: {
      module: moduleKey,
      profile: profile,
      event: Models.EventTypeDeprecated.Watched,
      user_id: String(payload?.data?.user_id ?? ''),
    },
  };
};

export const bufferWarningDeprecated = async (
  data: Models.BufferWarningEventTypeDeprecated,
  profile: string,
): Promise<Notifications.Payload> => {
  const user = data.user ?? 'Unknown User';
  const player = data.player ?? 'Unknown Player';
  const title = data.title ?? 'Unknown Content';
  const body =
    (data.message?.length ?? 0) == 0 ? `${user} (${player}) is buffering ${title}` : data.message;
  return <Notifications.Payload>{
    title: createTitle(profile, 'Buffer Warning'),
    body: body,
    image: !data.poster_url ? undefined : data.poster_url,
    data: {
      module: moduleKey,
      profile: profile,
      event: data.event_type,
      user_id: data.user_id ?? '',
      session_id: data.session_id ?? '',
      session_key: data.session_key ?? '',
    },
  };
};

export const playbackErrorDeprecated = async (
  data: Models.PlaybackErrorEventTypeDeprecated,
  profile: string,
): Promise<Notifications.Payload> => {
  const user = data.user ?? 'Unknown User';
  const player = data.player ?? 'Unknown Player';
  const title = data.title ?? 'Unknown Content';
  const body =
    (data.message?.length ?? 0) == 0
      ? `${user} (${player}) encountered an error trying to play ${title}`
      : data.message;
  return <Notifications.Payload>{
    title: createTitle(profile, 'Playback Error'),
    body: body,
    image: !data.poster_url ? undefined : data.poster_url,
    data: {
      module: moduleKey,
      profile: profile,
      event: data.event_type,
      user_id: data.user_id ?? '',
    },
  };
};

export const playbackPauseDeprecated = async (
  data: Models.PlaybackPauseEventTypeDeprecated,
  profile: string,
): Promise<Notifications.Payload> => {
  const user = data.user ?? 'Unknown User';
  const player = data.player ?? 'Unknown Player';
  const title = data.title ?? 'Unknown Content';
  const body =
    (data.message?.length ?? 0) == 0 ? `${user} (${player}) has paused ${title}` : data.message;
  return <Notifications.Payload>{
    title: createTitle(profile, 'Playback Paused'),
    body: body,
    image: !data.poster_url ? undefined : data.poster_url,
    data: {
      module: moduleKey,
      profile: profile,
      event: data.event_type,
      user_id: data.user_id ?? '',
      session_id: data.session_id ?? '',
      session_key: data.session_key ?? '',
    },
  };
};

export const playbackResumeDeprecated = async (
  data: Models.PlaybackResumeEventTypeDeprecated,
  profile: string,
): Promise<Notifications.Payload> => {
  const user = data.user ?? 'Unknown User';
  const player = data.player ?? 'Unknown Player';
  const title = data.title ?? 'Unknown Content';
  const body =
    (data.message?.length ?? 0) == 0 ? `${user} (${player}) has resumed ${title}` : data.message;
  return <Notifications.Payload>{
    title: createTitle(profile, 'Playback Resumed'),
    body: body,
    image: !data.poster_url ? undefined : data.poster_url,
    data: {
      module: moduleKey,
      profile: profile,
      event: data.event_type,
      user_id: data.user_id ?? '',
      session_id: data.session_id ?? '',
      session_key: data.session_key ?? '',
    },
  };
};

export const playbackStartDeprecated = async (
  data: Models.PlaybackStartEventTypeDeprecated,
  profile: string,
): Promise<Notifications.Payload> => {
  const user = data.user ?? 'Unknown User';
  const player = data.player ?? 'Unknown Player';
  const title = data.title ?? 'Unknown Content';
  const body =
    (data.message?.length ?? 0) == 0
      ? `${user} (${player}) started playing ${title}`
      : data.message;
  return <Notifications.Payload>{
    title: createTitle(profile, 'Playback Started'),
    body: body,
    image: !data.poster_url ? undefined : data.poster_url,
    data: {
      module: moduleKey,
      profile: profile,
      event: data.event_type,
      user_id: data.user_id ?? '',
      session_id: data.session_id ?? '',
      session_key: data.session_key ?? '',
    },
  };
};

export const playbackStopDeprecated = async (
  data: Models.PlaybackStopEventTypeDeprecated,
  profile: string,
): Promise<Notifications.Payload> => {
  const user = data.user ?? 'Unknown User';
  const player = data.player ?? 'Unknown Player';
  const title = data.title ?? 'Unknown Content';
  const body =
    (data.message?.length ?? 0) == 0 ? `${user} (${player}) has stopped ${title}` : data.message;
  return <Notifications.Payload>{
    title: createTitle(profile, 'Playback Stopped'),
    body: body,
    image: !data.poster_url ? undefined : data.poster_url,
    data: {
      module: moduleKey,
      profile: profile,
      event: data.event_type,
      user_id: data.user_id ?? '',
    },
  };
};

export const plexRemoteAccessBackUpDeprecated = async (
  data: Models.PlexRemoteAccessBackUpEventTypeDeprecated,
  profile: string,
): Promise<Notifications.Payload> => {
  const body =
    (data.message?.length ?? 0) == 0
      ? 'The Plex Media Server remote access is back up'
      : data.message;
  return <Notifications.Payload>{
    title: createTitle(profile, 'Plex Remote Access Back Up'),
    body: body,
    data: {
      module: moduleKey,
      profile: profile,
      event: data.event_type,
    },
  };
};

export const plexRemoteAccessDownDeprecated = async (
  data: Models.PlexRemoteAccessDownEventTypeDeprecated,
  profile: string,
): Promise<Notifications.Payload> => {
  const reason = data.remote_access_reason ?? 'Unknown Reason';
  const body =
    (data.message?.length ?? 0) == 0
      ? `The Plex Media Server remote access is down (${reason})`
      : data.message;
  return <Notifications.Payload>{
    title: createTitle(profile, 'Plex Remote Access Down'),
    body: body,
    data: {
      module: moduleKey,
      profile: profile,
      event: data.event_type,
    },
  };
};

export const plexServerBackUpDeprecated = async (
  data: Models.PlexServerBackUpEventTypeDeprecated,
  profile: string,
): Promise<Notifications.Payload> => {
  const body = (data.message?.length ?? 0) == 0 ? 'The Plex Media Server is back up' : data.message;
  return <Notifications.Payload>{
    title: createTitle(profile, 'Plex Server Back Up'),
    body: body,
    data: {
      module: moduleKey,
      profile: profile,
      event: data.event_type,
    },
  };
};

export const plexServerDownDeprecated = async (
  data: Models.PlexServerDownEventTypeDeprecated,
  profile: string,
): Promise<Notifications.Payload> => {
  const body = (data.message?.length ?? 0) == 0 ? 'The Plex Media Server is down' : data.message;
  return <Notifications.Payload>{
    title: createTitle(profile, 'Plex Server Down'),
    body: body,
    data: {
      module: moduleKey,
      profile: profile,
      event: data.event_type,
    },
  };
};

export const plexUpdateAvailableDeprecated = async (
  data: Models.PlexUpdateAvailableEventTypeDeprecated,
  profile: string,
): Promise<Notifications.Payload> => {
  const version = data.update_version ?? 'Unknown Version';
  const body =
    (data.message?.length ?? 0) == 0
      ? `An update is available for the Plex Media Server (version ${version})`
      : data.message;
  return <Notifications.Payload>{
    title: createTitle(profile, 'Plex Update Available'),
    body: body,
    data: {
      module: moduleKey,
      profile: profile,
      event: data.event_type,
    },
  };
};

export const recentlyAddedDeprecated = async (
  data: Models.RecentlyAddedEventTypeDeprecated,
  profile: string,
): Promise<Notifications.Payload> => {
  const title = data.title ?? 'Unknown Content';
  const body =
    (data.message?.length ?? 0) == 0 ? `${title} was recently added to Plex` : data.message;
  return <Notifications.Payload>{
    title: createTitle(profile, 'Recently Added'),
    body: body,
    image: !data.poster_url ? undefined : data.poster_url,
    data: {
      module: moduleKey,
      profile: profile,
      event: data.event_type,
    },
  };
};

export const tautulliDatabaseCorruptionDeprecated = async (
  data: Models.TautulliDatabaseCorruptionEventTypeDeprecated,
  profile: string,
): Promise<Notifications.Payload> => {
  const body =
    (data.message?.length ?? 0) == 0
      ? `Tautulli database corruption detected: Automatic cleanup of database backups is suspended`
      : data.message;
  return <Notifications.Payload>{
    title: createTitle(profile, 'Tautulli Database Corruption'),
    body: body,
    data: {
      module: moduleKey,
      profile: profile,
      event: data.event_type,
    },
  };
};

export const tautulliUpdateAvailableDeprecated = async (
  data: Models.TautulliUpdateAvailableEventTypeDeprecated,
  profile: string,
): Promise<Notifications.Payload> => {
  const version = data.tautulli_update_version ?? 'Unknown Version';
  const body =
    (data.message?.length ?? 0) == 0
      ? `An update is available for Tautulli (version ${version})`
      : data.message;
  return <Notifications.Payload>{
    title: createTitle(profile, 'Tautulli Update Available'),
    body: body,
    data: {
      module: moduleKey,
      profile: profile,
      event: data.event_type,
    },
  };
};

export const transcodeDecisionChangeDeprecated = async (
  data: Models.TranscodeDecisionChangeEventTypeDeprecated,
  profile: string,
): Promise<Notifications.Payload> => {
  const user = data.user ?? 'Unknown User';
  const player = data.player ?? 'Unknown Player';
  const title = data.title ?? 'Unknown Content';
  const body =
    (data.message?.length ?? 0) == 0
      ? `${user} (${player}) has changed transcode decision for ${title}`
      : data.message;
  return <Notifications.Payload>{
    title: createTitle(profile, 'Transcode Decision Changed'),
    body: body,
    image: !data.poster_url ? undefined : data.poster_url,
    data: {
      module: moduleKey,
      profile: profile,
      event: data.event_type,
      user_id: data.user_id ?? '',
      session_id: data.session_id ?? '',
      session_key: data.session_key ?? '',
    },
  };
};

export const userConcurrentStreamsDeprecated = async (
  data: Models.UserConcurrentStreamsEventTypeDeprecated,
  profile: string,
): Promise<Notifications.Payload> => {
  const user = data.user ?? 'Unknown User';
  const streams = data.user_streams ?? '??';
  const body =
    (data.message?.length ?? 0) == 0 ? `${user} has ${streams} concurrent streams` : data.message;
  return <Notifications.Payload>{
    title: createTitle(profile, 'User Concurrent Streams'),
    body: body,
    data: {
      module: moduleKey,
      profile: profile,
      event: data.event_type,
      user_id: data.user_id ?? '',
    },
  };
};

export const userNewDeviceDeprecated = async (
  data: Models.UserNewDeviceEventTypeDeprecated,
  profile: string,
): Promise<Notifications.Payload> => {
  const user = data.user ?? 'Unknown User';
  const player = data.player ?? 'Unknown Player';
  const body =
    (data.message?.length ?? 0) == 0
      ? `${user} is streaming from a new device: ${player}`
      : data.message;
  return <Notifications.Payload>{
    title: createTitle(profile, 'User New Device'),
    body: body,
    data: {
      module: moduleKey,
      profile: profile,
      event: data.event_type,
      user_id: data.user_id ?? '',
    },
  };
};

export const watchedDeprecated = async (
  data: Models.WatchedEventTypeDeprecated,
  profile: string,
): Promise<Notifications.Payload> => {
  const user = data.user ?? 'Unknown User';
  const player = data.player ?? 'Unknown Player';
  const title = data.title ?? 'Unknown Content';
  const body =
    (data.message?.length ?? 0) == 0 ? `${user} (${player}) has watched ${title}` : data.message;
  return <Notifications.Payload>{
    title: createTitle(profile, 'Watched'),
    body: body,
    image: !data.poster_url ? undefined : data.poster_url,
    data: {
      module: moduleKey,
      profile: profile,
      event: data.event_type,
      user_id: data.user_id ?? '',
    },
  };
};
