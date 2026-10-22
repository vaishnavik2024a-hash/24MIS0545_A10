# Use ultra-lightweight Nginx alpine image to serve static content
FROM nginx:alpine

# Copy the dashboard code to the default web server root directory
COPY index.html /usr/share/nginx/html/index.html

# Expose port 80 for traffic
EXPOSE 80
