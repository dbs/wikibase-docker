#!/bin/sh
# This file is provided by the wikibase/wikibase docker image.

# Test if required environment variables have been set
REQUIRED_VARIABLES=(MW_ADMIN_NAME MW_ADMIN_PASS DB_SERVER DB_USER DB_PASS DB_NAME)
for i in ${REQUIRED_VARIABLES[@]}; do
    eval THISSHOULDBESET=\$$i
    if [ -z "$THISSHOULDBESET" ]; then
    echo "$i is required but isn't set. You should pass it to docker. See: https://docs.docker.com/engine/reference/commandline/run/#set-environment-variables--e---env---env-file";
    exit 1;
    fi
done

set -eu

# Wait for the db to come up
/wait-for-it.sh $DB_SERVER -t 120
# Sometimes it appears to come up and then go back down meaning MW install fails
# So wait for a second and double check!
sleep 1
/wait-for-it.sh $DB_SERVER -t 120

# Do the mediawiki install (only if LocalSettings doesn't already exist)
if [ ! -e "/var/www/html/LocalSettings.php" ]; then
    php /var/www/html/maintenance/install.php --dbuser $DB_USER --dbpass $DB_PASS --dbname $DB_NAME --dbserver $DB_SERVER --lang $MW_SITE_LANG --pass $MW_ADMIN_PASS $MW_SITE_NAME $MW_ADMIN_NAME

    # Copy our LocalSettings into place after install from the template
    # https://stackoverflow.com/a/24964089/4746236
    export DOLLAR='$'
    envsubst < /LocalSettings.php.template > /var/www/html/LocalSettings.php

    # Run update.php to install Wikibase
    php /var/www/html/maintenance/update.php --quick
fi

# Run the actual entry point
docker-php-entrypoint apache2-foreground
