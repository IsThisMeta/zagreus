import { Notification, NotificationAlertOptions } from '@parse/node-apn';

export interface APNSPayload {
  title: string;
  body: string;
  image?: string;
  data?: {
    [key: string]: string;
  };
}

export interface APNSSettings {
  sound: boolean;
  ios: {
    interruptionLevel: APNSInterruptionLevel;
  };
}

export enum APNSInterruptionLevel {
  PASSIVE = 'passive',
  ACTIVE = 'active',
  TIME_SENSITIVE = 'time-sensitive',
  CRITICAL = 'critical',
}

export interface APNSNotificationOptions {
  tokens: string[];
  payload: APNSPayload;
  settings: APNSSettings;
}

/**
 * Builds an APNS notification from the provided payload and settings
 */
export const buildAPNSNotification = (
  payload: APNSPayload,
  settings: APNSSettings,
): Notification => {
  const notification = new Notification();

  // Basic notification content
  notification.alert = <NotificationAlertOptions>{
    title: payload.title,
    body: payload.body,
  };

  // Add sound if enabled
  if (settings.sound) {
    notification.sound = 'default';
  }

  // Set interruption level for iOS 15+
  notification.pushType = 'alert';
  notification.payload = {
    'interruption-level': settings.ios.interruptionLevel,
  };

  // Add custom data
  if (payload.data) {
    Object.keys(payload.data).forEach((key) => {
      notification.payload[key] = payload.data![key];
    });
  }

  // Add image as attachment if present
  if (payload.image) {
    notification.mutableContent = true;
    notification.payload['image-url'] = payload.image;
  }

  // Set priority and expiration (10 = high, 5 = default)
  notification.priority = 10; // Always use high priority for now
  
  // Set expiry to 28 days
  notification.expiry = Math.floor(Date.now() / 1000) + 2419200;

  // Enable content-available for background updates
  notification.contentAvailable = true;

  // REQUIRED: Set the topic to the app bundle ID
  notification.topic = 'com.zebrralabs.zagreus';
  
  // Ensure we have a badge to wake the app
  notification.badge = 1;

  return notification;
};


/**
 * Validates APNS device tokens
 */
export const isValidAPNSToken = (token: string): boolean => {
  // APNS tokens are 64 hexadecimal characters
  const apnsTokenRegex = /^[a-fA-F0-9]{64}$/;
  return apnsTokenRegex.test(token);
};

/**
 * Groups tokens by their validity for batch processing
 */
export const groupTokensByValidity = (tokens: string[]): {
  valid: string[];
  invalid: string[];
} => {
  const valid: string[] = [];
  const invalid: string[] = [];

  tokens.forEach((token) => {
    if (isValidAPNSToken(token)) {
      valid.push(token);
    } else {
      invalid.push(token);
    }
  });

  return { valid, invalid };
};

export const generateTitle = (module: string, profile: string, body: string): string => {
  if (profile && profile !== 'default') return `${module} (${profile}): ${body}`;
  return `${module}: ${body}`;
};