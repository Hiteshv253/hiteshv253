# --- Stage 1: Build Dependencies ---
FROM php:8.2-fpm-alpine AS builder

# Set working directory
WORKDIR /var/www/html

# Install build system dependencies
RUN apk add --no-cache \
    git \
    curl \
    libpng-dev \
    libxml2-dev \
    zip \
    unzip \
    oniguruma-dev \
    postgresql-dev

# Install PHP extensions required for Laravel
RUN docker-php-ext-install pdo pdo_mysql pdo_pgsql mbstring xml bcmath gd opcache

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Copy application configuration files
COPY composer.json composer.lock* ./

# Install application dependencies (no scripts/no dev)
RUN composer install --no-dev --no-scripts --no-interaction --prefer-dist --optimize-autoloader

# --- Stage 2: Production Build ---
FROM php:8.2-fpm-alpine

# Set working directory
WORKDIR /var/www/html

# Install runtime production dependencies
RUN apk add --no-cache \
    postgresql-libs \
    libpng \
    libxml2 \
    oniguruma \
    shadow

# Install production PHP extensions
RUN docker-php-ext-install pdo pdo_mysql pdo_pgsql mbstring xml bcmath gd opcache

# Copy OPcache configuration
COPY docker/opcache.ini /usr/local/etc/php/conf.d/opcache.ini

# Copy build artifacts and source code
COPY --from=builder /var/www/html/vendor /var/www/html/vendor
COPY . .

# Adjust file permissions for security (Laravel files run under non-root developer www-data)
RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 775 /var/www/html/storage /var/www/html/bootstrap/cache

# Switch to www-data user
USER www-data

# Expose PHP-FPM port
EXPOSE 9000

CMD ["php-fpm"]
