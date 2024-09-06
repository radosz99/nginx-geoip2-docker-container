# About

Repository for custom nginx build with GeoIP2 module for retrieving geolocation data from IP and handling it under nginx.

# Setup

Before you have to make sure that you have `docker` and `docker compose` installed in your environment.

## Launch

1. Sign up for the Geolite2 access - https://www.maxmind.com/en/geolite2/signup
2. Generate a new free license key (in `Manage License Keys`)
3. Update the `docker.env` file with your `GEOIP_ACCOUNT_ID` and `GEOIP_LICENSE_KEY`
4. Run one of these commands:  

If you do not want to open your ports:
```angular2html
$ docker compose -f docker-compose.yaml --env-file docker.env up --build -d
```
If you wish to open your ports:
```angular2html
$ docker compose --env-file docker.env up --build -d
```

5. Test it:
```angular2html
$ docker exec -it nginx-geoip2 bash
root@1234:/usr# curl -H "X-Forwarded-For: 8.8.8.8" http://localhost/geoip
```
Output should look like this:
```angular2html
IP: 8.8.8.8
Country: United States
City: 
Latitude: 37.75100
Longitude: -97.82200
```
You can test on your local IP, just modify the curl command. 

## Modify
Please modify the `nginx.conf` according to your needs. Simple configuration with taking advantage of GeoIP2 data is in the following configuration:

```angular2html
load_module modules/ngx_http_geoip2_module.so;

events {
    worker_connections 1024;
}

http {
    server_tokens off;

    include /etc/nginx/mime.types;
    default_type application/octet-stream;

    geoip2 /usr/share/GeoIP/GeoLite2-Country.mmdb {
        auto_reload 5m;
        $geoip2_data_country_code country iso_code;
        $geoip2_data_country_name country names en;
    }

    geoip2 /usr/share/GeoIP/GeoLite2-City.mmdb {
        auto_reload 5m;
        $geoip2_data_city_name city names en;
        $geoip2_data_latitude location latitude;
        $geoip2_data_longitude location longitude;
    }

    map $request $request_path {
        "~^(?P<path>[^?]*)(\?.*)?$"  $path;
    }

    log_format json_single_line escape=json '{ "time_local": "$time_local", "remote_addr": "$remote_addr", "remote_user": "$remote_user", "request": "$request", "request_path": "$request_path", "query_string": "$query_string", "status": "$status", "body_bytes_sent": "$body_bytes_sent", "request_time": "$request_time", "http_referer": "$http_referer", "http_user_agent": "$http_user_agent", "request_method": "$request_method", "http_host": "$host", "uri": "$uri", "server_protocol": "$server_protocol", "connection": "$connection", "bytes_sent": "$bytes_sent", "request_length": "$request_length", "ssl_protocol": "$ssl_protocol", "ssl_cipher": "$ssl_cipher", "scheme": "$scheme", "upstream_addr": "$upstream_addr", "upstream_response_time": "$upstream_response_time", "upstream_status": "$upstream_status", "gzip_ratio": "$gzip_ratio", "geoip2_country_code": "$geoip2_data_country_code", "geoip2_country_name": "$geoip2_data_country_name", "geoip2_city_name": "$geoip2_data_city_name", "geoip2_latitude": "$geoip2_data_latitude", "geoip2_longitude": "$geoip2_data_longitude" }';

    access_log /var/log/nginx/access.log json_single_line;
}
```