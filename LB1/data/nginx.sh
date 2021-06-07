apt-get update -y
apt-get install nginx -y
service nginx start

rm /etc/nginx/sites-enabled/default
echo "server {
       listen 80;
       listen [::]:80;

       root /vagrant_data/;
       index index.html;

       location / {
               try_files $uri $uri/ =404;
       }
}" > /etc/nginx/sites-enabled/default