# build
FROM node:20-alpine AS builder
RUN sed -i 's#https\?://dl-cdn.alpinelinux.org/alpine#https://mirrors.tuna.tsinghua.edu.cn/alpine#g' /etc/apk/repositories; apk update; apk add g++ dotnet6-runtime;

WORKDIR /app
COPY package*.json ./
RUN npm install --registry=https://registry.npmmirror.com

COPY . .

# add .env.example to .env
RUN [ ! -e ".env" ] && cp .env.example .env || true

RUN npx electron-vite build

# nginx
FROM nginx:1.27-alpine-slim AS app

COPY --from=builder /app/out/renderer /usr/share/nginx/html

COPY --from=builder /app/nginx.conf /etc/nginx/conf.d/default.conf

RUN apk add --no-cache npm

RUN npm install -g NeteaseCloudMusicApi

CMD nginx && npx NeteaseCloudMusicApi
