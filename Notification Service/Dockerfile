# Build stage
FROM golang:1.21-alpine AS builder

# Install git for go mod download
RUN apk add --no-cache git

WORKDIR /app

# Copy go mod files
COPY go.mod go.sum ./
RUN go mod download

# Copy source code
COPY *.go ./

# Build the binary
RUN CGO_ENABLED=0 GOOS=linux go build -o zagreus-notifications .

# Final stage
FROM alpine:latest

RUN apk --no-cache add ca-certificates

WORKDIR /app

# Copy the binary from builder
COPY --from=builder /app/zagreus-notifications .

# Copy the APNs key
COPY AuthKey_PTTBS94D2P.p8 /app/AuthKey_PTTBS94D2P.p8

# Expose port
EXPOSE 8080

# Run the binary
CMD ["./zagreus-notifications"]