#set env vars
set -o allexport; source .env; set +o allexport;

#wait until the server is ready
echo "Waiting for software to be ready ..."
sleep 30s;

PWD=$(pwd)
echo $PWD
curl https://${DOMAIN}/index/install/install \
  -H 'accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7' \
  -H 'accept-language: fr-FR,fr;q=0.9,en-US;q=0.8,en;q=0.7,he;q=0.6,zh-CN;q=0.5,zh;q=0.4,ja;q=0.3' \
  -H 'cache-control: no-cache' \
  -H 'content-type: application/x-www-form-urlencoded' \
  -H 'pragma: no-cache' \
  -H 'upgrade-insecure-requests: 1' \
  -H 'user-agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36' \
  --data-raw 'installing=0&adminUsername=admin&adminPassword='${ADMIN_PASSWORD}'&adminPassword2='${ADMIN_PASSWORD}'&adminEmail='${ADMIN_EMAIL}'&locale=en&timeZone=UTC&filesDir=%2Fvar%2Fwww%2Ffiles&databaseDriver=mysqli&databaseHost=172.17.0.1%3A56151&databaseUsername='${MYSQL_USER}'&databasePassword='${MYSQL_PASSWORD}'&databaseName='${MYSQL_DATABASE}'&oaiRepositoryId='${DOMAIN}'&enableBeacon=1&submitFormButton='

sleep 10s;

docker-compose exec -T ojs sh -c "cp /var/www/html/config.inc.php /var/www/files/ojs.config.inc.php"
mv ./volumes/private/ojs.config.inc.php ./volumes/config/ojs.config.inc.php

docker-compose down;

sed -i "s~default = sendmail~default = smtp~g" ./volumes/config/ojs.config.inc.php
sed -i "s~sendmail_path = \"/usr/sbin/sendmail -bs\"~; sendmail_path = \"/usr/sbin/sendmail -bs\"~g" ./volumes/config/ojs.config.inc.php
sed -i "s~; smtp = On~smtp = On~g" ./volumes/config/ojs.config.inc.php
sed -i "s~; smtp_server = mail.example.com~smtp_server = 172.17.0.1~g" ./volumes/config/ojs.config.inc.php
sed -i "s~; smtp_port = 25~smtp_port = 25~g" ./volumes/config/ojs.config.inc.php
sed -i "s~; default_envelope_sender = my_address@my_host.com~default_envelope_sender = ${DEFAULT_SENDER}~g" ./volumes/config/ojs.config.inc.php
sed -i "s~; allow_envelope_sender = Off~allow_envelope_sender = On~g" ./volumes/config/ojs.config.inc.php
sed -i "s~; force_default_envelope_sender = Off~force_default_envelope_sender = On~g" ./volumes/config/ojs.config.inc.php
sed -i "s~api_key_secret = ""~api_key_secret = "${API_KEY_SECRET}"~g" ./volumes/config/ojs.config.inc.php

sed -i "s~# - ./volumes/config/ojs.config.inc.php:/var/www/html/config.inc.php~- ./volumes/config/ojs.config.inc.php:/var/www/html/config.inc.php~g" ./docker-compose.yml

docker-compose up -d;
sleep 20s;