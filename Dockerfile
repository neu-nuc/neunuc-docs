# NeuNuc Internal Docs — Production nginx container
# Build:  docker build -t neunuc-docs .
# Run:    docker run -p 8080:80 neunuc-docs

FROM nginx:alpine

# Remove default nginx content
RUN rm -rf /usr/share/nginx/html/*

# Copy built MkDocs site
COPY site /usr/share/nginx/html

# Copy nginx config
COPY infra/docs-host/nginx/docs.conf /etc/nginx/conf.d/default.conf

# Copy basic auth file (generate with: htpasswd -cb .htpasswd admin <password>)
COPY infra/docs-host/.htpasswd /etc/nginx/.htpasswd

# Security headers
RUN sed -i 's/server_tokens on/server_tokens off/' /etc/nginx/nginx.conf

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
