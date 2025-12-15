import express from 'express';
import { Environment, Logger } from './utils';
import * as http2 from 'http2';
import * as jwt from 'jsonwebtoken';
import * as fs from 'fs';

const logger = Logger.child({ module: 'test-direct' });

export const testDirectRouter = express.Router();

// Generate JWT token for APNs
function generateToken(): string {
  const key = Environment.APNS_AUTH_KEY.read();
  const keyId = Environment.APNS_KEY_ID.read();
  const teamId = Environment.APNS_TEAM_ID.read();
  
  const token = jwt.sign({}, key, {
    algorithm: 'ES256',
    header: {
      alg: 'ES256',
      kid: keyId
    },
    issuer: teamId,
    expiresIn: '1h'
  });
  
  return token;
}

// Direct APNs test endpoint - bypassing node-apn
testDirectRouter.get('/test-direct/:token', async (req, res) => {
  try {
    const deviceToken = req.params.token;
    logger.info({ deviceToken }, 'Sending direct test notification');

    // Create the exact payload structure that Zebrra uses
    const payload = {
      aps: {
        alert: {
          title: 'Zagreus Test',
          body: 'Direct APNs Test - Can you see this?'
        },
        sound: 'default',
        badge: 1
      }
    };

    // Generate JWT
    const authToken = generateToken();
    
    // Use sandbox endpoint for testing
    const client = http2.connect('https://api.sandbox.push.apple.com');
    
    const headers = {
      ':method': 'POST',
      ':path': `/3/device/${deviceToken}`,
      'authorization': `bearer ${authToken}`,
      'apns-topic': 'com.zebrralabs.zagreus',
      'apns-push-type': 'alert',
      'apns-priority': '10',
      'apns-expiration': '0',
      'content-type': 'application/json'
    };

    const request = client.request(headers);
    
    // Log what we're sending
    logger.info({ 
      payload,
      headers,
      payloadString: JSON.stringify(payload)
    }, 'Sending direct APNs request');

    // Handle response
    request.on('response', (headers) => {
      logger.info({ responseHeaders: headers }, 'APNs response headers');
      
      if (headers[':status'] === 200) {
        res.json({ 
          success: true, 
          message: 'Notification sent successfully',
          apnsId: headers['apns-id']
        });
      } else {
        res.status(500).json({ 
          success: false, 
          status: headers[':status'],
          apnsId: headers['apns-id']
        });
      }
    });

    request.on('data', (chunk) => {
      const data = chunk.toString();
      logger.info({ responseData: data }, 'APNs response data');
    });

    request.on('error', (err) => {
      logger.error({ error: err }, 'APNs request error');
      res.status(500).json({ error: err.message });
    });

    // Send the payload
    request.write(JSON.stringify(payload));
    request.end();

    // Clean up
    request.on('end', () => {
      client.close();
    });

  } catch (error) {
    logger.error({ error }, 'Direct test notification failed');
    res.status(500).json({ error: String(error) });
  }
});