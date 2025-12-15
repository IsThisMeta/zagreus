import express from 'express';
import { DatabaseService } from '../../services/database';
import { Logger } from '../../utils';

const logger = Logger.child({ module: 'auth' });
const router = express.Router();

interface RegisterRequest {
  user_id: string;
  email: string;
  token: string;
  device_name?: string;
  device_model?: string;
  os_version?: string;
  app_version?: string;
}

const register = async (req: express.Request, res: express.Response) => {
  try {
    const body: RegisterRequest = req.body;
    
    // Validate required fields
    if (!body.user_id || !body.email || !body.token) {
      return res.status(400).json({
        error: 'Missing required fields: user_id, email, token'
      });
    }
    
    logger.info({ 
      user_id: body.user_id, 
      email: body.email,
      token: body.token,
      tokenLast4: body.token.slice(-4)
    }, 'Registering device with token');
    
    // Create or update user
    await DatabaseService.upsertUser(body.user_id, body.email);
    
    // Register device token
    const device = await DatabaseService.upsertDeviceToken(
      body.user_id,
      body.token,
      {
        device_name: body.device_name,
        device_model: body.device_model,
        os_version: body.os_version,
        app_version: body.app_version,
      }
    );
    
    logger.info({ user_id: body.user_id, device_id: device.id }, 'Device registered successfully');
    
    res.json({
      success: true,
      device_id: device.id,
      message: 'Device registered successfully'
    });
  } catch (error) {
    logger.error({ error }, 'Failed to register device');
    res.status(500).json({
      error: 'Failed to register device'
    });
  }
};

const unregister = async (req: express.Request, res: express.Response) => {
  try {
    const { token } = req.body;
    
    if (!token) {
      return res.status(400).json({
        error: 'Missing required field: token'
      });
    }
    
    await DatabaseService.removeDeviceToken(token);
    
    res.json({
      success: true,
      message: 'Device unregistered successfully'
    });
  } catch (error) {
    logger.error({ error }, 'Failed to unregister device');
    res.status(500).json({
      error: 'Failed to unregister device'
    });
  }
};

export const Controller = {
  enable: (parentRouter: express.Router): void => {
    parentRouter.use('/auth', router);
    router.post('/register', register);
    router.post('/unregister', unregister);
  },
};