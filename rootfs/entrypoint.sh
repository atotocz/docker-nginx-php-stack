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

if [ "$GIT_BRANCH" == 'develop' ] || [ "$GIT_BRANCH" == 'master' ]; then
	if [ -f /var/www/html/crontab ]; then
		echo "===> detected crontab in project root"
		crontab /var/www/html/crontab
		crontab -l
		echo "" >> /etc/supervisor/supervisord.conf
		echo "[program:cron]" >> /etc/supervisor/supervisord.conf
		echo "command=cron -f -L 15" >> /etc/supervisor/supervisord.conf
		echo "autostart=true" >> /etc/supervisor/supervisord.conf
		echo "autorestart=true" >> /etc/supervisor/supervisord.conf
	fi
fi

echo -e "===> generated supervisord configuration:\n"
cat /etc/supervisor/supervisord.conf
echo -e "\n\n===> starting supervisord..."


# start supervisord!

/usr/bin/supervisord -c /etc/supervisor/supervisord.conf
