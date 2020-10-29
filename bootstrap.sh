
sudo dd if=/dev/zero of=/swapfile bs=128M count=32
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile



sudo amazon-linux-extras install docker -y
sudo systemctl start docker 
sudo systemctl enable docker 

sudo docker run -d -p 5001:80 hasheminejad/aws-game:server3
sudo docker run -d -p 5002:80 hasheminejad/aws-game:server3
sudo docker run -d -p 5003:80 hasheminejad/aws-game:server3


sudo amazon-linux-extras install nginx1.12 -y

cat <<'EOF' > /etc/nginx/nginx.conf

user nginx;
worker_processes auto;
error_log /var/log/nginx/error.log;
pid /run/nginx.pid;

# Load dynamic modules. See /usr/share/nginx/README.dynamic.
include /usr/share/nginx/modules/*.conf;

events {
    worker_connections 1024;
}

http {
    log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
                      '$status $body_bytes_sent "$http_referer" '
                      '"$http_user_agent" "$http_x_forwarded_for"';

    access_log  /var/log/nginx/access.log  main;

    sendfile            on;
    tcp_nopush          on;
    tcp_nodelay         on;
    keepalive_timeout   65;
    types_hash_max_size 2048;

    include             /etc/nginx/mime.types;
    default_type        application/octet-stream;

    # Load modular configuration files from the /etc/nginx/conf.d directory.
    # See http://nginx.org/en/docs/ngx_core_module.html#include
    # for more information.
    include /etc/nginx/conf.d/*.conf;

    server {
        listen       80 default_server;
        #listen       [::]:80 default_server;
        server_name  _;
        root         /usr/share/nginx/html;

        # Load configuration files for the default server block.
        include /etc/nginx/default.d/*.conf;

        location / {
            proxy_pass  http://backend;
        }

        error_page 404 /404.html;
            location = /40x.html {
        }

        error_page 500 502 503 504 /50x.html;
            location = /50x.html {
        }
    }

    upstream backend  {
        server 127.0.0.1:5001;
        server 127.0.0.1:5002;
        server 127.0.0.1:5003;
    }
}
EOF
