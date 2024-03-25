#set env vars
set -o allexport; source .env; set +o allexport;

mkdir -p ./volumes/public
mkdir -p ./volumes/private
mkdir -p ./volumes/config
chown -R 1000:1000 ./volumes/public
chown -R 1000:1000 ./volumes/private
chown -R 1000:1000 ./volumes/config
chmod -R 777 ./volumes