# Shared image for the Next.js dashboards (portal / admin / sales).
# The build context is an individual app directory (see web/docker-compose.yml);
# this single Dockerfile is reused for each app.
FROM node:20-alpine

WORKDIR /app

# NEXT_PUBLIC_* values are inlined into the client bundle at BUILD time, so the
# API URL must be provided as a build arg (see docker-compose build.args).
ARG NEXT_PUBLIC_API_URL
ENV NEXT_PUBLIC_API_URL=$NEXT_PUBLIC_API_URL
ENV NEXT_TELEMETRY_DISABLED=1

# Install dependencies first for better layer caching.
COPY package.json package-lock.json* ./
RUN npm ci

# App source. node_modules/.next/.env* are excluded via .dockerignore so the
# build arg above is the single source of the API URL.
COPY . .
RUN npm run build

ENV NODE_ENV=production
ENV PORT=3000
EXPOSE 3000

# next start (and the admin wrapper) serve on 0.0.0.0:$PORT.
CMD ["npm", "run", "start"]
