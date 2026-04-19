FROM node:22-alpine AS build

WORKDIR /app

COPY web/package.json ./package.json
COPY web/package-lock.json ./package-lock.json
COPY web/astro.config.mjs ./astro.config.mjs
COPY web/tsconfig.json ./tsconfig.json
RUN npm ci

COPY web/src ./src
COPY web/public ./public
RUN npm run build

FROM nginx:1.27-alpine AS runtime

COPY web/nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=build /app/dist /usr/share/nginx/html
COPY setup.sh /usr/share/nginx/html/setup.sh

EXPOSE 80
