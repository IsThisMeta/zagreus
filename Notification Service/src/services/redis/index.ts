import Redis from 'ioredis';
import { Logger, Constants, Environment } from '../../utils';

const logger = Logger.child({ module: 'redis' });
let redis: Redis | undefined;

export const getRedis = (): Redis => {
  if (!redis) {
    throw new Error('Redis is not initialized');
  }
  return redis;
};

export const initialize = (): void => {
  const host = Environment.REDIS_HOST.read();
  const port = Number(Environment.REDIS_PORT.read());
  const username = Environment.REDIS_USER.read();
  const password = Environment.REDIS_PASS.read();
  const useTLS = Environment.REDIS_USE_TLS.read() === 'true';

  logger.info(`Connecting to Redis at ${host}:${port} (TLS: ${useTLS})`);

  redis = new Redis({
    host,
    port,
    username: username ? username : undefined,
    password: password ? password : undefined,
    tls: useTLS ? { host, port } : undefined,
    retryStrategy: (times) => {
      const delay = Math.min(times * 50, 2000);
      logger.warn(`Redis connection attempt ${times} failed, retrying in ${delay}ms`);
      return delay;
    },
    reconnectOnError: (err) => {
      const targetError = 'READONLY';
      if (err.message.includes(targetError)) {
        return true;
      }
      return false;
    },
  });

  redis.on('error', (error) => {
    logger.fatal('Redis connection failed - CANNOT PROCEED WITHOUT REDIS');
    logger.fatal(error);
    process.exit(1); // Exit if Redis fails - no silly business
  });
  
  redis.once('connect', async () => {
    logger.info('Redis connected successfully');
  });
};

export const set = async (
  key: string,
  value: string,
  expiration: Constants.RedisExpirationConfig,
): Promise<boolean> => {
  const _isSetSuccess = (res: 'OK' | null): boolean => {
    return res === 'OK';
  };

  if (!redis) {
    throw new Error('Redis is not initialized');
  }
  
  let res = false;
  try {
    const set = await redis.set(key, value, expiration.mode, expiration.ttl);
    res = _isSetSuccess(set);
  } catch (error) {
    logger.error('Redis SET failed:', error);
    throw error;
  }
  return res;
};

export const get = async (key: string): Promise<string | null> => {
  if (!redis) {
    throw new Error('Redis is not initialized');
  }
  
  let res: string | null = null;
  try {
    res = await redis.get(key);
  } catch (error) {
    logger.error('Redis GET failed:', error);
    throw error;
  }
  return res;
};
