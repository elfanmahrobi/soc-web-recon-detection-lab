# Apache and Filebeat Onboarding

## 1. Install Apache

```bash
sudo apt update
sudo apt install apache2 -y
sudo systemctl enable --now apache2
sudo systemctl is-active apache2
```

## 2. Confirm the log source

```bash
sudo ls -l /var/log/apache2/
curl http://127.0.0.1/
sudo tail -n 10 /var/log/apache2/access.log
```

## 3. Configure Filebeat

Back up the current configuration and adapt the repository example:

```bash
sudo cp /etc/filebeat/filebeat.yml /etc/filebeat/filebeat.yml.bak
sudo nano /etc/filebeat/filebeat.yml
```

Enable the Apache module when it is available:

```bash
sudo filebeat modules enable apache
sudo filebeat test config -e
sudo filebeat test output -e
sudo systemctl restart filebeat
sudo systemctl is-active filebeat
```

## 4. Validate ingestion

Generate a test request:

```bash
curl http://192.168.56.123/lab-validation
```

Search in Kibana Discover:

```text
event.dataset : "apache.access" and host.ip : "192.168.56.123"
```

Field names can differ by Filebeat and Elastic version. Confirm actual fields in Discover before creating a production rule.
