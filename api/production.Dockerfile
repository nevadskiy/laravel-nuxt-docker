# CLI image
FROM php:8.3-cli as build

# Retrieve APT lists
RUN apt-get update \
# Install Zip
  && apt-get install -y libzip-dev zip \
  && docker-php-ext-install zip \
# Install Git
  && apt-get install -y git \
# Install Swoole extension
  && pecl install swoole \
  && docker-php-ext-enable swoole \
# Install Process Control extension
  && docker-php-ext-install pcntl \
  && docker-php-ext-enable pcntl \
# Install PDO PGSQL extension
  && apt-get install -y libpq-dev \
  && docker-php-ext-install pdo pdo_pgsql \
# Install Redis extension
  && pecl install redis \
  && docker-php-ext-enable redis \
# Remove APT lists
  && rm -rf /var/lib/apt/lists/*

# Install Composer package manager
COPY --from=composer:latest /usr/bin/composer /usr/local/bin/composer

# Specify working directory
WORKDIR /app

# Copy application files
COPY . .

# Change owner for application files
RUN chown -R www-data:www-data .

# Install Composer dependencies
RUN composer install \
  --no-dev \
  --optimize-autoloader \
  --no-interaction

# Change mode for entrypoint script
RUN chmod +x ./entrypoint.sh