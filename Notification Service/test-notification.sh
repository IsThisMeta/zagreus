#!/bin/bash

# Your encoded user ID
USER_ID="ZTRjZGIzODEtMGYwNC00ZmJmLWI5MzItNTBmNDk2Mzk0ODQ1"

# Send a simple test webhook
curl -X POST https://zagreus-notifications.fly.dev/v1/notifications/webhook/$USER_ID \
  -H "Content-Type: application/json" \
  -d '{
    "eventType": "Test",
    "movie": {
      "title": "Simple Test",
      "id": 1
    }
  }'