import axios from 'axios';
import { Logger, Environment } from '../../utils';

const logger = Logger.child({ module: 'fanart_tv' });

const http = axios.create({
  baseURL: 'http://webservice.fanart.tv/v3/',
  params: {
    api_key: Environment.FANART_TV_API_KEY.read(),
  },
});

const convertToPreview = (url: string): string => url.replace('/fanart/', '/preview/');

export const getArtistThumbnail = async (artistId: string): Promise<string | undefined> => {
  try {
    return await http({
      method: 'GET',
      url: `music/${artistId}`,
    }).then((response) => {
      if (
        response.data.artistthumb &&
        Array.isArray(response.data.artistthumb) &&
        response.data.artistthumb.length > 0
      ) {
        const url = convertToPreview(response.data.artistthumb[0]?.url);
        if (url) return url;
      }
    });
  } catch (error) {
    logger.error(error);
  }
  return undefined;
};

export const getAlbumCover = async (albumId: string): Promise<string | undefined> => {
  try {
    return await http({
      method: 'GET',
      url: `music/albums/${albumId}`,
    }).then((response) => {
      if (
        response.data.albums &&
        response.data.albums[albumId] &&
        response.data.albums[albumId].albumcover &&
        Array.isArray(response.data.albums[albumId].albumcover) &&
        response.data.albums[albumId].albumcover.length > 0
      ) {
        const url = convertToPreview(response.data[albumId].albumcover[0]?.url);
        if (url) return url;
      }
    });
  } catch (error) {
    logger.error(error);
  }
  return undefined;
};
