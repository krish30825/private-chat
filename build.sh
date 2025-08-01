#!/usr/bin/env bash
set -o errexit

# Install PHP dependencies using Composer
composer install --no-dev --optimize-autoloader
