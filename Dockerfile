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

# Set working directory
WORKDIR /var/www/html

# Copy all project files into the container
COPY . /var/www/html

# Give permissions to Laravel folders
RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 755 /var/www/html/storage /var/www/html/bootstrap/cache

# Install Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# Install Laravel dependencies
RUN composer install --no-dev --optimize-autoloader

# Set environment to production
ENV APP_ENV=production

# Start Apache
CMD ["apache2ctl", "-D", "FOREGROUND"]
