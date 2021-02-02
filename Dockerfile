FROM node:14-alpine AS BUILD_IMAGE

WORKDIR /usr/src/app

COPY package.json yarn.lock ./

# install dependencies
RUN yarn --frozen-lockfile

COPY . .

# lint & test
RUN yarn lint & yarn test

# build application
RUN yarn build

# remove development dependencies
RUN npm prune --production

FROM node:14-alpine

WORKDIR /usr/src/app

# copy from build image
COPY --from=BUILD_IMAGE /usr/src/app/dist ./dist
COPY --from=BUILD_IMAGE /usr/src/app/node_modules ./node_modules
COPY --from=BUILD_IMAGE /usr/src/app/.env.example ./.env.example

EXPOSE 3000

CMD [ "node", "./dist/index.js" ]