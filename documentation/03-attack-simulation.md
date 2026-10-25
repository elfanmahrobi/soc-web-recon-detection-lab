# Authorized Attack Simulation

> [!WARNING]
> Use these commands only against the isolated lab server at `192.168.56.123` or another explicitly authorized target.

## Baseline request

```bash
curl -I http://192.168.56.123/
```

## Controlled path enumeration

```bash
for path in admin login backup test .env .git/config phpmyadmin robots.txt; do
  curl -s -o /dev/null -w "%{http_code} %{url_effective}\n" "http://192.168.56.123/$path"
done
```

## Optional lab tools

```bash
nmap -sT -sV -p 80 192.168.56.123
gobuster dir -u http://192.168.56.123/ -w /usr/share/wordlists/dirb/common.txt -t 5
```

The thread count is intentionally limited to reduce unnecessary load. Capture the test start and end times for easier correlation in Kibana.

## Expected evidence

- Multiple requests from `192.168.56.122`
- Repeated `404` responses
- Requests to high-interest paths
- Automated or uncommon user agents
- A short burst of requests within the test window
