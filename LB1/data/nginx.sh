apt-get update -y
apt-get install nginx -y
service nginx start

rm /etc/nginx/sites-enabled/default
echo "server {
       listen 80;
       
       server_name localhost;

       location / {
              root /vagrant_data/;
              index index.html;
       }
}" > /etc/nginx/sites-enabled/default
