# Sample Dockerfile for WordPress
# Note that installing MySQL in this container functionally makes it available to WordPress only - if you have multiple apps that need MySQL, you should run that in a separate container
# Also note that we're building this image using Debian Jessie as a base image, but there are official Docker images available for both PHP and MySQL

FROM debian:jessie

# Adding placeholder environment variables
# Set these environment variables in your Distelli application, both in Build Variables and Env Vars
# Pass the environment variables in the docker run command

# ENV MYSQL_ROOT_PASSWORD $MYSQL_ROOT_PASSWORD
# ENV DB_NAME $DB_NAME
# ENV DB_USER_NAME $DB_USER_NAME
# ENV DB_USER_PASSWORD $DB_USER_PASSWORD

# Installing nginx and PHP
# To minimize the number of layers, chain the commands using &&
# For readability, use \ and create a new line for every package
# To save the MySQL database, in the docker run command, mount a local directory to /var/lib/mysql in the container

RUN	apt-get update && \
			apt-get install -y php5-fpm \
			php5-mysql \
			nginx

# Installing mysql in non-interactive mode
# Note that this leads to the root password being blank: you’ll need to initialize the database when you start the container

RUN DEBIAN_FRONTEND=noninteractive apt-get -y install mysql-server

VOLUME /var/lib/mysql

# Adding WordPress
# Assumes that in the PreBuild steps, you've downloaded wordpress to a folder called wp-download

COPY ./wp-download /usr/share/nginx/html

# Setting up WordPress
RUN sed -i 's/database_name_here/'$DB_NAME'/g' /usr/share/nginx/html/wp-config-sample.php && \
		sed -i 's/username_here/'$DB_USER_NAME'/g' /usr/share/nginx/html/wp-config-sample.php && \
    sed -i 's/password_here/'$DB_USER_PASSWORD'/g'/usr/share/nginx/html/wp-config-sample.php && \
    cp /usr/share/nginx/html/wp-config-sample.php /usr/share/nginx/html/wp-config.php && \
    chmod 640 /usr/share/nginx/html/wp-config.php && \
    chown www-data:www-data /usr/share/nginx/html/wp-config.php

# Skipping entrypoint for now
# Put all of these into a run script, maybe?
CMD mysql -u root -p$MYSQL_ROOT_PASSWORD -e 'CREATE DATABASE IF NOT EXISTS '$DB_NAME'; GRANT ALL PRIVILEGES ON '$DB_NAME'.* TO '$DB_USER_NAME' IDENTIFIED BY "'$DB_USER_PASSWORD'"'

CMD service nginx restart
