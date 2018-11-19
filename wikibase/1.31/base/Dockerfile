FROM ubuntu:xenial as fetcher

RUN apt-get update && \
    apt-get install --yes --no-install-recommends unzip=6.* git ca-certificates

RUN git clone https://github.com/wikimedia/mediawiki-extensions-Wikibase.git && cd mediawiki-extensions-Wikibase && git checkout origin/REL1_31 && git submodule update --init

FROM composer as composer

COPY --from=fetcher /mediawiki-extensions-Wikibase /Wikibase

WORKDIR /Wikibase
RUN composer install --no-dev


FROM mediawiki:1.31

# Install envsubst
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install --yes --no-install-recommends gettext-base=0.19.* && \
    rm -rf /var/lib/apt/lists/*

RUN a2enmod rewrite

RUN install -d /var/log/mediawiki -o www-data

COPY wait-for-it.sh /wait-for-it.sh
COPY entrypoint.sh /entrypoint.sh
COPY LocalSettings.php.template /LocalSettings.php.template
COPY htaccess /var/www/html/.htaccess

RUN ln -s /var/www/html/ /var/www/html/w

ENV MW_SITE_NAME=wikibase-docker\
    MW_SITE_LANG=en

ENTRYPOINT ["/bin/bash"]
CMD ["/entrypoint.sh"]
