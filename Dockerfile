# Stage 1: build the website with the assignment's pinned Node.js tag.
FROM node:22-alpine AS builder

# Keep dependency installation and source files in a predictable location.
WORKDIR /app

# Copy manifests first so unchanged dependencies can reuse cached layers.
COPY package*.json ./

# Install the exact locked dependencies, including Parcel for the build.
RUN npm ci

# Copy only the HTML sources and the single shared stylesheet.
COPY src/ ./src/
COPY styles/ ./styles/

# Bundle all five HTML entry points and their CSS into /app/dist.
RUN npm run build

# Stage 2: serve the built static website with the pinned Nginx runtime.
FROM nginx:1.27-alpine

# Copy only generated static files; Node.js and node_modules stay in builder.
COPY --from=builder /app/dist /usr/share/nginx/html

# Document the HTTP port used inside the container.
EXPOSE 80

# Run Nginx in the foreground so the container remains alive.
CMD ["nginx", "-g", "daemon off;"]
