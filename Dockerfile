# Use the official PHP Apache image
FROM php:7.4-apache

# Install system dependencies and PHP extensions
RUN apt-get update && apt-get install -y \
    libzip-dev zip unzip git curl \
    && docker-php-ext-install pdo pdo_mysql zip

# Enable Apache mod_rewrite (needed for Laravel routing)
RUN a2enmod rewrite

# Set Apache to serve from Laravel's public directory
RUN sed -i 's|DocumentRoot /var/www/html|DocumentRoot /var/www/html/public|' /etc/apache2/sites-available/000-default.conf

# Update the <Directory> directive in Apache config
RUN sed -i '/<Directory \/var\/www\/>/,/<\/Directory>/c\\
<Directory /var/www/html/public>\n\
    Options Indexes FollowSymLinks\n\
    AllowOverride All\n\
    Require all granted\n\
</Directory>' /etc/apache2/apache2.conf

# Set working directory
WORKDIR /var/www/html

# Copy all project files into the container
COPY . /var/www/html

# Ensure Laravel .htaccess exists
RUN if [ ! -f /var/www/html/public/.htaccess ]; then echo "<IfModule mod_rewrite.c>\nRewriteEngine On\nRewriteRule ^(.*)$ public/\$1 [L]\n</IfModule>" > /var/www/html/public/.htaccess; fi

# Give permissions to Laravel folders
RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 755 /var/www/html/storage /var/www/html/bootstrap/cache

# Install Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# Install Laravel dependencies
RUN composer install --no-dev --optimize-autoloader

# Set environment to production
ENV APP_ENV=production

# Expose port 80
EXPOSE 80

# Start Apache
CMD ["apache2ctl", "-D", "FOREGROUND"]
