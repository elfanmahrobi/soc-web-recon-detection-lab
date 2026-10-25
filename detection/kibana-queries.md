# Kibana Query Library

> Field names may vary by Elastic and Filebeat version. Validate them in Kibana Discover.

## Traffic from the Kali host

```text
source.ip : "192.168.56.122"
```

## Apache activity against the monitored server

```text
event.dataset : "apache.access" and host.ip : "192.168.56.123"
```

## Repeated not-found responses

```text
event.dataset : "apache.access" and http.response.status_code : 404
```

## Sensitive-path requests

```text
url.path : ("/admin" or "/login" or "/backup" or "/.env" or "/.git/config" or "/phpmyadmin")
```

## Possible automated tools

```text
user_agent.original : (*gobuster* or *nikto* or *nmap* or *sqlmap* or *dirbuster*)
```

## Combined high-signal query

```text
source.ip : "192.168.56.122" and event.dataset : "apache.access" and
(http.response.status_code : 404 or url.path : ("/admin" or "/.env" or "/.git/config" or "/backup" or "/phpmyadmin"))
```

## Dashboard fields

- `@timestamp`
- `source.ip`
- `host.ip`
- `http.request.method`
- `url.path`
- `http.response.status_code`
- `user_agent.original`
- `event.dataset`
