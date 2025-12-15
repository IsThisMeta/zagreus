import { getRedis } from '../redis';
import { Logger } from '../../utils';

const logger = Logger.child({ module: 'cache' });

const DEVICE_LIST_PREFIX = 'devices:';
const DEVICE_LIST_TTL = 300; // 5 minutes

/**
 * Get cached device list for a user
 */
export async function getDeviceList(userId: string): Promise<string[] | null> {
  try {
    const redis = getRedis();
    const key = `${DEVICE_LIST_PREFIX}${userId}`;
    const cached = await redis.get(key);
    
    if (cached) {
      return JSON.parse(cached);
    }
    
    return null;
  } catch (error) {
    logger.error({ error }, 'Failed to get cached device list');
    return null;
  }
}

/**
 * Cache device list for a user
 */
export async function setDeviceList(userId: string, devices: string[]): Promise<void> {
  try {
    const redis = getRedis();
    const key = `${DEVICE_LIST_PREFIX}${userId}`;
    await redis.set(key, JSON.stringify(devices), 'EX', DEVICE_LIST_TTL);
  } catch (error) {
    logger.error({ error }, 'Failed to cache device list');
    // Don't throw - caching failures shouldn't break the flow
  }
}

/**
 * Clear cached device list for a user
 */
export async function clearDeviceList(userId: string): Promise<void> {
  try {
    const redis = getRedis();
    const key = `${DEVICE_LIST_PREFIX}${userId}`;
    await redis.del(key);
  } catch (error) {
    logger.error({ error }, 'Failed to clear cached device list');
    // Don't throw - caching failures shouldn't break the flow
  }
}