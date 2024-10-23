# Base image for Node.js
FROM node:16-alpine

# Set working directory
WORKDIR /app

# Install app dependencies
COPY package*.json ./
RUN npm install --force

# Copy the rest of the application code
COPY . .

# Build the Vue.js app for production
RUN npm run build

# Install a simple HTTP server to serve the production build
RUN npm install -g http-server

# Expose the necessary port
EXPOSE 8080

# Serve the built app using the HTTP server
CMD ["http-server", "dist"]
