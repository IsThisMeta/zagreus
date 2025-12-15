import { Server } from './server';
import { Redis } from './services';
import * as APNS from './services/apns';
import { DatabaseService } from './services/database';

// Initialize services
DatabaseService.initialize();
APNS.initialize();
Redis.initialize();
Server.start();
