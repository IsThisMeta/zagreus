import { Provider, Notification } from '@parse/node-apn';
import * as Cache from '../cache';
import { Environment, Logger, Notifications } from '../../utils';
import * as APNSNotifications from '../../utils/apns-notifications';
import { DatabaseService } from '../database';

const logger = Logger.child({ module: 'apns' });
let apnsProvider: Provider;

/**
 * Initialize APNS Provider with certificates and configuration
 */
export const initialize = (): void => {
  const options = {
    // Certificate-based authentication
    cert: Environment.APNS_CERT_PATH.read(),
    key: Environment.APNS_KEY_PATH.read(),
    
    // Or token-based authentication (recommended)
    token: {
      key: Environment.APNS_AUTH_KEY.read(),
      keyId: Environment.APNS_KEY_ID.read(),
      teamId: Environment.APNS_TEAM_ID.read(),
    },
    
    // Environment - auto-detect based on NODE_ENV
    production: Environment.NODE_ENV.read() === 'production',
    
    // Connection settings
    connectionRetryLimit: 10,
  };

  apnsProvider = new Provider(options);

  // Handle provider events
  apnsProvider.on('error', (error: Error) => {
    logger.error({ error }, 'APNS Provider error');
  });

  apnsProvider.on('socketError', (error: Error) => {
    logger.error({ error }, 'APNS Socket error');
  });

  apnsProvider.on('transmissionError', (errCode: number, notification: any, device: string) => {
    logger.error(
      { errorCode: errCode, device, notification },
      'APNS Transmission error'
    );
  });
};

/**
 * Check if user exists in the database
 */
export const hasUserID = async (uid: string): Promise<boolean> => {
  try {
    if (!uid) return false;
    
    // Check in database
    const user = await DatabaseService.getUser(uid);
    return !!user;
  } catch (error) {
    logger.error(error);
    return false;
  }
};

/**
 * Get user's registered device tokens
 */
export const getUserDevices = async (uid: string): Promise<string[]> => {
  try {
    // Invalid UID
    if (!uid) return [];

    // Check cache first
    const cache = await Cache.getDeviceList(uid);
    if (cache) return cache;

    // Get from database
    const devices = await DatabaseService.getUserDevices(uid);
    
    // Cache the results
    if (devices.length > 0) {
      await Cache.setDeviceList(uid, devices);
    }
    
    return devices;
  } catch (error) {
    logger.error(error);
    return [];
  }
};

/**
 * Send notifications via APNS
 */
export const sendNotification = async (
  tokens: string[],
  payload: Notifications.Payload,
  settings: Notifications.Settings,
): Promise<boolean> => {
  try {
    // Validate and group tokens
    const { valid: validTokens, invalid: invalidTokens } = 
      APNSNotifications.groupTokensByValidity(tokens);
    
    if (invalidTokens.length > 0) {
      logger.warn(
        { count: invalidTokens.length, tokens: invalidTokens },
        'Invalid tokens detected'
      );
    }

    if (validTokens.length === 0) {
      logger.warn('No valid tokens to send notifications to');
      return false;
    }

    // Convert Notifications.Payload to APNSPayload
    const apnsPayload: APNSNotifications.APNSPayload = {
      title: payload.title,
      body: payload.body,
      image: payload.image,
      data: payload.data,
    };

    // Convert settings
    const apnsSettings: APNSNotifications.APNSSettings = {
      sound: settings.sound,
      ios: {
        interruptionLevel: settings.ios.interruptionLevel as unknown as APNSNotifications.APNSInterruptionLevel,
      },
    };

    // Build notification
    const notification = APNSNotifications.buildAPNSNotification(apnsPayload, apnsSettings);
    
    // Debug logging
    logger.info({ 
      notification: {
        topic: notification.topic,
        alert: notification.alert,
        sound: notification.sound,
        payload: notification.payload,
        priority: notification.priority,
        pushType: notification.pushType,
        contentAvailable: notification.contentAvailable,
        badge: notification.badge,
        rawNotification: JSON.stringify(notification),
      },
      tokenCount: validTokens.length 
    }, 'Sending notification');
    
    // Send to all valid tokens
    const result = await apnsProvider.send(notification, validTokens);
    
    // Process results
    let successCount = 0;
    let failureCount = 0;

    result.sent.forEach((sentResult: any) => {
      successCount++;
      logger.info({ 
        device: sentResult.device,
        deviceLast4: sentResult.device.slice(-4)
      }, 'Notification sent successfully to device');
    });

    result.failed.forEach((failedResult: any) => {
      failureCount++;
      logger.error(
        {
          device: failedResult.device,
          status: failedResult.status,
          response: failedResult.response,
        },
        'Notification failed'
      );

      // Handle specific errors
      if (failedResult.status === 410) {
        // Token is no longer valid, remove from database
        DatabaseService.removeDeviceToken(failedResult.device).catch((err) => {
          logger.error({ error: err }, 'Failed to remove invalid token');
        });
      }
    });

    logger.info(
      {
        success: successCount,
        failure: failureCount,
        total: validTokens.length,
      },
      'Notification batch completed'
    );

    return successCount > 0;
  } catch (error) {
    logger.error({ error }, 'Failed to send APNS notification');
    return false;
  }
};

/**
 * Cleanup provider connections
 */
export const shutdown = async (): Promise<void> => {
  if (apnsProvider) {
    await apnsProvider.shutdown();
    logger.info('APNS Provider shut down');
  }
};