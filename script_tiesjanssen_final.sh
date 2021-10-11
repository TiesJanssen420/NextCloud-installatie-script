echo "test"
#!/bin/bash
restart=y
while [ $restart == "y" ]
do
clear
echo "Welkom bij het NextCloud server installatie script"
echo ""
#webserverkeuze
echo "De installatie voor de webserver start nu."
echo "Je hebt voor de installatie 3 keuzes:"
echo -n "Kies uit: apache, nginx, lighttpd "; read webservers
echo ""

#installatie webserver
function Install-webserver
{
	echo "Je hebt voor "$webservers" gekozen."
	echo "De installatie voor "$webservers"wordt gestart.";
}

function message-webserver
{
	echo ""$webservers" is al geinstaleerd.";      
}

if [ $webservers == "apache" ];
        then
                Install-web
                systemctl start apache2
	if ( systemctl -q is-active apache2 == "inactive" )
		then
			message-web
		else
			apt install apache2
			systemctl stop apache2.service
			systemctl start apache2.service
			systemctl enable apache2.service
	fi
fi

if [ $webservers == "nginx" ];
        then
                Install-web
                systemctl start nginx
	if ( systemctl -q is-active nginx == "inactive" )
		then
			message-web
		else
			apt install nginx
			systemctl stop nginx.service
			systemctl start nginx.service
			systemctl enable nginx.service
	fi
fi

if [ $webservers == "lighttpd" ];
        then
                Install-web
                systemctl start lightpd
	if ( systemctl -q is-active lightpd == "inactive" )
		then
			message-web
		else
			apt install lightpd
			systemctl stop lightpd.service
			systemctl start lightpd.service
			systemctl enable lightpd.service
	fi
fi

#Keuze
echo -n "Geef de gewenste naam van het domein op: "; read domainname
echo ""

#database keuze
echo "De installatie voor de database start nu."
echo "Je hebt voor de installatie 2 keuzes:"
echo -n "Kies uit: mysql of mariadb "; read database
echo ""

function Install-database
{
	echo "Je hebt voor "$database"gekozen."
	echo "De installatie voor "$database"wordt gestart.";
}

function message-database
{
	echo ""$database" is al geinstaleerd.";        
}

if [ $database == "mysql" ]
        then
                Install-web
                systemctl start mysql-server mysql-client
	if ( systemctl -q is-active mysql == "inactive" )
		then
			message-web
		else
			apt install mysql-server mysql-client
			systemctl stop mysql.service
			systemctl start mysql.service
			systemctl enable mysql.service
	fi
fi

if [ $database == "mariadb" ]
        then
                Install-web
                systemctl start mariadb-server mariadb-client
	if ( systemctl -q is-active mariadb == "inactive" )
		then
			message-web
		else
			apt install mariadb-server mariadb-client
			systemctl stop mariadb.service
			systemctl start mariadb.service
			systemctl enable mariadb.service
	fi
fi

#check in downloads voor nextcloud
if [ -f "nextcloud-21.0.2.zip" ];
    then
        echo "nextcloud is al gedownload"
    else
        wget https://download.nextcloud.com/server/releases/nextcloud-21.0.2.zip
fi

#check of unzip er is
if [ -f "/usr/bin/unzip" ]
	then
        	echo "unzip is al geinstalleerd"
        else
           	apt install unzip
fi

unzip nextcloud-21.0.2.zip
mv nextcloud/ /var/www/

#permissions voor nextcloud
chown -R www-data:www-data /var/www/nextcloud
a2dissite 000-default.conf
systemctl reload apache2

#configuratie apache
echo -n "Wilt u zelf de configuratie instellen van apache? (y/n):"; read configapache

if [ $configapache == "y" ];
	then
		echo "Maak met de volgende command het configuratie bestand aan:"
		echo "nano /etc/apache2/sites-available/nextcloud.conf"
		sleep 1s
		echo "Hier volgt de configuratie"
		echo ""
		echo "<VirtualHost *:80>"
		echo 'DocumentRoot "/var/www/nextcloud"'
		echo "ServerName nextcloud"
		echo ""
		echo '<Directory "/var/www/nextcloud/">'
		echo "Options MultiViews FollowSymlinks"
		echo "AllowOverride All"
		echo "Order allow,deny"
		echo "Allow from all"
		echo "</Directory>"
		echo ""
		echo "TransferLog /var/log/apache2/nextcloud_access.log"
		echo "ErrorLog /var/log/apache2/nextcloud_error.log"
		echo ""
		echo "</VirtualHost>"
fi
if [ $configapache == "n" ];
	then
        	rm -f /etc/apache2/sites-available/nextcloud.conf
	 	touch /etc/apache2/sites-available/nextcloud.conf
           	echo "<VirtualHost *:80>" >> /etc/apache2/sites-available/nextcloud.conf
           	echo 'DocumentRoot "/var/www/nextcloud"' >> /etc/apache2/sites-available/nextcloud.conf
           	echo "ServerName nextcloud" >> /etc/apache2/sites-available/nextcloud.conf
           	echo "" >> /etc/apache2/sites-available/nextcloud.conf
           	echo '<Directory "/var/www/nextcloud/">' >> /etc/apache2/sites-available/nextcloud.conf
           	echo "Options MultiViews FollowSymlinks" >> /etc/apache2/sites-available/nextcloud.conf
           	echo "AllowOverride All" >> /etc/apache2/sites-available/nextcloud.conf
           	echo "Order allow,deny" >> /etc/apache2/sites-available/nextcloud.conf
           	echo "Allow from all" >> /etc/apache2/sites-available/nextcloud.conf
           	echo "</Directory>" >> /etc/apache2/sites-available/nextcloud.conf
           	echo "" >> /etc/apache2/sites-available/nextcloud.conf
           	echo "ransferLog /var/log/apache2/nextcloud_access.log" >> /etc/apache2/sites-available/nextcloud.conf
           	echo "ErrorLog /var/log/apache2/nextcloud_error.log" >> /etc/apache2/sites-available/nextcloud.conf
   		echo "" >> /etc/apache2/sites-available/nextcloud.conf
           	echo "</VirtualHost>" >> /etc/apache2/sites-available/nextcloud.conf

fi

#configuratie mariadb
echo -n "Wilt u zelf de configuratie instellen van de database? (y/n):"; read configdb
if [ $configdb == "y" ];
	then
		echo "Hier volgt de configuratie van mariadb die ingevuld moet worden:"
		sleep 1s
		echo "sudo mariadb"
		echo "CREATE DATABASE nextcloud"
		echo "GRANT ALL PRIVILEGES ON Nextcloud.* TO 'ties'@'localhost' IDENTIFIED BY 'P0iuytrewq';"
		echo "FLUSH PRIVILEGES;"
		echo ""
fi

if [ $configdb == "n" ];
	then
		mysql -e "CREATE DATABASE nextcloud"
		mysql -e "GRANT ALL PRIVILEGES ON nextcloud.* TO 'ties'@'localhost' IDENTIFIED BY 'P0iuytrewq';"
		mysql -e "FLUSH PRIVILEGES"
fi


#configuratie nextcloud
echo -n "Wilt u zelf de configuratie instellen van NextCloud? (y/n):"; read configcloud
if [ $configcloud == "y" ];
	then
		echo "Open de config met het volgende commando:"
		sleep 1s
		echo "nano var/www/nextcloud/config/config.php"
		echo "Voeg de volgende regel doe aan het bestand:"
		echo "'memecache.local' => '\OC\Memcache\APCu',"
fi

if [ $configcloud == "n" ];
	then
        	sed -i "s/);/  'memcache.local' => '\OC\Memcache\APCu',/g" /var/www/nextcloud/config/config.php
        	sed -i -e '$a);' /var/www/nextcloud/config/config.php
fi

#config php
echo -n "Wilt u zelf de configuratie instellen van PhP? (y/n):"; read configphp

if [ $configphp == "y" ];
        then
        	echo "Open de config met het volgende commando:"
        	sleep 1s
        	echo "nano /etc/php/7.3/apache2/php.ini"
        	echo "memory_limit = 512M"
        	echo "upload_max_filesize = 200M"
        	echo "max_execution_time = 360"
         	echo "post_max_size = 200M"
         	echo "date.timezone = Netherlands/Amsterdam"
         	echo "opcache.enable=1"
         	echo "opcache.interned_strings_buffer=8"
         	echo "opcache.max_accelerated_files=10000"
         	echo "opcache.memory_consumption=128"
         	echo "opcache.save_comments=1"
         	echo "opcache.revalidate_freq=1"
fi

if [ $configphp == "n" ];
	then
      		sed -i 's/memory_limit = 128M/memory_limit = 512M/g' /etc/php/7.3/apache2/php.ini
        	sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 200M/g' /etc/php/7.3/apache2/php.ini
         	sed -i 's/max_execution_time = 30/max_execution_time = 360/g' /etc/php/7.3/apache2/php.ini
         	sed -i 's/post_max_size = 8M/post_max_size = 200M/g' /etc/php/7.3/apache2/php.ini
         	sed -i 's/;date.timezone =/date.timezone = Netherlands/Amsterdam/g' /etc/php/7.3/apache2/php.ini
         	sed -i 's/;opcache.enable=1/opcache.enable=1/g' /etc/php/7.3/apache2/php.ini
         	sed -i 's/;opcache.interned_strings_buffer=8/opcache.interned_strings_buffer=8/g' /etc/php/7.3/apache2/php.ini
         	sed -i 's/;opcache.max_accelerated_files=10000/opcache.max_accelerated_files=10000/g' /etc/php/7.3/apache2/php.ini
         	sed -i 's/;opcache.memory_consumption=128/opcache.memory_consumption=128/g' /etc/php/7.3/apache2/php.ini
         	sed -i 's/;opcache.save_comments=1/opcache.save_comments=1/g' /etc/php/7.3/apache2/php.ini
         	sed -i 's/;opcache.revalidate_freq=2/opcache.revalidate_freq=1/g' /etc/php/7.3/apache2/php.ini
fi

#fail2ban install
echo "Fail2Ban wordt nu geinstalleerd"
sleep 1s
apt install fail2ban
systemctl start fail2ban.service
systemctl enable fail2ban.service


#fail2ban configuratie
echo -n "Wilt u zelf de configuratie instellen van Fail2Ban? (y/n):"; read configf2b
case $configf2b in
	y)
		echo "Hier volgt een voorbeeldconfiguratie van fail2ban"
		sleep 1s
		echo cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local
		echo sed -i 's/#ignoreip = 127.0.0.1/ignoreip = 127.0.0.1/g' /etc/fail2ban/jail.local	
		echo sed -i 's/bantime  = 15m/bantime  = 120m/g' /etc/fail2ban/jail.local
		echo sed -i 's/findtime  = 15m/findtime  = 120m/g' /etc/fail2ban/jail.local
		echo sed -i 's/maxretry = 5/maxretry = 7/g' /etc/fail2ban/jail.local
		echo sed -i '247 i maxretry = 3' /etc/fail2ban/jail.local
		echo sed -i '248 i enable = true' /etc/fail2ban/jail.local
		echo sudo systemctl restart fail2ban
		;;
	n)
		echo "Fail2Ban wordt nu geconfigureerd"
		sleep 1s
		cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local
		sed -i 's/#ignoreip = 127.0.0.1/ignoreip = 127.0.0.1/g' /etc/fail2ban/jail.local	
		sed -i 's/bantime  = 15m/bantime  = 120m/g' /etc/fail2ban/jail.local
		sed -i 's/findtime  = 15m/findtime  = 120m/g' /etc/fail2ban/jail.local
		sed -i 's/maxretry = 5/maxretry = 7/g' /etc/fail2ban/jail.local
		sed -i '247 i maxretry = 3' /etc/fail2ban/jail.local
		sed -i '248 i enable = true' /etc/fail2ban/jail.local
		systemctl restart fail2ban
		;;
	*) 	echo input onbekend
esac

echo "Hier volgt de configuratie voor de Firewall en HTTPS"
sleep 1s
#https config
iptables -A INPUT -p tcp -m multiport --dports 80,443 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT
iptables -A OUTPUT -p tcp -m multiport --dports 80,443 -m conntrack --ctstate ESTABLISHED -j ACCEPT

#firewall configuratie
iptables -P INPUT DROP
iptables -P OUTPUT DROP
iptables -P FORWARD DROP
echo "Configuratie klaar"
sleep 1s

#SSL certificaat
echo "Hier volgt de installatie van het SSL certificaat"
apt install openssl
mkdir /etc/apache2/ssl
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/apache2/ssl/sslkey.key -out /etc/apache2/ssl/sslkey.crt
a2ensite nextcloud.conf
a2enmod ssl
sed -i 's/80/443/g' /etc/apache2/sites-enabled/nextcloud.conf
sed -i '4 i SSLEngine on' /etc/apache2/sites-enabled/nextcloud.conf
sed -i '5 i SSLCertificateFile      /etc/apache2/ssl/sslkey.crt' /etc/apache2/sites-enabled/nextcloud.conf
sed -i '6 i SSLCertificateKeyFile   /etc/apache2/ssl/sslkey.key' /etc/apache2/sites-enabled/nextcloud.conf
a2ensite default-ssl
a2dissite default-ssl.conf
systemctl reload apache2.service
echo "Het script is nu klaar."
sleep 1s
echo "Wil je het script opnieuw starten?"; read restart
done
