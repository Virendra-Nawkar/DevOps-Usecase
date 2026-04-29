# Stage 1 — Install dependencies and build
FROM node:18-alpine AS builder

WORKDIR /app

# Copy package files first (layer caching — faster rebuilds)
COPY package*.json ./

# Install all dependencies
RUN npm install

# Copy rest of the source code
COPY . .

# Build Next.js app — output goes into .next/standalone/
RUN npm run build

# Stage 2 — Run only the standalone output (tiny final image)
FROM node:18-alpine AS runner

WORKDIR /app

# Copy the standalone server (contains only what's needed to run)
COPY --from=builder /app/.next/standalone ./

# Copy static assets (CSS, JS chunks, images)
COPY --from=builder /app/.next/static ./.next/static

# Copy your JSON data files
COPY --from=builder /app/data ./data

# Expose port 3000 (Next.js default port)
EXPOSE 3000

# Set environment to production
ENV NODE_ENV=production

# Start using the standalone server.js
CMD ["node", "server.js"]
