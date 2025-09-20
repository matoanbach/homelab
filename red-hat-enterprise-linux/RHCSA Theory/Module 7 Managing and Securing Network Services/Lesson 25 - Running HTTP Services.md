# Lesson 25: Running HTTP Services
- 25.1 Exploring HTTP configuration
- 25.2 Creating a Basic Web Site

## 25.1 Exploring HTTP Configuration
- Apache (`httpd`) is a common web server on Linux
- Ngix is another common web server
- The main httpd configuration file is `/etc/httpd/conf/httpd.conf`
- Additional drop-in files can be stored in `/etc/httpd/conf.d/`
- The default DocumentRoot is `/var/www/htdocs`
- Apache looks for a file with the name `index.html` in this directory

## 25.2 Creating a Basic Web Site

- logs are forwarded to `/var/log/httpd`

## Lesson 25 Lab: Managin HTTP Services

- Configure Apache to serve a basic website that shows the text "hello world" after connecting to it
- Use `curl localhost` to verify connection