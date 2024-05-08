FROM php:8.2-fpm


# Install common php extensions
RUN apt-get update && apt-get install -y \
    libfreetype-dev \
    libjpeg62-turbo-dev \
    libpng-dev \
    zlib1g-dev \
    libzip-dev \
    unzip \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) gd \
    && docker-php-ext-install zip



# set working directory
COPY . /var/www/app

WORKDIR /var/www/app

COPY .env.example .env


RUN chown -R www-data:www-data /var/www/app \
    && chmod -R 755 /var/www/app/storage
# Install composer

COPY --from=composer:latest /usr/bin/composer /usr/local/bin/composer

#copy the composer.json file and install the dependencies

COPY composer.json ./

RUN composer install 

#generate key
RUN php artisan key:generate

# clear cache
RUN php artisan config:cache

#migrate the database
RUN php artisan migrate 

#set the default command to run php-fpm
CMD ["php-fpm"]
