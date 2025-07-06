# Nginx Monitoring

![Preview](img/Screenshot.png)


### Source

- [VoidQuark Grafana Dashboards](https://github.com/voidquark/grafana-dashboards)
- [Grafana Dashboard: PrivateBin Access Log](https://grafana.com/grafana/dashboards/19507-privatebin-access-log/)
- Dashboard ID: 19507

NGINX erişim loglarını JSON formatında Fluentd üzerinden Loki'ye gönderip, Grafana ile görselleştirmeyi sağlayan izleme altyapısı.

- fluent.conf
```bash
<source>
  @type tail
  path /var/log/nginx/access.log
  pos_file /fluentd/log/nginx-access.pos
  tag nginx.access
  <parse>
    @type json
  </parse>
</source>

<match nginx.access>
  @type loki
  endpoint_url "http://loki:3100"
  labels {"job":"nginx"}
  <buffer>
    flush_interval 5s
  </buffer>
</match>

```

- nginx.conf
```bash
log_format json_combined escape=json
  '{'
    '"time_local":"$time_local",'
    '"remote_addr":"$remote_addr",'
    '"status":"$status",'
    '"msec":"$msec",'
    '"bytes_sent":"$bytes_sent",'
    '"body_bytes_sent":"$body_bytes_sent",'
    '"request":"$request",'
    '"request_time":"$request_time",'
    '"request_method":"$request_method",'
    '"request_uri":"$request_uri",'
    '"request_length":"$request_length",'
    '"host":"$http_host",'
    '"referer":"$http_referer",'
    '"user_agent":"$http_user_agent",'
    '"x_forwarded_for":"$http_x_forwarded_for",'
    '"x_forwarded_proto":"$x_forwarded_proto",'
    '"connection":"$connection",'
    '"accept_encoding":"$http_accept_encoding",'
    '"accept_language":"$http_accept_language",'
    '"accept":"$http_accept",'
    '"cf_ray":"$http_cf_ray",'
    '"cf_connecting_ip":"$http_cf_connecting_ip",'
    '"cf_ipcountry":"$http_cf_ipcountry",'
    '"sec_fetch_site":"$http_sec_fetch_site",'
    '"sec_fetch_mode":"$http_sec_fetch_mode",'
    '"sec_fetch_dest":"$http_sec_fetch_dest"'
  '}';

access_log /var/log/nginx/access.log json_combined;
error_log /var/log/nginx/error.log;

```

- Loki Quary
```bash
{job="nginx"} | json 
| remote_addr!~"^172\\.20\\..*" 
and remote_addr != "" 
and request_uri!~"^/api/.*" 
and request_uri!~"(?i)(\\.env|\\.env\\.local|\\.env\\.production|/old\\.env|/scripts$|/scripts/.*|/error/\\.env|/wp-content/uploads/.*|/public/img/icons/.*|/public/app/plugins/.*|/config/.*|/getcfg\\.php|\\?phpinfo.*|/app_dev\\.php.*|/public/fonts/.*|/public/build/.*|/wp-includes/.*|/wp-admin/images/.*|/wp-admin/js/.*|/wp-admin/css/.*)" 
| line_format "🌍 {{.remote_addr}} 🗂 {{.request_method}} 📄 {{.request_uri}} 💻 {{.user_agent}}"
```
