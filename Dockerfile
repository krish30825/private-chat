# Step 1: Use official PHP with Apache image
FROM php:7.4-apache

# Step 2: Install PHP extensions required by Laravel
RUN apt-get update && apt-get install -y \
    libzip-dev \
    unzip \
    zip \
    git \
    curl \
    && docker-php-ext-install pdo pdo_mysql zip

# Step 3: Enable Apache mod_rewrite
RUN a2enmod rewrite

# Step 4: Set the document root to /var/www/html/public
RUN sed -i 's|DocumentRoot /var/www/html|DocumentRoot /var/www/html/public|g' /etc/apache2/sites-available/000-default.conf

# Step 5: Copy project files into the container
COPY . /var/www/html

# Step 6: Set working directory
WORKDIR /var/www/html

# Step 7: Set permissions for Laravel directories
RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 755 /var/www/html \
    && chmod -R 775 /var/www/html/storage /var/www/html/bootstrap/cache

# Step 8: Expose Apache port
EXPOSE 80
