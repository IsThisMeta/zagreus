import express from 'express';
import basicauth from 'basic-auth';
import { Models } from './';
import { DatabaseService } from '../services/database';
import { Constants, Logger, Notifications } from '../utils';

const logger = Logger.child({ module: 'middleware' });

export async function startNewRequest(
  request: express.Request,
  response: express.Response,
  next: express.NextFunction,
): Promise<void> {
  logger.info({ url: request.url, ...request.headers });
  next();
}

export async function extractNotificationOptions(
  request: express.Request,
  response: express.Response,
  next: express.NextFunction,
): Promise<void> {
  const getSound = (sound: any): boolean => {
    return sound !== 'false';
  };

  const getInterruptionLevel = (level: any): Notifications.iOSInterruptionLevel => {
    const idx = Object.values(Notifications.iOSInterruptionLevel).indexOf(level) !== -1;
    if (idx) return level as Notifications.iOSInterruptionLevel;
    return Notifications.iOSInterruptionLevel.ACTIVE;
  };

  response.locals.notificationSettings = <Notifications.Settings>{
    sound: getSound(request.query.sound),
    ios: {
      interruptionLevel: getInterruptionLevel(request.query.interruption_level),
    },
  };

  logger.debug({ ...response.locals.notificationSettings });
  next();
}

export async function extractProfile(
  request: express.Request,
  response: express.Response,
  next: express.NextFunction,
): Promise<void> {
  // Extract the username part from basic auth and set it as the profile
  const auth = basicauth(request);
  response.locals.profile = auth?.name ?? 'default';

  logger.debug({ profile: response.locals.profile });
  next();
}

export async function extractDeviceToken(
  request: express.Request,
  response: express.Response,
  next: express.NextFunction,
): Promise<void> {
  if (request.params.id) {
    response.locals.tokens = [request.params.id];
    logger.debug({ device_id: request.params.id });
    next();
  } else {
    logger.warn('A request with no device ID was attempted. Cancelling request...');
    response.status(400).json(<Models.Response>{ message: Constants.MESSAGE.NO_ID_SUPPLIED });
  }
}

export async function pullUserTokens(
  request: express.Request,
  response: express.Response,
  next: express.NextFunction,
): Promise<void> {
  const devices: string[] = await DatabaseService.getUserDevices(request.params.id);
  const deviceCount: number = devices?.length ?? 0;

  // Check if this is a test webhook
  const isTestWebhook = request.body?.eventType === 'Test';

  if (deviceCount > 0) {
    response.locals.tokens = devices;
    logger.debug({ device_count: deviceCount });
    next();
  } else if (isTestWebhook) {
    // For test webhooks, continue with empty device list
    response.locals.tokens = [];
    logger.debug('Test webhook detected, continuing without devices');
    next();
  } else {
    logger.warn('-> No devices found. Cancelling request...');
    response.status(400).json(<Models.Response>{ message: Constants.MESSAGE.NO_DEVICES_FOUND });
  }
}

export async function checkNotificationPassword(
  request: express.Request,
  response: express.Response,
  next: express.NextFunction,
): Promise<void> {
  // TODO
  next();
}

export async function validateUser(
  request: express.Request,
  response: express.Response,
  next: express.NextFunction,
): Promise<void> {
  if (request.params.id && (await DatabaseService.getUser(request.params.id))) {
    logger.debug({ user_id: request.params.id });
    next();
  } else {
    logger.warn({ user: request.params.id }, 'Failed to find user. Cancelling request...');
    response.status(404).json(<Models.Response>{ message: Constants.MESSAGE.USER_NOT_FOUND });
  }
}
