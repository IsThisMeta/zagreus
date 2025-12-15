# APNS Migration Guide for Zagreus Notification Service

## Overview
This guide outlines the key changes needed to migrate from Firebase Cloud Messaging (FCM) to Apple Push Notification Service (APNS).

## Required NPM Packages

### Core APNS Package
```json
{
  "dependencies": {
    "@parse/node-apn": "^5.2.3",  // Main APNS library
    "pg": "^8.11.3",              // PostgreSQL client (or your preferred DB)
    "pg-pool": "^3.6.1"           // Connection pooling for PostgreSQL
  }
}
```

### Optional but Recommended
```json
{
  "dependencies": {
    "knex": "^3.0.1",             // SQL query builder (optional)
    "db-migrate": "^0.11.13",     // Database migration tool
    "db-migrate-pg": "^1.3.0"     // PostgreSQL adapter for db-migrate
  }
}
```

## Key Files Created

### 1. APNS Notification Utility (`src/utils/apns-notifications.ts`)
- Replaces the Firebase notification builder
- Handles APNS-specific notification format
- Includes token validation
- Supports interruption levels for iOS 15+

### 2. APNS Service (`src/services/apns/index.ts`)
- Direct replacement for `src/services/firebase/index.ts`
- Implements the same interface (hasUserID, getUserDevices, sendNotification)
- Handles APNS provider initialization and error handling
- Includes token cleanup for invalid devices

### 3. Database Service (`src/services/database/index.ts`)
- Replaces Firebase Firestore for user/device management
- PostgreSQL-based implementation (can be adapted for other databases)
- Includes connection pooling and error handling

### 4. Database Schema (`src/services/database/schema.sql`)
- Simple relational schema for users and device tokens
- Includes notification settings table
- Failed notification logging for debugging
- Automatic timestamp updates

## Environment Variables Needed

### Remove these Firebase variables:
- FIREBASE_CLIENT_EMAIL
- FIREBASE_PROJECT_ID
- FIREBASE_PRIVATE_KEY
- FIREBASE_DATABASE_URL

### Add these APNS variables:
```bash
# For Token-based Authentication (Recommended)
APNS_AUTH_KEY=path/to/AuthKey_XXXXXXXXXX.p8
APNS_KEY_ID=XXXXXXXXXX
APNS_TEAM_ID=XXXXXXXXXX

# OR for Certificate-based Authentication
APNS_CERT_PATH=path/to/cert.pem
APNS_KEY_PATH=path/to/key.pem

# Database Configuration
DB_HOST=localhost
DB_PORT=5432
DB_NAME=zagreus_notifications
DB_USER=your_user
DB_PASSWORD=your_password
```

## Migration Steps

### 1. Update Dependencies
```bash
npm uninstall firebase-admin
npm install @parse/node-apn pg
```

### 2. Update Environment Configuration
Add the new environment variables to `src/utils/environment.ts`:
```typescript
export const APNS_AUTH_KEY = new EnvironmentVariable('APNS_AUTH_KEY');
export const APNS_KEY_ID = new EnvironmentVariable('APNS_KEY_ID');
export const APNS_TEAM_ID = new EnvironmentVariable('APNS_TEAM_ID');
// ... database variables
```

### 3. Update Service Initialization
In `src/index.ts`, replace Firebase initialization with:
```typescript
import { DatabaseService } from './services/database';
import * as APNS from './services/apns';

// Initialize services
DatabaseService.initialize();
APNS.initialize();
```

### 4. Update Module Controllers
In each module controller (e.g., `src/modules/*/controller.ts`), update imports:
```typescript
// Replace
import { Firebase } from '../../services';

// With
import * as APNS from '../../services/apns';

// Update service calls
await APNS.sendNotification(devices, payload, settings);
```

### 5. Update Notification Payload Type
Update imports in controllers to use the new APNS types:
```typescript
import { APNSPayload, APNSSettings } from '../../utils/apns-notifications';
```

## Key Differences to Note

### 1. Token Format
- Firebase FCM tokens and APNS tokens have different formats
- APNS tokens are 64 hexadecimal characters
- You'll need a migration strategy for existing tokens

### 2. Authentication
- APNS supports token-based (recommended) or certificate-based auth
- Token-based auth uses a .p8 key file from Apple Developer Portal

### 3. Notification Format
- APNS has a different payload structure than FCM
- Image attachments work differently (mutable-content flag)
- Interruption levels are iOS-specific

### 4. Error Handling
- APNS provides specific error codes (e.g., 410 for invalid token)
- Built-in retry logic in the @parse/node-apn library

### 5. User Management
- No longer tied to Firebase Authentication
- Need to implement your own user registration/management
- Device tokens stored in your own database

## Testing Recommendations

1. Set up a test database with the provided schema
2. Use Apple's Push Notification Console for testing
3. Test with both development and production APNS environments
4. Implement gradual rollout (dual Firebase/APNS support during migration)

## Security Considerations

1. Store APNS keys securely (never commit to git)
2. Use environment variables for all sensitive configuration
3. Implement rate limiting for notification endpoints
4. Validate all device tokens before storing
5. Regularly clean up invalid/expired tokens

## Next Steps

1. Set up the PostgreSQL database with the provided schema
2. Obtain APNS credentials from Apple Developer Portal
3. Update environment configuration
4. Test with a small subset of users
5. Monitor error rates and adjust accordingly
6. Gradually migrate all users from Firebase to APNS