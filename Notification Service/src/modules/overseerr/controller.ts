import express from 'express';
import { Models, Payloads } from './';
import { Middleware, Models as ServerModels } from '../../server';
import * as APNS from '../../services/apns';
import { Constants, Logger, Notifications } from '../../utils';

export const enable = (api: express.Router) => api.use(route, router);

const logger = Logger.child({ module: 'overseerr' });
const router = express.Router();
const route = '/overseerr';

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
  data: Models.RequestProperties,
  devices: string[],
  profile: string,
  settings: Notifications.Settings,
): Promise<void> => {
  let payload: Notifications.Payload | undefined;
  if (data.notification_type) {
    switch (data.notification_type) {
      case Models.NotificationType.MEDIA_APPROVED:
        payload = await Payloads.mediaApproved(data, profile);
        break;
      case Models.NotificationType.MEDIA_AUTO_APPROVED:
        payload = await Payloads.mediaAutoApproved(data, profile);
        break;
      case Models.NotificationType.MEDIA_AVAILABLE:
        payload = await Payloads.mediaAvailable(data, profile);
        break;
      case Models.NotificationType.MEDIA_DECLINED:
        payload = await Payloads.mediaDeclined(data, profile);
        break;
      case Models.NotificationType.MEDIA_FAILED:
        payload = await Payloads.mediaFailed(data, profile);
        break;
      case Models.NotificationType.MEDIA_PENDING:
        payload = await Payloads.mediaPending(data, profile);
        break;
      case Models.NotificationType.TEST_NOTIFICATION:
        payload = await Payloads.test(data, profile);
        break;
      case Models.NotificationType.ISSUE_CREATED:
        payload = await Payloads.issueCreated(data, profile);
        break;
      case Models.NotificationType.ISSUE_RESOLVED:
        payload = await Payloads.issueResolved(data, profile);
        break;
      case Models.NotificationType.ISSUE_REOPENED:
        payload = await Payloads.issueReopened(data, profile);
        break;
      case Models.NotificationType.ISSUE_COMMENT:
        payload = await Payloads.issueCommented(data, profile);
        break;
      default:
        logger.warn({ data }, '-> An unknown notification_type was received');
        break;
    }
  }
  if (payload) await APNS.sendNotification(devices, payload, settings);
};
