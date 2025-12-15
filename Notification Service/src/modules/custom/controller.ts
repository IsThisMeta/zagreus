import express from 'express';
import { Middleware, Models as ServerModels } from '../../server';
import * as APNS from '../../services/apns';
import { Constants, Logger, Notifications } from '../../utils';

export const enable = (api: express.Router) => api.use(route, router);

const logger = Logger.child({ module: 'custom' });
const router = express.Router();
const route = '/custom';

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
  settings: Notifications.Settings,
): Promise<void> => {
  const payload = <Notifications.Payload>{
    title: data?.title ?? 'Unknown Title',
    body: data?.body ?? 'Unknown Content',
    image: data?.image,
  };
  await APNS.sendNotification(devices, payload, settings);
};
