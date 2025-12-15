import express from 'express';
import { Models, Payloads } from './';
import { Middleware, Models as ServerModels } from '../../server';
import * as APNS from '../../services/apns';
import { Constants, Logger, Notifications } from '../../utils';

export const enable = (api: express.Router) => api.use(route, router);

const logger = Logger.child({ module: 'tautulli' });
const router = express.Router();
const route = '/tautulli';

router.post(
  '/user/:id',
  Middleware.validateUser,
  Middleware.checkNotificationPassword,
  Middleware.pullUserTokens,
  handler,
);
router.post('/device/:id', Middleware.extractDeviceToken, handler);

async function handler(request: express.Request, response: express.Response): Promise<void> {
  try {
    response.status(200).json(<ServerModels.Response>{ message: Constants.MESSAGE.OK });
    await _handleWebhook(
      request.body,
      response.locals.tokens,
      response.locals.profile,
      response.locals.notificationSettings,
    );
  } catch (error) {
    logger.error(error);
    response
      .status(500)
      .json(<ServerModels.Response>{ message: Constants.MESSAGE.INTERNAL_SERVER_ERROR });
  }
}

const _handleWebhook = async (
  data: any,
  devices: string[],
  profile: string,
  settings: Notifications.Settings,
): Promise<void> => {
  let payload: Notifications.Payload | undefined;
  if (data.action) {
    switch (data.action) {
      case Models.ActionType.BufferWarning:
        payload = await Payloads.bufferWarning(data, profile);
        break;
      case Models.ActionType.PlaybackError:
        payload = await Payloads.playbackError(data, profile);
        break;
      case Models.ActionType.PlaybackPause:
        payload = await Payloads.playbackPause(data, profile);
        break;
      case Models.ActionType.PlaybackResume:
        payload = await Payloads.playbackResume(data, profile);
        break;
      case Models.ActionType.PlaybackStart:
        payload = await Payloads.playbackStart(data, profile);
        break;
      case Models.ActionType.PlaybackStop:
        payload = await Payloads.playbackStop(data, profile);
        break;
      case Models.ActionType.PlexRemoteAccessBackUp:
        payload = await Payloads.plexRemoteAccessBackUp(data, profile);
        break;
      case Models.ActionType.PlexRemoteAccessDown:
        payload = await Payloads.plexRemoteAccessDown(data, profile);
        break;
      case Models.ActionType.PlexServerBackUp:
        payload = await Payloads.plexServerBackUp(data, profile);
        break;
      case Models.ActionType.PlexServerDown:
        payload = await Payloads.plexServerDown(data, profile);
        break;
      case Models.ActionType.PlexUpdateAvailable:
        payload = await Payloads.plexUpdateAvailable(data, profile);
        break;
      case Models.ActionType.RecentlyAdded:
        payload = await Payloads.recentlyAdded(data, profile);
        break;
      case Models.ActionType.TautulliDatabaseCorruption:
        payload = await Payloads.tautulliDatabaseCorruption(data, profile);
        break;
      case Models.ActionType.TautulliUpdateAvailable:
        payload = await Payloads.tautulliUpdateAvailable(data, profile);
        break;
      case Models.ActionType.TranscodeDecisionChange:
        payload = await Payloads.transcodeDecisionChange(data, profile);
        break;
      case Models.ActionType.UserConcurrentStreams:
        payload = await Payloads.userConcurrentStreams(data, profile);
        break;
      case Models.ActionType.UserNewDevice:
        payload = await Payloads.userNewDevice(data, profile);
        break;
      case Models.ActionType.Watched:
        payload = await Payloads.watched(data, profile);
        break;
      case Models.ActionType.Test:
        payload = await Payloads.test(data, profile);
        break;
      default:
        logger.warn({ data }, 'An unknown ActionType was received');
        break;
    }
  }
  if (!payload && data.event_type) {
    switch (data.event_type) {
      case Models.EventTypeDeprecated.BufferWarning:
        payload = await Payloads.bufferWarningDeprecated(data, profile);
        break;
      case Models.EventTypeDeprecated.PlaybackError:
        payload = await Payloads.playbackErrorDeprecated(data, profile);
        break;
      case Models.EventTypeDeprecated.PlaybackPause:
        payload = await Payloads.playbackPauseDeprecated(data, profile);
        break;
      case Models.EventTypeDeprecated.PlaybackResume:
        payload = await Payloads.playbackResumeDeprecated(data, profile);
        break;
      case Models.EventTypeDeprecated.PlaybackStart:
        payload = await Payloads.playbackStartDeprecated(data, profile);
        break;
      case Models.EventTypeDeprecated.PlaybackStop:
        payload = await Payloads.playbackStopDeprecated(data, profile);
        break;
      case Models.EventTypeDeprecated.PlexRemoteAccessBackUp:
        payload = await Payloads.plexRemoteAccessBackUpDeprecated(data, profile);
        break;
      case Models.EventTypeDeprecated.PlexRemoteAccessDown:
        payload = await Payloads.plexRemoteAccessDownDeprecated(data, profile);
        break;
      case Models.EventTypeDeprecated.PlexServerBackUp:
        payload = await Payloads.plexServerBackUpDeprecated(data, profile);
        break;
      case Models.EventTypeDeprecated.PlexServerDown:
        payload = await Payloads.plexServerDownDeprecated(data, profile);
        break;
      case Models.EventTypeDeprecated.PlexUpdateAvailable:
        payload = await Payloads.plexUpdateAvailableDeprecated(data, profile);
        break;
      case Models.EventTypeDeprecated.RecentlyAdded:
        payload = await Payloads.recentlyAddedDeprecated(data, profile);
        break;
      case Models.EventTypeDeprecated.TautulliDatabaseCorruption:
        payload = await Payloads.tautulliDatabaseCorruptionDeprecated(data, profile);
        break;
      case Models.EventTypeDeprecated.TautulliUpdateAvailable:
        payload = await Payloads.tautulliUpdateAvailableDeprecated(data, profile);
        break;
      case Models.EventTypeDeprecated.TranscodeDecisionChange:
        payload = await Payloads.transcodeDecisionChangeDeprecated(data, profile);
        break;
      case Models.EventTypeDeprecated.UserConcurrentStreams:
        payload = await Payloads.userConcurrentStreamsDeprecated(data, profile);
        break;
      case Models.EventTypeDeprecated.UserNewDevice:
        payload = await Payloads.userNewDeviceDeprecated(data, profile);
        break;
      case Models.EventTypeDeprecated.Watched:
        payload = await Payloads.watchedDeprecated(data, profile);
        break;
      default:
        logger.warn({ data }, 'An unknown EventType was received');
        break;
    }
  }
  if (payload) await APNS.sendNotification(devices, payload, settings);
};
