FROM nginx:alpine

# Copy the static site into Nginx's web root.
# (HTML files use relative links like `css/styles.css` and `index.html`.)
COPY website/ /usr/share/nginx/html/

EXPOSE 80

