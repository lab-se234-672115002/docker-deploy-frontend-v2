#FROM node:22-alpine AS build-stage
#WORKDIR /app
#COPY package*.json ./
#RUN npm install && \
#    npm ci
#COPY . .
#ARG BUILD_MODE=production
#RUN npm run build -- --mode ${BUILD_MODE}

#FROM nginx:alpine AS production-stage
#COPY nginx-custom.conf /etc/nginx/conf.d/default.conf
#COPY --from=build-stage /app/dist /usr/share/nginx/html
#EXPOSE 8080
#CMD ["nginx", "-g", "daemon off;"]
#
FROM node:22-alpine AS build-stage
WORKDIR /app
COPY package*.json ./
RUN npm install && \
    npm ci
COPY . .
RUN VITE_GRAPHQ_URI=__VITE_GRAPHQL_URI_PLACEHOLDER__ \
    VITE_SERVER_URI_=_VITE_SERVER_URI_PLACEHOLDER__ \
    npm run build -- --mode production
FROM nginx:alpine AS production-stage
COPY nginx-custom.conf /etc/nginx/conf.d/default.conf
COPY --from=build-stage /app/dist /usr/share/nginx/html
COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh
EXPOSE 8080
ENTRYPOINT [ "/docker-entrypoint.sh" ]
