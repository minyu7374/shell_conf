#!/bin/bash

minyu-web2www() {
    local domain=wminyu.top
    for url in "$@"; do
        echo "$url" | sed -E "s|(https?)://([^.]+).$domain(:443\|:433\|:80\|:81)?(/?.*)|\1://www.$domain/\2\4|g"
    done
}

[[ "$_HOST_NAME" =~ GMK ]] || return # only for GMK

nc_php_ver=8.3
nc_php="php$nc_php_ver"
nc_php_ini="/etc/php/fpm-php-nextcloud$nc_php_ver/php.ini"
nc_www_dir=/var/www/cloud.wminyu.top/htdocs

cloud-upgrade() {
    local nc_ver
    nc_ver="$(equery l -F "\$fullversion" nextcloud)"
    sudo webapp-config -U nextcloud "$nc_ver" -h cloud.wminyu.top -d /
    sudo chown -R nginx:nginx "$nc_www_dir"
    cd "$nc_www_dir" && sudo -u nginx "$nc_php" -c "$nc_php_ini" occ upgrade
}

cloud-occ() {
    cd "$nc_www_dir" && sudo -u nginx "$nc_php" -c "$nc_php_ini" occ "$@"
}

alias nginx-do='sudo -u nginx'
alias cloud-scan='cloud-occ files:scan --all'
alias cloud-repair='cloud-occ maintenance:repair'
# alias cloud-htaccess='cloud-occ maintenance:update:htaccess'
