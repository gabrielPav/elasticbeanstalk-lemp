#!/bin/bash

# Check if user is root
if [ $(id -u) != "0" ]; then
    echo "Error: You must be root to run this script, please use root to install LEMP"
    exit 1
fi

# Install Nginx and ngx_pagespeed dependencies
yum -y install wget zip unzip openssl openssl-devel gcc-c++ pcre-dev pcre-devel zlib-devel make

# Install ngx_pagespeed module
NPS_VERSION=1.9.32.3
wget https://github.com/pagespeed/ngx_pagespeed/archive/release-${NPS_VERSION}-beta.zip
unzip release-${NPS_VERSION}-beta.zip
cd ngx_pagespeed-release-${NPS_VERSION}-beta/
wget https://dl.google.com/dl/page-speed/psol/${NPS_VERSION}.tar.gz
tar -xzvf ${NPS_VERSION}.tar.gz
cd

# Install Nginx
NGINX_VERSION=1.8.0
wget http://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz
tar -xvzf nginx-${NGINX_VERSION}.tar.gz
cd nginx-${NGINX_VERSION}/
./configure --add-module=$HOME/ngx_pagespeed-release-${NPS_VERSION}-beta --with-http_gzip_static_module --with-http_realip_module --with-http_ssl_module
make
make install
cd

# Download the Nginx configuration files
touch /usr/local/nginx/conf/nginx.conf
touch /usr/local/nginx/conf/webapp.conf
touch /etc/init.d/nginx

wget https://raw.githubusercontent.com/gabrielPav/elasticbeanstalk-lemp/master/conf/nginx/nginx.conf -O /usr/local/nginx/conf/nginx.conf
wget https://raw.githubusercontent.com/gabrielPav/elasticbeanstalk-lemp/master/conf/nginx/webapp.conf -O /usr/local/nginx/conf/webapp.conf
wget https://raw.githubusercontent.com/gabrielPav/elasticbeanstalk-lemp/master/conf/nginx/nginx.init.txt -O /etc/init.d/nginx

chmod +x /etc/init.d/nginx
chkconfig nginx on

# Install PHP 5.4
echo 'Installing PHP-FPM'
yum -y install php54.x86_64 php54-bcmath.x86_64 php54-cli.x86_64 php54-common.x86_64 php54-dba.x86_64 php54-devel.x86_64 php54-fpm.x86_64 php54-gd.x86_64 php54-intl.x86_64 php54-mbstring.x86_64 php54-mcrypt.x86_64 php54-pdo.x86_64 php54-process.x86_64 php54-xml.x86_64 php54-imap.x86_64 php54-odbc.x86_64 php54-ldap.x86_64 php54-soap.x86_64 php54-tidy.x86_64 php54-snmp.x86_64
chkconfig php-fpm on

# Change the user/group of PHP-FPM processes
sed -i 's/user = apache/user = webapp/g' /etc/php-fpm.d/www.conf
sed -i 's/group = apache/group = webapp/g' /etc/php-fpm.d/www.conf

# Change some PHP variables
sed -i 's/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g' /etc/php.ini
sed -i 's/max_execution_time = 30/max_execution_time = 90/g' /etc/php.ini
sed -i 's/max_input_time = 60/max_input_time = 90/g' /etc/php.ini
sed -i 's/memory_limit = 128M/memory_limit = 512M/g' /etc/php.ini
sed -i 's/display_errors = On/display_errors = Off/g' /etc/php.ini

# Remove install files
/bin/rm -rf /root/nginx-1.8.0
/bin/rm -rf /root/nginx-1.8.0.tar.gz
/bin/rm -rf /root/ngx_pagespeed-release-1.9.32.3-beta
/bin/rm -rf /root/release-1.9.32.3-beta.zip

# Replace the httpd process with an empty process
mv /usr/sbin/httpd /usr/sbin/httpd.disabled
touch /usr/sbin/httpd
echo '#!/bin/bash' >> /usr/sbin/httpd
chmod 755 /usr/sbin/httpd

# Locking HTTP and PHP version
echo "exclude=php* httpd*" >> /etc/yum.conf

# Starting services
service nginx start
service php-fpm start
chkconfig nginx on
chkconfig php-fpm on
php -v

echo 'Done.'
