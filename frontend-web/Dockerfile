# Multi-stage Dockerfile for React Development
FROM node:18-alpine as base

# Set working directory
WORKDIR /app

# Install dependencies
COPY package*.json ./
RUN npm ci --only=production && npm cache clean --force

# Development stage
FROM node:18-alpine as development

WORKDIR /app

# Install all dependencies (including dev)
COPY package*.json ./
RUN npm ci && npm cache clean --force

# Copy source code
COPY . .

# Create user for security
RUN addgroup -g 1001 -S nodejs
RUN adduser -S nextjs -u 1001
USER nextjs

# Expose port
EXPOSE 3000

# Development command
CMD ["npm", "run", "dev"]

# Production build stage
FROM node:18-alpine as builder

WORKDIR /app

COPY package*.json ./
RUN npm ci && npm cache clean --force

COPY . .
RUN npm run build

# Production stage
FROM nginx:alpine as production

# Copy built assets
COPY --from=builder /app/dist /usr/share/nginx/html

# Copy nginx configuration
COPY nginx.conf /etc/nginx/nginx.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]