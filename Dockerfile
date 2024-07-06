FROM node:22-alpine3.20 as base

WORKDIR /app

COPY ./package.json ./package-lock.json ./

FROM base as dependencies

RUN npm ci

FROM dependencies as build

COPY \
    ./src \
    ./src

COPY ./esbuild.mjs ./tsconfig.json ./

RUN npm run build

FROM dependencies as final

RUN npm ci --omit=dev

COPY --from=build /app/dist ./

CMD ["app.js"]
