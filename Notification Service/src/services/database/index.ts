import { Pool, QueryResult } from 'pg';
import { Environment, Logger } from '../../utils';

const logger = Logger.child({ module: 'database' });

let pool: Pool;

interface User {
  id: string;
  email: string;
  created_at: Date;
  updated_at: Date;
}

interface DeviceToken {
  id: string;  // uuid in your table
  user_id: string;
  token: string;
  device_name?: string;
  device_model?: string;
  ios_version?: string;  // not os_version
  app_version?: string;
  bundle_id?: string;
  environment?: string;
  is_active: boolean;
  created_at: Date;
  updated_at: Date;
  last_used?: Date;
}

/**
 * Initialize database connection pool
 */
export const initialize = (): void => {
  pool = new Pool({
    host: Environment.DB_HOST.read(),
    port: parseInt(Environment.DB_PORT.read() || '5432'),
    database: Environment.DB_NAME.read(),
    user: Environment.DB_USER.read(),
    password: Environment.DB_PASSWORD.read(),
    max: 20,
    idleTimeoutMillis: 30000,
    connectionTimeoutMillis: 2000,
  });

  pool.on('error', (err: Error) => {
    logger.error({ error: err }, 'Unexpected database error');
  });

  logger.info('Database connection pool initialized');
};

/**
 * Get user by ID
 */
export const getUser = async (userId: string): Promise<User | null> => {
  try {
    const query = 'SELECT * FROM users WHERE id = $1';
    const result = await pool.query<User>(query, [userId]);
    
    return result.rows[0] || null;
  } catch (error) {
    logger.error({ error, userId }, 'Failed to get user');
    throw error;
  }
};

/**
 * Create or update user
 */
export const upsertUser = async (userId: string, email: string): Promise<User> => {
  try {
    const query = `
      INSERT INTO users (id, email) 
      VALUES ($1, $2)
      ON CONFLICT (id) 
      DO UPDATE SET email = $2, updated_at = CURRENT_TIMESTAMP
      RETURNING *
    `;
    
    const result = await pool.query<User>(query, [userId, email]);
    return result.rows[0];
  } catch (error) {
    logger.error({ error, userId, email }, 'Failed to upsert user');
    throw error;
  }
};

/**
 * Get active device tokens for a user
 */
export const getUserDevices = async (userId: string): Promise<string[]> => {
  try {
    const query = `
      SELECT token 
      FROM device_tokens 
      WHERE user_id = $1 AND is_active = true
      ORDER BY last_used DESC NULLS LAST
    `;
    
    const result = await pool.query<{ token: string }>(query, [userId]);
    return result.rows.map((row: { token: string }) => row.token);
  } catch (error) {
    logger.error({ error, userId }, 'Failed to get user devices');
    throw error;
  }
};

/**
 * Add or update device token
 */
export const upsertDeviceToken = async (
  userId: string,
  token: string,
  deviceInfo?: {
    device_name?: string;
    device_model?: string;
    os_version?: string;
    app_version?: string;
  }
): Promise<DeviceToken> => {
  try {
    const query = `
      INSERT INTO device_tokens (user_id, token, device_name, device_model, ios_version, app_version)
      VALUES ($1, $2, $3, $4, $5, $6)
      ON CONFLICT (user_id, token)
      DO UPDATE SET 
        device_name = COALESCE($3, device_tokens.device_name),
        device_model = COALESCE($4, device_tokens.device_model),
        ios_version = COALESCE($5, device_tokens.ios_version),
        app_version = COALESCE($6, device_tokens.app_version),
        is_active = true,
        updated_at = CURRENT_TIMESTAMP
      RETURNING *
    `;
    
    const values = [
      userId,
      token,
      deviceInfo?.device_name || null,
      deviceInfo?.device_model || null,
      deviceInfo?.os_version || null,
      deviceInfo?.app_version || null,
    ];
    
    const result = await pool.query<DeviceToken>(query, values);
    return result.rows[0];
  } catch (error) {
    logger.error({ error, userId, token }, 'Failed to upsert device token');
    throw error;
  }
};

/**
 * Remove device token
 */
export const removeDeviceToken = async (token: string): Promise<void> => {
  try {
    const query = 'UPDATE device_tokens SET is_active = false WHERE token = $1';
    await pool.query(query, [token]);
    
    logger.info({ token }, 'Device token deactivated');
  } catch (error) {
    logger.error({ error, token }, 'Failed to remove device token');
    throw error;
  }
};

/**
 * Update last used timestamp for device token
 * Using updated_at since last_used_at doesn't exist
 */
export const updateTokenLastUsed = async (token: string): Promise<void> => {
  try {
    const query = 'UPDATE device_tokens SET last_used = CURRENT_TIMESTAMP WHERE token = $1';
    await pool.query(query, [token]);
  } catch (error) {
    logger.error({ error, token }, 'Failed to update token last used');
    // Don't throw - this is not critical
  }
};

/**
 * Log failed notification for debugging
 * Just logs to console since we don't have a failed_notifications table
 */
export const logFailedNotification = async (
  userId: string,
  deviceToken: string,
  errorCode: string,
  errorMessage: string,
  payload: any
): Promise<void> => {
  logger.error({
    userId,
    deviceToken,
    errorCode,
    errorMessage,
    payload
  }, 'Failed to send notification');
};

/**
 * Get user notification settings
 * Returns default settings since we're not storing preferences anymore
 */
export const getUserNotificationSettings = async (userId: string): Promise<any> => {
  // Always return default settings
  return {
    sound_enabled: true,
    interruption_level: 'active',
  };
};

/**
 * Cleanup old failed notifications
 * No-op since we don't have a failed_notifications table
 */
export const cleanupOldFailedNotifications = async (): Promise<number> => {
  return 0;
};

/**
 * Close database connections
 */
export const shutdown = async (): Promise<void> => {
  if (pool) {
    await pool.end();
    logger.info('Database connection pool closed');
  }
};

// Export as a service object
export const DatabaseService = {
  initialize,
  getUser,
  upsertUser,
  getUserDevices,
  upsertDeviceToken,
  removeDeviceToken,
  updateTokenLastUsed,
  logFailedNotification,
  getUserNotificationSettings,
  cleanupOldFailedNotifications,
  shutdown,
};