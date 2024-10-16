# Base image for Node.js
FROM node:16-alpine

# Install bash
# RUN apk add --no-cache bash

# Set working directory
WORKDIR /app

# Install app dependencies
COPY package*.json ./
RUN npm install

# Copy the rest of the application code
COPY . .

# Set the API_URL environment variable
ARG VUE_APP_API_URL
ENV VUE_APP_API_URL=$VUE_APP_API_URL

# Build the Vue.js app for production
RUN npm run build

# Install a simple HTTP server to serve the production build
RUN npm install -g http-server

# Expose the necessary port
EXPOSE 8080

# Serve the built app using the HTTP server
CMD ["http-server", "dist"]