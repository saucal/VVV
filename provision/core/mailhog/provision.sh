#!/bin/bash
function mailhog_setup() {
  if [[ -f "/etc/init/mailcatcher.conf" ]]; then
    echo " * Cleaning up old mailcatcher.conf"
    rm -f /etc/init/mailcatcher.conf
  fi

  if [[ ! -e /usr/local/bin/mailhog ]]; then
    echo " * Installing MailHog"
    curl --silent -L -o /usr/local/bin/mailhog https://github.com/mailhog/MailHog/releases/download/v1.0.0/MailHog_linux_amd64
    chmod +x /usr/local/bin/mailhog
  fi
  if [[ ! -e /usr/local/bin/mhsendmail ]]; then
    echo " * Installing MHSendmail"
    curl --silent -L -o /usr/local/bin/mhsendmail https://github.com/mailhog/mhsendmail/releases/download/v0.2.0/mhsendmail_linux_amd64
    chmod +x /usr/local/bin/mhsendmail
  fi

  if [[ ! -e /etc/systemd/system/mailhog.service ]]; then
    echo " * Mailhog service file missing, setting up"
    # Make it start on reboot
    cp -f "/srv/provision/core/mailhog/mailhog.service" "/etc/systemd/system/mailhog.service"
  fi

  # Start on reboot
  echo " * Enabling MailHog Service"
  systemctl enable mailhog

  echo " * Starting MailHog Service"
  systemctl start mailhog
}
export -f mailhog_setup

vvv_add_hook after_packages mailhog_setup

vvv_add_hook services_restart "service mailhog restart"

function mailhog_php_finalize() {
  # Enable PHP MailHog sendmail settings by default
  echo " * Enabling MailHog for PHP"
  phpenmod -s ALL mailhog
}

vvv_add_hook php_finalize mailhog_php_finalize
