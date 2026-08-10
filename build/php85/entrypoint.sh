#!/usr/bin/env bash
set -euo pipefail

if [[ "${ENABLE_XDEBUG:-0}" == "1" ]]; then
    ln -sf /etc/php/8.5/mods-available/xdebug.ini /etc/php/8.5/cli/conf.d/20-xdebug.ini
    ln -sf /etc/php/8.5/mods-available/xdebug.ini /etc/php/8.5/fpm/conf.d/20-xdebug.ini
else
    rm -f /etc/php/8.5/cli/conf.d/20-xdebug.ini /etc/php/8.5/fpm/conf.d/20-xdebug.ini
fi

exec "$@"
