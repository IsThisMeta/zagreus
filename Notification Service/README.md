# Zagreus Notification Service

A TypeScript backend service that handles receiving webhooks from Radarr/Sonarr and sends push notifications via Apple Push Notification service (APNs) to iOS devices.

> This is a custom notification service for Zagreus that uses APNs directly instead of Firebase Cloud Messaging.

## Usage

For documentation on setting up the webhooks, please look at Zagreus's documentation [available here](https://notify.zagreus.app).

## Installation (Docker)

```docker
docker run -d \
    -e APNS_AUTH_KEY="-----BEGIN PRIVATE KEY-----\n...\n-----END PRIVATE KEY-----" \
    -e APNS_KEY_ID=YOUR_KEY_ID \
    -e APNS_TEAM_ID=YOUR_TEAM_ID \
    -e DB_HOST=postgres \
    -e DB_PORT=5432 \
    -e DB_NAME=zagreus \
    -e DB_USER=postgres \
    -e DB_PASSWORD=yourpassword \
    -e REDIS_HOST=redis \
    -e REDIS_PORT=6379 \
    -e FANART_TV_API_KEY=1234567890 \
    -e THEMOVIEDB_API_KEY=1234567890 \
    -p 9000:9000 \
    --restart unless-stopped \
ghcr.io/yourusername/zagreus-notification-service:latest
```

## Development & Installation

Zagreus's Notification Service requires:

- Node.js v14.0.0 or higher (v18.0.0 or higher is recommended)
- PostgreSQL 13 or higher
- Redis 6 or higher
- Apple Developer account with APNs configured

### Environment

All environment variables must either be set at an operating system-level, terminal-level, as Docker environment variables, or by creating a `.env` file at the root of the project. A sample `.env` is supplied in the project (`.env.sample`).

| Variable                | Value                                                                 | Default | Required? |
| :---------------------- | :-------------------------------------------------------------------- | :-----: | :-------: |
| `APNS_AUTH_KEY`         | APNs authentication key content (.p8 file)                            | &mdash; |  &check;  |
| `APNS_KEY_ID`           | APNs Key ID from Apple Developer                                      | &mdash; |  &check;  |
| `APNS_TEAM_ID`          | Apple Developer Team ID                                               | &mdash; |  &check;  |
| `DB_HOST`               | PostgreSQL hostname                                                   | &mdash; |  &check;  |
| `DB_PORT`               | PostgreSQL port                                                       | &mdash; |  &check;  |
| `DB_NAME`               | PostgreSQL database name                                              | &mdash; |  &check;  |
| `DB_USER`               | PostgreSQL username                                                   | &mdash; |  &check;  |
| `DB_PASSWORD`           | PostgreSQL password                                                   | &mdash; |  &check;  |
| `REDIS_HOST`            | Redis instance hostname                                               | &mdash; |  &check;  |
| `REDIS_PORT`            | Redis instance port                                                   | &mdash; |  &check;  |
| `REDIS_USER`            | Redis instance username                                               |  `""`   |  &cross;  |
| `REDIS_PASS`            | Redis instance password                                               |  `""`   |  &cross;  |
| `REDIS_USE_TLS`         | Use a TLS connection when communicating with Redis?                   | `false` |  &cross;  |
| `FANART_TV_API_KEY`     | A developer [Fanart.tv](https://fanart.tv/) API key                  | &mdash; |  &cross;  |
| `THEMOVIEDB_API_KEY`    | A developer [The Movie Database](https://www.themoviedb.org) API key | &mdash; |  &cross;  |
| `PORT`                  | The port to attach the service web server to                         | `9000`  |  &cross;  |

### Running

2. Configure the required environmental variables
3. Run `npm install`
4. Run `npm start`

### Building

2. Configure the required environmental variables
3. Run `npm install`
4. Run `npm run build`
5. Run `npm run serve`
