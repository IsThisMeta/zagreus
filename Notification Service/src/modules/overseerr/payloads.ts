import { Models } from './';
import { TheMovieDB } from '../../api';
import { Notifications } from '../../utils';

const title = (profile: string, body: string): string =>
  Notifications.generateTitle('Overseerr', profile, body);

export const mediaApproved = async (
  data: Models.RequestProperties,
  profile: string,
): Promise<Notifications.Payload> => {
  const header = data.event ?? 'Media Approved';
  const requester = data.request?.requestedBy_username ?? data.username;
  const body1 = data.subject;
  const body2 = `Originally Requested by ${requester}`;
  const image =
    data.media?.media_type === Models.MediaType.MOVIE
      ? await getMovieImageURL(data)
      : await getSeriesImageURL(data);

  return <Notifications.Payload>{
    title: title(profile, header),
    body: [body1, body2].join('\n'),
    image: image,
  };
};

export const mediaAutoApproved = async (
  data: Models.RequestProperties,
  profile: string,
): Promise<Notifications.Payload> => {
  const header = data.event ?? 'Media Auto Approved';
  const requester = data.request?.requestedBy_username ?? data.username;
  const body1 = data.subject;
  const body2 = `Originally Requested by ${requester}`;
  const image =
    data.media?.media_type === Models.MediaType.MOVIE
      ? await getMovieImageURL(data)
      : await getSeriesImageURL(data);

  return <Notifications.Payload>{
    title: title(profile, header),
    body: [body1, body2].join('\n'),
    image: image,
  };
};

export const mediaAvailable = async (
  data: Models.RequestProperties,
  profile: string,
): Promise<Notifications.Payload> => {
  const header = data.event ?? 'Media Available';
  const requester = data.request?.requestedBy_username ?? data.username;
  const body1 = data.subject;
  const body2 = `Originally Requested by ${requester}`;
  const image =
    data.media?.media_type === Models.MediaType.MOVIE
      ? await getMovieImageURL(data)
      : await getSeriesImageURL(data);

  return <Notifications.Payload>{
    title: title(profile, header),
    body: [body1, body2].join('\n'),
    image: image,
  };
};

export const mediaDeclined = async (
  data: Models.RequestProperties,
  profile: string,
): Promise<Notifications.Payload> => {
  const header = data.event ?? 'Media Declined';
  const requester = data.request?.requestedBy_username ?? data.username;
  const body1 = data.subject;
  const body2 = `Originally Requested by ${requester}`;
  const image =
    data.media?.media_type === Models.MediaType.MOVIE
      ? await getMovieImageURL(data)
      : await getSeriesImageURL(data);

  return <Notifications.Payload>{
    title: title(profile, header),
    body: [body1, body2].join('\n'),
    image: image,
  };
};

export const mediaFailed = async (
  data: Models.RequestProperties,
  profile: string,
): Promise<Notifications.Payload> => {
  const header = data.event ?? 'Media Failed';
  const requester = data.request?.requestedBy_username ?? data.username;
  const body1 = data.subject;
  const body2 = `Originally Requested by ${requester}`;
  const image =
    data.media?.media_type === Models.MediaType.MOVIE
      ? await getMovieImageURL(data)
      : await getSeriesImageURL(data);

  return <Notifications.Payload>{
    title: title(profile, header),
    body: [body1, body2].join('\n'),
    image: image,
  };
};

export const mediaPending = async (
  data: Models.RequestProperties,
  profile: string,
): Promise<Notifications.Payload> => {
  const header = data.event ?? 'Media Requested';
  const requester = data.request?.requestedBy_username ?? data.username;
  const body1 = data.subject;
  const body2 = `Originally Requested by ${requester}`;
  const image =
    data.media?.media_type === Models.MediaType.MOVIE
      ? await getMovieImageURL(data)
      : await getSeriesImageURL(data);

  return <Notifications.Payload>{
    title: title(profile, header),
    body: [body1, body2].join('\n'),
    image: image,
  };
};

export const issueCreated = async (
  data: Models.RequestProperties,
  profile: string,
): Promise<Notifications.Payload> => {
  const header = data.event ?? 'New Issue Reported';
  const body1 = data.subject;
  const body2 = data.message;
  const image =
    data.media?.media_type === Models.MediaType.MOVIE
      ? await getMovieImageURL(data)
      : await getSeriesImageURL(data);

  return <Notifications.Payload>{
    title: title(profile, header),
    body: [body1, body2].join('\n'),
    image: image,
  };
};

export const issueResolved = async (
  data: Models.RequestProperties,
  profile: string,
): Promise<Notifications.Payload> => {
  const header = data.event ?? 'Issue Resolved';
  const body1 = data.subject;
  const body2 = data.message;
  const image =
    data.media?.media_type === Models.MediaType.MOVIE
      ? await getMovieImageURL(data)
      : await getSeriesImageURL(data);

  return <Notifications.Payload>{
    title: title(profile, header),
    body: [body1, body2].join('\n'),
    image: image,
  };
};

export const issueReopened = async (
  data: Models.RequestProperties,
  profile: string,
): Promise<Notifications.Payload> => {
  const header = data.event ?? 'Issue Reopened';
  const body1 = data.subject;
  const body2 = data.message;
  const image =
    data.media?.media_type === Models.MediaType.MOVIE
      ? await getMovieImageURL(data)
      : await getSeriesImageURL(data);

  return <Notifications.Payload>{
    title: title(profile, header),
    body: [body1, body2].join('\n'),
    image: image,
  };
};

export const issueCommented = async (
  data: Models.RequestProperties,
  profile: string,
): Promise<Notifications.Payload> => {
  const header = data.event ?? 'New Comment on Issue';
  const body1 = data.subject;
  const body2 = data.comment?.comment_message;
  const image =
    data.media?.media_type === Models.MediaType.MOVIE
      ? await getMovieImageURL(data)
      : await getSeriesImageURL(data);

  return <Notifications.Payload>{
    title: title(profile, header),
    body: [body1, body2].join('\n'),
    image: image,
  };
};

export const test = async (
  data: Models.RequestProperties,
  profile: string,
): Promise<Notifications.Payload> => {
  return <Notifications.Payload>{
    title: title(profile, 'Connection Test'),
    body: 'Zagreus is ready for Overseerr notifications!',
  };
};

const getSeriesImageURL = async (data: Models.RequestProperties): Promise<string | undefined> => {
  if (data.media?.tvdbId) {
    const id = parseInt(data.media.tvdbId);
    if (!isNaN(id)) return await TheMovieDB.getSeriesPoster(id);
  }
  return undefined;
};

const getMovieImageURL = async (data: Models.RequestProperties): Promise<string | undefined> => {
  if (data.media?.tmdbId) {
    const id = parseInt(data.media.tmdbId);
    if (!isNaN(id)) return await TheMovieDB.getMoviePoster(id);
  }
  return undefined;
};
