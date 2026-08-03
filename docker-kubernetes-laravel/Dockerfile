# --- Stage 1: Build Dependencies ---
FROM php:8.2-fpm-alpine AS builder

WORKDIR /var/www/html

# Install base dev dependencies
RUN apk add --no-cache \
    git \
    curl \
    libpng-dev \
    libxml2-dev \
    zip \
    unzip \
    oniguruma-dev \
    mysql-client

# Install extension modules
RUN docker-php-ext-install pdo pdo_mysql mbstring xml bcmath gd opcache

# Install composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Pre-copy composer profiles to use cached layer
COPY composer.json composer.lock* ./

RUN composer install --no-dev --no-scripts --no-interaction --prefer-dist --optimize-autoloader

# --- Stage 2: Production PHP FPM Engine ---
FROM php:8.2-fpm-alpine

WORKDIR /var/www/html

RUN apk add --no-cache \
    libpng \
    libxml2 \
    oniguruma \
    shadow

RUN docker-php-ext-install pdo pdo_mysql mbstring xml bcmath gd opcache

# Copy application source files
COPY --from=builder /var/www/html/vendor /var/www/html/vendor
COPY . .

# Setup configurations
RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 775 /var/www/html/storage /var/www/html/bootstrap/cache

USER www-data

EXPOSE 9000

CMD ["php-fpm"]
