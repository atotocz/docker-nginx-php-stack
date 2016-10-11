#!/usr/bin/env bash


# run startup commands

if [ -f /var/www/html/docker-run.sh ]; then
	echo "===> detected docker-run.conf in project root:"
	cat /var/www/html/docker-run.sh
	echo -e "\n===> executing docker-run.sh..."
    bash /var/www/html/docker-run.sh
    if [ $? -ne 0 ]; then
    	echo "===> docker-run.sh failed!"
    	exit 1
	fi
	echo ""
fi


# update supervisor configuration

if [ -f /var/www/html/supervisord.conf ]; then
	echo "===> detected supervisord.conf in project root"
	echo -e "\n" >> /etc/supervisor/supervisord.conf
    cat /var/www/html/supervisord.conf >> /etc/supervisor/supervisord.conf
fi


# setup cron

if [ -f /var/www/html/crontab ]; then
	echo "===> detected crontab in project root"
	crontab /var/www/html/crontab
	crontab -l
fi

echo -e "===> generated supervisord configuration:\n"
cat /etc/supervisor/supervisord.conf
echo -e "\n\n===> starting supervisord..."


# start supervisord!

/usr/bin/supervisord -c /etc/supervisor/supervisord.conf
