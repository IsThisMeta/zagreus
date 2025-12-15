import express from 'express';
import basicAuth from 'basic-auth';
import { Middleware, Models as ServerModels } from '../../server';
import * as APNS from '../../services/apns';
import { Constants, Logger, Notifications } from '../../utils';
import * as RadarrController from '../radarr/controller';
import * as SonarrController from '../sonarr/controller';

export const enable = (api: express.Router) => api.use(route, router);

const logger = Logger.child({ module: 'webhook' });
const router = express.Router();
const route = '/notifications';

/**
 * General webhook endpoint that determines the service type from the payload
 * Expected URL format: /v1/notifications/webhook
 */
router.post(
  '/webhook',
  Middleware.startNewRequest,
  Middleware.extractNotificationOptions,
  extractUserFromPayload,
  Middleware.validateUser,
  Middleware.pullUserTokens,
  handler,
);

/**
 * Webhook endpoint with user ID in path (used by Zagreus app)
 * Expected URL format: /v1/notifications/webhook/:payload (where payload is base64 encoded user ID)
 */
router.post(
  '/webhook/:payload',
  Middleware.startNewRequest,
  Middleware.extractNotificationOptions,
  extractUserFromPath,
  Middleware.validateUser,
  Middleware.pullUserTokens,
  handler,
);

async function extractUserFromPath(
  request: express.Request,
  response: express.Response,
  next: express.NextFunction,
): Promise<void> {
  try {
    // Extract base64 encoded user ID from URL path
    const payload = request.params.payload;
    if (!payload) {
      logger.warn('No payload found in URL path');
      response.status(400).json(<ServerModels.Response>{ 
        message: 'Missing user authentication' 
      });
      return;
    }
    
    // Decode base64 to get user ID
    const userId = Buffer.from(payload, 'base64').toString('utf-8');
    
    // Validate it looks like a UUID
    const uuidRegex = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;
    if (!uuidRegex.test(userId)) {
      logger.warn({ userId }, 'Invalid user ID format');
      response.status(400).json(<ServerModels.Response>{ 
        message: 'Invalid user authentication' 
      });
      return;
    }
    
    // Set the user ID in params for middleware compatibility
    request.params.id = userId;
    logger.debug({ user_id: userId, payload }, 'Extracted user ID from URL path');
    next();
  } catch (error) {
    logger.error({ error, payload: request.params.payload }, 'Failed to decode user ID from path');
    response.status(400).json(<ServerModels.Response>{ 
      message: 'Invalid user authentication' 
    });
  }
}

async function extractUserFromPayload(
  request: express.Request,
  response: express.Response,
  next: express.NextFunction,
): Promise<void> {
  // Extract user ID from basic auth username (sent by Radarr/Sonarr webhook)
  const auth = basicAuth(request);
  const userId = auth?.name;
  
  if (!userId) {
    logger.warn('No user ID found in basic auth username');
    response.status(400).json(<ServerModels.Response>{ 
      message: 'Missing user authentication' 
    });
    return;
  }
  
  // Set the user ID in params for middleware compatibility
  request.params.id = userId;
  logger.debug({ user_id: userId }, 'Extracted user ID from basic auth');
  next();
}

async function handler(request: express.Request, response: express.Response): Promise<void> {
  try {
    response.status(200).json(<ServerModels.Response>{ message: Constants.MESSAGE.OK });
    
    const data = request.body;
    const devices = response.locals.tokens;
    const settings = response.locals.notificationSettings;
    
    // Determine service type from payload
    const service = detectService(data);
    
    if (!service) {
      logger.warn({ data }, 'Unable to determine service type from webhook');
      return;
    }
    
    logger.info({ service, eventType: data.eventType }, 'Processing webhook');
    
    // Route to appropriate handler based on service type
    let payload: Notifications.Payload | undefined;
    
    switch (service) {
      case 'radarr':
        const radarrModule = await import('../radarr/payloads');
        payload = await handleRadarrWebhook(data, radarrModule);
        break;
        
      case 'sonarr':
        const sonarrModule = await import('../sonarr/payloads');
        payload = await handleSonarrWebhook(data, sonarrModule);
        break;
        
      default:
        logger.warn({ service }, 'Unsupported service type');
        return;
    }
    
    if (payload) {
      logger.info({ payload, settings }, 'Sending notification with payload');
      await APNS.sendNotification(devices, payload, settings);
    }
  } catch (error) {
    logger.error({ error }, 'Failed to handle webhook');
  }
}

function detectService(data: any): string | null {
  // Check for Radarr-specific fields
  if (data.movie || data.remoteMovie) {
    return 'radarr';
  }
  
  // Check for Sonarr-specific fields
  if (data.series || data.episodes) {
    return 'sonarr';
  }
  
  // Check eventType patterns
  if (data.eventType) {
    const eventType = data.eventType.toLowerCase();
    if (eventType.includes('movie')) {
      return 'radarr';
    }
    if (eventType.includes('series') || eventType.includes('episode')) {
      return 'sonarr';
    }
  }
  
  return null;
}

async function handleRadarrWebhook(data: any, payloads: any): Promise<Notifications.Payload | undefined> {
  const profile = 'default'; // Could be extracted from data if needed
  
  switch (data.eventType) {
    case 'Download':
      return await payloads.download(data, profile);
    case 'Grab':
      return await payloads.grab(data, profile);
    case 'Health':
      return await payloads.health(data, profile);
    case 'MovieDelete':
      return await payloads.movieDelete(data, profile);
    case 'MovieFileDelete':
      return await payloads.movieFileDelete(data, profile);
    case 'Rename':
      return await payloads.rename(data, profile);
    case 'Test':
      return await payloads.test(data, profile);
    default:
      logger.warn({ eventType: data.eventType }, 'Unknown Radarr event type');
      return undefined;
  }
}

async function handleSonarrWebhook(data: any, payloads: any): Promise<Notifications.Payload | undefined> {
  const profile = 'default'; // Could be extracted from data if needed
  
  switch (data.eventType) {
    case 'Download':
      return await payloads.download(data, profile);
    case 'EpisodeFileDelete':
      return await payloads.deleteEpisodeFile(data, profile);
    case 'Grab':
      return await payloads.grab(data, profile);
    case 'Health':
      return await payloads.health(data, profile);
    case 'Rename':
      return await payloads.rename(data, profile);
    case 'SeriesDelete':
      return await payloads.deleteSeries(data, profile);
    case 'Test':
      return await payloads.test(data, profile);
    default:
      logger.warn({ eventType: data.eventType }, 'Unknown Sonarr event type');
      return undefined;
  }
}