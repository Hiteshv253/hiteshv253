#!/usr/bin/env bash
set -e

# ==============================================================================
# ZERO DOWNTIME DEPLOYMENT SCRIPT FOR LARAVEL (VPS/ON-PREMISE)
# ==============================================================================
# This script deploys a Laravel application using a symlink switching pattern:
# /var/www/app
#   ├── current -> releases/20260803120000 (symlink)
#   ├── shared (storage, .env, logs)
#   └── releases
#       ├── 20260803110000
#       └── 20260803120000
# ==============================================================================

PROJECT_ROOT="/var/www/app"
RELEASES_DIR="${PROJECT_ROOT}/releases"
SHARED_DIR="${PROJECT_ROOT}/shared"
RELEASE_NAME=$(date +%Y%m%d%H%M%S)
NEW_RELEASE_DIR="${RELEASES_DIR}/${RELEASE_NAME}"
KEEP_RELEASES=5

echo "🚀 Starting deployment of release: ${RELEASE_NAME}..."

# 1. Ensure Directories Exist
mkdir -p "${RELEASES_DIR}"
mkdir -p "${SHARED_DIR}"
mkdir -p "${SHARED_DIR}/storage"
mkdir -p "${SHARED_DIR}/storage/app"
mkdir -p "${SHARED_DIR}/storage/framework/cache"
mkdir -p "${SHARED_DIR}/storage/framework/sessions"
mkdir -p "${SHARED_DIR}/storage/framework/views"
mkdir -p "${SHARED_DIR}/storage/logs"

# 2. Clone/Copy Code to New Release Directory
echo "📦 Preparing codebase..."
# In a real environment, we'd pull from git: git clone --depth 1 git@github.com:user/repo.git "${NEW_RELEASE_DIR}"
# For demo purposes, we copy current workspace files:
cp -R . "${NEW_RELEASE_DIR}"

# 3. Bind Shared Environment (.env) and Storage
echo "🔗 Linking shared assets..."
rm -rf "${NEW_RELEASE_DIR}/storage"
ln -nfs "${SHARED_DIR}/.env" "${NEW_RELEASE_DIR}/.env"
ln -nfs "${SHARED_DIR}/storage" "${NEW_RELEASE_DIR}/storage"

# 4. Install Composer Packages
echo "🔌 Installing Composer dependencies..."
cd "${NEW_RELEASE_DIR}"
composer install --no-dev --no-interaction --prefer-dist --optimize-autoloader --no-scripts

# 5. Run Database Migrations
echo "🗄️ Running migrations..."
php artisan migrate --force

# 6. Warm Up Caches & Optimize
echo "⚡ Optimizing Laravel config & routes caching..."
php artisan config:cache
php artisan route:cache
php artisan view:cache

# 7. Switch Symlink (The atomic switch point)
echo "🔄 Switching active symlink to new release..."
ln -nfs "${NEW_RELEASE_DIR}" "${PROJECT_ROOT}/current"

# 8. Reload PHP-FPM and Nginx
echo "🌀 Reloading services..."
# Using sudo to reload FPM and Nginx without restarting container/server to prevent connections dropping
sudo systemctl reload php8.2-fpm || echo "Skipping php-fpm reload (not systemd)"
sudo systemctl reload nginx || echo "Skipping nginx reload (not systemd)"

# 9. Clean up Old Releases
echo "🧹 Cleaning up older releases (keeping last ${KEEP_RELEASES})..."
cd "${RELEASES_DIR}"
ls -1t | tail -n +$((KEEP_RELEASES + 1)) | xargs -I {} rm -rf {}

echo "🎉 Deployment successful! Active directory: $(readlink -f ${PROJECT_ROOT}/current)"
