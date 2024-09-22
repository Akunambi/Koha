FROM debian:bullseye-slim

# Set environment variables
ENV DEBIAN_FRONTEND noninteractive

# Install necessary dependencies
RUN apt-get update && \
    apt-get install -y \
    sudo wget gnupg2 lsb-release curl apache2 \
    mariadb-server libapache2-mod-perl2 \
    && apt-get clean

# Add Koha GPG key and sources list
RUN wget -qO - https://debian.koha-community.org/koha/gpg.asc | gpg --dearmor -o /usr/share/keyrings/koha-keyring.gpg \
    && echo 'deb [signed-by=/usr/share/keyrings/koha-keyring.gpg] https://debian.koha-community.org/koha 24.05 main' | tee /etc/apt/sources.list.d/koha.list

# Install Koha
RUN apt-get update && \
    apt-get install -y koha-common

# Enable Apache modules
RUN a2enmod rewrite cgi headers proxy_http

# Configure MariaDB
RUN service mariadb start \
    && mysql -e "CREATE USER 'koha'@'localhost' IDENTIFIED BY 'password';" \
    && mysql -e "GRANT ALL PRIVILEGES ON *.* TO 'koha'@'localhost';" \
    && mysql -e "FLUSH PRIVILEGES;" \
    && koha-create --create-db libraryname

# Start Koha and Plack
RUN koha-plack --enable libraryname \
    && koha-plack --start libraryname

# Expose the necessary ports for OPAC and staff interface
EXPOSE 80 8080

# Start Apache
CMD ["apachectl", "-D", "FOREGROUND"]
