import { Models } from './';
import { TheMovieDB } from '../../api';
import { Notifications } from '../../utils';

const title = (profile: string, body: string): string =>
  Notifications.generateTitle('Sonarr', profile, body);
const moduleKey = 'sonarr';

export const deleteEpisodeFile = async (
  data: Models.EpisodeFileDeleteEventType,
  profile: string,
): Promise<Notifications.Payload> => {
  const body1 =
    data.episodes?.length == 1
      ? `Season ${data.episodes[0].seasonNumber} – Episode ${data.episodes[0].episodeNumber}`
      : `${data.episodes?.length ?? 0} Episodes`;
  const body2 = 'Files Deleted';
  const image = data.series?.tvdbId
    ? await TheMovieDB.getSeriesPoster(data.series.tvdbId)
    : undefined;
  return <Notifications.Payload>{
    title: title(profile, data.series?.title ?? 'Unknown Series'),
    body: [body1, body2].join('\n'),
    image: image,
    data: {
      module: moduleKey,
      profile: profile,
      event: data.eventType,
      seriesId: data.series?.id?.toString() ?? '-1',
      seasonNumber:
        data.episodes && data.episodes.length > 0
          ? data.episodes[0]?.seasonNumber?.toString() ?? '-1'
          : '-1',
    },
  };
};

export const deleteSeries = async (
  data: Models.SeriesDeleteEventType,
  profile: string,
): Promise<Notifications.Payload> => {
  let body = 'Series Deleted';
  if (data.deletedFiles) body += ' (With Files)';
  const image = data.series?.tvdbId
    ? await TheMovieDB.getSeriesPoster(data.series.tvdbId)
    : undefined;
  return <Notifications.Payload>{
    title: title(profile, data.series?.title ?? 'Unknown Series'),
    body: body,
    image: image,
    data: {
      module: moduleKey,
      profile: profile,
      event: data.eventType,
    },
  };
};

export const download = async (
  data: Models.DownloadEventType,
  profile: string,
): Promise<Notifications.Payload> => {
  const body1 =
    data.episodes?.length == 1
      ? `Season ${data.episodes[0].seasonNumber} – Episode ${data.episodes[0].episodeNumber}`
      : `${data.episodes?.length ?? 0} Episodes`;
  const quality = data.episodeFile
    ? data.episodeFile?.quality ?? 'Unknown Quality'
    : 'Unknown Quality';
  const body2 = data.isUpgrade ? `Upgraded (${quality})` : `Downloaded (${quality})`;
  const image = data.series?.tvdbId
    ? await TheMovieDB.getSeriesPoster(data.series.tvdbId)
    : undefined;
  return <Notifications.Payload>{
    title: title(profile, data.series?.title ?? 'Unknown Series'),
    body: [body1, body2].join('\n'),
    image: image,
    data: {
      module: moduleKey,
      profile: profile,
      event: data.eventType,
      seriesId: data.series?.id?.toString() ?? '-1',
      seasonNumber:
        data.episodes && data.episodes.length > 0
          ? data.episodes[0]?.seasonNumber?.toString() ?? '-1'
          : '-1',
    },
  };
};

export const grab = async (
  data: Models.GrabEventType,
  profile: string,
): Promise<Notifications.Payload> => {
  const body1 =
    data.episodes?.length == 1
      ? `Season ${data.episodes[0].seasonNumber} – Episode ${data.episodes[0].episodeNumber}`
      : `${data.episodes?.length ?? 0} Episodes`;
  const body2 = `Grabbed (${data.release?.quality ?? 'Unknown Quality'})`;
  const body3 = data?.release?.releaseTitle ?? 'Unknown Release';
  const image = data.series?.tvdbId
    ? await TheMovieDB.getSeriesPoster(data.series.tvdbId)
    : undefined;
  return <Notifications.Payload>{
    title: title(profile, data.series?.title ?? 'Unknown Series'),
    body: [body1, body2, body3].join('\n'),
    image: image,
    data: {
      module: moduleKey,
      profile: profile,
      event: data.eventType,
      seriesId: data.series?.id?.toString() ?? '-1',
      seasonNumber:
        data.episodes && data.episodes.length > 0
          ? data.episodes[0]?.seasonNumber?.toString() ?? '-1'
          : '-1',
    },
  };
};

export const health = async (
  data: Models.HealthEventType,
  profile: string,
): Promise<Notifications.Payload> => {
  return <Notifications.Payload>{
    title: title(profile, 'Health Check'),
    body: data.message ?? 'Unknown Message',
    data: {
      module: moduleKey,
      profile: profile,
      event: data.eventType,
    },
  };
};

export const rename = async (
  data: Models.RenameEventType,
  profile: string,
): Promise<Notifications.Payload> => {
  const image = data.series?.tvdbId
    ? await TheMovieDB.getSeriesPoster(data.series.tvdbId)
    : undefined;
  return <Notifications.Payload>{
    title: title(profile, data.series?.title ?? 'Unknown Series'),
    body: 'Files Renamed',
    image: image,
    data: {
      module: moduleKey,
      profile: profile,
      event: data.eventType,
      seriesId: data.series?.id?.toString() ?? '-1',
    },
  };
};

export const test = async (
  data: Models.TestEventType,
  profile: string,
): Promise<Notifications.Payload> => {
  return <Notifications.Payload>{
    title: title(profile, 'Connection Test'),
    body: 'Zagreus is ready for Sonarr notifications!',
    data: {
      module: moduleKey,
      profile: profile,
      event: data.eventType,
    },
  };
};
