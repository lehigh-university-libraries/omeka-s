ARG BASE_IMAGE=lehighlts/omeka-s:4.2.1-php84@sha256:d2f7cd531aaa0285b83ff82a454531ae031f2ff3ba7bffa471cd55aeabfd791d
FROM ${BASE_IMAGE}

WORKDIR /var/www/omeka-s

# nginx:nginx in the base image.
COPY --link --chown=100:101 modules/ /var/www/omeka-s/modules/
COPY --link --chown=100:101 themes/ /var/www/omeka-s/themes/
