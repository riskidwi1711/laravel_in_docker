# Gunakan gambar resmi PHP dengan Apache sebagai dasar
FROM php:8.2-apache

# Set konfigurasi Apache
RUN echo "ServerName localhost" >> /etc/apache2/apache2.conf
RUN a2enmod rewrite

# Install dependensi yang dibutuhkan oleh Laravel
RUN apt-get update && apt-get install -y \
    git \
    curl \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    zip \
    unzip

# Install ekstensi PHP yang dibutuhkan oleh Laravel
RUN docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd

# Install Composer (manajer paket PHP)
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Set direktori kerja
WORKDIR /var/www/html

# Salin file composer.lock dan composer.json ke dalam container
COPY composer.lock composer.json /var/www/html/

# Install dependensi PHP menggunakan Composer
RUN composer install --prefer-dist --no-scripts --no-dev --no-autoloader && rm -rf /root/.composer

# Salin semua file ke dalam container
COPY . /var/www/html/

# Generate autoload dan atur izin file
RUN composer dump-autoload && chown -R www-data:www-data /var/www/html

# Set konfigurasi Apache untuk Laravel
COPY docker/apache/laravel.conf /etc/apache2/sites-available/laravel.conf
RUN a2dissite 000-default.conf && a2ensite laravel.conf && a2enmod rewrite

# Expose port 80
EXPOSE 80

# Jalankan perintah saat container dijalankan
CMD ["apache2-foreground"]
