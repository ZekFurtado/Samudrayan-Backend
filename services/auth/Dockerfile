# syntax=docker/dockerfile:1

# ---------- Stage 1: install workspace deps ----------
FROM node:20-slim AS deps
WORKDIR /repo
COPY package.json package-lock.json ./
COPY packages/shared/package.json packages/shared/package.json
COPY packages/shared-firebase/package.json packages/shared-firebase/package.json
COPY services/auth/package.json services/auth/package.json
RUN npm ci --workspace=services/auth --include-workspace-root --omit=dev

# ---------- Stage 2: runtime ----------
FROM node:20-slim AS runtime
ENV NODE_ENV=production
RUN groupadd -r appuser && useradd -r -g appuser appuser
WORKDIR /repo
COPY --from=deps /repo/node_modules ./node_modules
COPY --from=deps /repo/package.json ./package.json
COPY packages/shared ./packages/shared
COPY packages/shared-firebase ./packages/shared-firebase
COPY services/auth ./services/auth
WORKDIR /repo/services/auth
USER appuser
EXPOSE 4001
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD node -e "require('http').get('http://localhost:4001/health', r => process.exit(r.statusCode===200?0:1)).on('error', () => process.exit(1))"
CMD ["node", "src/index.js"]
