#!/bin/bash

useradd -M -r -s /bin/false prometheus
mkdir /etc/prometheus /var/lib/prometheus

wget https://github.com/prometheus/prometheus/releases/download/v2.14.0/prometheus-2.14.0.linux-amd64.tar.gz
tar xzf prometheus-2.14.0.linux-amd64.tar.gz
cp prometheus-2.14.0.linux-amd64/{prometheus,promtool} /usr/local/bin/
chown prometheus:prometheus /usr/local/bin/{prometheus,promtool}
cp -r prometheus-2.14.0.linux-amd64/{consoles,console_libraries} /etc/prometheus/


echo "
global:
  scrape_interval: 1s
  evaluation_interval: 1s

scrape_configs:
  - job_name: 'node'
    ec2_sd_configs:
      - region: '${region}'       
        profile: ${role}
        port: 9100
    relabel_configs:
        # Only monitor instances with a Name starting with '${project}'
      - source_labels: [__meta_ec2_tag_Name]
        regex: ${project}.*
        action: keep
        # Use the instance ID as the instance label
      - source_labels: [__meta_ec2_tag_Name,__meta_ec2_availability_zone]
        target_label: instance" > /etc/prometheus/prometheus.yml

chown -R prometheus:prometheus /etc/prometheus
chown prometheus:prometheus /var/lib/prometheus

# Add prometheus as systemd service
tee -a /etc/systemd/system/prometheus.service << END
[Unit]
Description=Prometheus Time Series Collection and Processing Server
Wants=network-online.target
After=network-online.target

[Service]
User=prometheus
Group=prometheus
Type=simple
ExecStart=/usr/local/bin/prometheus \
    --config.file /etc/prometheus/prometheus.yml \
    --storage.tsdb.path /var/lib/prometheus/ \
    --web.console.templates=/etc/prometheus/consoles \
    --web.console.libraries=/etc/prometheus/console_libraries

[Install]
WantedBy=multi-user.target
END

systemctl daemon-reload
systemctl start prometheus
systemctl enable 

apt-get -qq -y install wget

apt-get install -qq -y libfontconfig1
apt-get install -f

wget https://dl.grafana.com/oss/release/grafana_6.4.4_amd64.deb
sudo dpkg -i grafana_6.4.4_amd64.deb

systemctl daemon-reload

systemctl enable grafana-server.service
systemctl start grafana-server.service

sleep 5


 curl 'http://localhost:3000/api/datasources' \
    -s \
    -X POST \
    -H 'Content-Type: application/json;charset=UTF-8' \
    --basic --user admin:admin \
    --data-binary "{\"name\":\"Prometheus\",\"type\":\"prometheus\",\"url\":\"http://localhost:9090\",\"access\":\"proxy\",\"isDefault\":true}"
