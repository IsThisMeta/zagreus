import { Models } from './';
import { FanartTV } from '../../api';
import { Notifications } from '../../utils';

const title = (profile: string, body: string): string =>
  Notifications.generateTitle('Lidarr', profile, body);
const moduleKey = 'lidarr';

export const grab = async (
  data: Models.GrabEventType,
  profile: string,
): Promise<Notifications.Payload> => {
  const body1 =
    data.albums?.length == 1
      ? data.albums[0].title ?? 'Unknown Album'
      : `${data.albums?.length ?? 0} Albums`;
  const body2 = `Grabbed (${data.release?.quality ?? 'Unknown Quality'})`;
  const body3 = data?.release?.releaseTitle ?? 'Unknown Release';
  const image = data.artist?.mbId ? await FanartTV.getArtistThumbnail(data.artist.mbId) : undefined;
  return <Notifications.Payload>{
    title: title(profile, data.artist?.name ?? 'Unknown Artist'),
    body: [body1, body2, body3].join('\n'),
    image: image,
    data: {
      module: moduleKey,
      profile: profile,
      event: data.eventType,
      artistId: data?.artist?.id?.toString() ?? '-1',
      albumId:
        data.albums && data.albums.length > 0 ? data.albums[0]?.id?.toString() ?? '-1' : '-1',
    },
  };
};

export const download = async (
  data: Models.DownloadEventType,
  profile: string,
): Promise<Notifications.Payload> => {
  const body1 =
    data.tracks?.length == 1
      ? data.tracks[0].title ?? 'Unknown Track'
      : `${data.tracks?.length ?? 0} Tracks`;
  const quality =
    data.tracks && data.tracks.length > 0
      ? data.tracks[0]?.quality ?? 'Unknown Quality'
      : 'Unknown Quality';
  const body2 = data.isUpgrade ? `Upgraded (${quality})` : `Downloaded (${quality})`;
  const image = data.artist?.mbId ? await FanartTV.getArtistThumbnail(data.artist.mbId) : undefined;
  return <Notifications.Payload>{
    title: title(profile, data.artist?.name ?? 'Unknown Artist'),
    body: [body1, body2].join('\n'),
    image: image,
    data: {
      module: moduleKey,
      profile: profile,
      event: data.eventType,
      artistId: data?.artist?.id?.toString() ?? '-1',
    },
  };
};

export const rename = async (
  data: Models.RenameEventType,
  profile: string,
): Promise<Notifications.Payload> => {
  const image = data.artist?.mbId ? await FanartTV.getArtistThumbnail(data.artist.mbId) : undefined;
  return <Notifications.Payload>{
    title: title(profile, data.artist?.name ?? 'Unknown Artist'),
    body: 'Files Renamed',
    image: image,
    data: {
      module: moduleKey,
      profile: profile,
      event: data.eventType,
      artistId: data?.artist?.id?.toString() ?? '-1',
    },
  };
};

export const retag = async (
  data: Models.RetagEventType,
  profile: string,
): Promise<Notifications.Payload> => {
  const image = data.artist?.mbId ? await FanartTV.getArtistThumbnail(data.artist.mbId) : undefined;
  return <Notifications.Payload>{
    title: title(profile, data.artist?.name ?? 'Unknown Artist'),
    body: 'Tracks Retagged',
    image: image,
    data: {
      module: moduleKey,
      profile: profile,
      event: data.eventType,
      artistId: data?.artist?.id?.toString() ?? '-1',
    },
  };
};

export const test = async (
  data: Models.TestEventType,
  profile: string,
): Promise<Notifications.Payload> => {
  return <Notifications.Payload>{
    title: title(profile, 'Connection Test'),
    body: 'Zagreus is ready for Lidarr notifications!',
    data: {
      module: moduleKey,
      profile: profile,
      event: data.eventType,
    },
  };
};
