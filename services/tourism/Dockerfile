# syntax=docker/dockerfile:1

# ---------- Stage 1: install workspace deps ----------
FROM node:20-slim AS deps
WORKDIR /repo
COPY package.json package-lock.json ./
COPY packages/shared/package.json packages/shared/package.json
COPY services/tourism/package.json services/tourism/package.json
RUN npm ci --workspace=services/tourism --include-workspace-root --omit=dev

# ---------- Stage 2: runtime ----------
FROM node:20-slim AS runtime
ENV NODE_ENV=production
RUN groupadd -r appuser && useradd -r -g appuser appuser
WORKDIR /repo
COPY --from=deps /repo/node_modules ./node_modules
COPY --from=deps /repo/package.json ./package.json
COPY packages/shared ./packages/shared
COPY services/tourism ./services/tourism
WORKDIR /repo/services/tourism
USER appuser
EXPOSE 4006
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD node -e "require('http').get('http://localhost:4006/health', r => process.exit(r.statusCode===200?0:1)).on('error', () => process.exit(1))"
CMD ["node", "src/index.js"]
