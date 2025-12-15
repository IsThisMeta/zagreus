import { Logger } from './logger';
const logger = Logger.child({ module: 'environment' });

interface _Options {
  fallback?: string;
  redacted?: boolean;
}

class _Var {
  constructor(private name: string, private options?: _Options) {
    if (process.env[this.name] || this.options?.fallback !== undefined) {
      logger.debug({ key: this.name, value: this.options?.redacted ? '[REDACTED]' : this.read() });
    } else {
      logger.fatal({ key: this.name }, 'Unable to find environment value. Exiting...');
      process.exit(1);
    }
  }

  public read = (): string => process.env[this.name] ?? this.options!.fallback!;
}

// API Keys (optional - for rich notifications)
export const FANART_TV_API_KEY = new _Var('FANART_TV_API_KEY', { fallback: '', redacted: true });
export const THEMOVIEDB_API_KEY = new _Var('THEMOVIEDB_API_KEY', { fallback: '', redacted: true });
// Redis
export const REDIS_HOST = new _Var('REDIS_HOST');
export const REDIS_PORT = new _Var('REDIS_PORT');
export const REDIS_USE_TLS = new _Var('REDIS_USE_TLS', { fallback: 'false' });
export const REDIS_USER = new _Var('REDIS_USER', { fallback: '' });
export const REDIS_PASS = new _Var('REDIS_PASS', { fallback: '', redacted: true });
// APNS
export const APNS_AUTH_KEY = new _Var('APNS_AUTH_KEY');
export const APNS_KEY_ID = new _Var('APNS_KEY_ID');
export const APNS_TEAM_ID = new _Var('APNS_TEAM_ID');
export const APNS_CERT_PATH = new _Var('APNS_CERT_PATH', { fallback: '' });
export const APNS_KEY_PATH = new _Var('APNS_KEY_PATH', { fallback: '' });
// Database
export const DB_HOST = new _Var('DB_HOST');
export const DB_PORT = new _Var('DB_PORT');
export const DB_NAME = new _Var('DB_NAME');
export const DB_USER = new _Var('DB_USER');
export const DB_PASSWORD = new _Var('DB_PASSWORD', { redacted: true });
// Other
export const NODE_ENV = new _Var('NODE_ENV', { fallback: 'development' });
export const PORT = new _Var('PORT', { fallback: '9000' });
