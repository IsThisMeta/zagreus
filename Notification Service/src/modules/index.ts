import express from 'express';
import * as Middleware from '../server/middleware';
import { Controller as Auth } from './auth';
import { Controller as Custom } from './custom';
import { Controller as Lidarr } from './lidarr';
import { Controller as Overseerr } from './overseerr';
import { Controller as Radarr } from './radarr';
import { Controller as Sonarr } from './sonarr';
import { Controller as Tautulli } from './tautulli';
import { Controller as Webhook } from './webhook';

export const router = express.Router();

// Auth endpoints (no middleware needed)
Auth.enable(router);

// General webhook endpoint (handles its own middleware)
Webhook.enable(router);

// Shared Middleware for webhook endpoints
router.use(Middleware.startNewRequest);
router.use(Middleware.extractNotificationOptions);
router.use(Middleware.extractProfile);

// Webhook Modules
Custom.enable(router);
Lidarr.enable(router);
Overseerr.enable(router);
Radarr.enable(router);
Sonarr.enable(router);
Tautulli.enable(router);
