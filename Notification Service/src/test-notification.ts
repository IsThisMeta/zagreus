import express from 'express';
import { Notification, Provider } from '@parse/node-apn';
import { Environment, Logger } from './utils';

const logger = Logger.child({ module: 'test-notification' });

export const testRouter = express.Router();

// Simple test endpoint
testRouter.get('/test-push/:token', async (req, res) => {
  try {
    const token = req.params.token;
    logger.info({ token }, 'Sending test notification');

    // Initialize provider
    const provider = new Provider({
      token: {
        key: Environment.APNS_AUTH_KEY.read(),
        keyId: Environment.APNS_KEY_ID.read(),
        teamId: Environment.APNS_TEAM_ID.read(),
      },
      production: false, // Use sandbox for Xcode builds
    });

    // Create notification
    const notification = new Notification();
    
    // Set the notification properties - DO NOT set aps directly!
    notification.alert = 'Test Notification - Can you see this?';
    notification.sound = 'default';
    notification.badge = 1;
    notification.topic = 'com.zebrralabs.zagreus';
    notification.priority = 10;
    notification.pushType = 'alert';
    notification.expiry = Math.floor(Date.now() / 1000) + 3600;

    // Debug log to see what's being sent
    logger.info({ 
      debug: {
        alert: notification.alert,
        sound: notification.sound, 
        badge: notification.badge,
        topic: notification.topic,
        pushType: notification.pushType,
        priority: notification.priority,
        // Log the full notification object
        fullNotification: JSON.stringify(notification),
        payload: JSON.stringify((notification as any).payload)
      }
    }, 'Notification before sending');
    
    // Send it
    const result = await provider.send(notification, token);
    
    logger.info({ 
      result,
      sent: result.sent,
      failed: result.failed,
      failedDetails: result.failed.map(f => ({ 
        device: f.device, 
        status: f.status, 
        response: f.response
      }))
    }, 'Notification result with details');
    
    res.json({ 
      success: true, 
      result: {
        sent: result.sent.length,
        failed: result.failed,
      }
    });

    await provider.shutdown();
  } catch (error) {
    logger.error({ error }, 'Test notification failed');
    res.status(500).json({ error: String(error) });
  }
});