# SOC Web Reconnaissance Detection Lab

![Status](https://img.shields.io/badge/status-in%20progress-yellow)
![Platform](https://img.shields.io/badge/platform-VirtualBox-blue)
![SIEM](https://img.shields.io/badge/SIEM-Elastic%20Stack-005571)
![Focus](https://img.shields.io/badge/focus-Web%20Reconnaissance%20Detection-red)

## Overview

This project demonstrates an end-to-end SOC workflow for detecting and investigating web reconnaissance activity in an isolated home lab. A Kali Linux machine generates controlled reconnaissance traffic against an Apache web service hosted on Ubuntu Server. Filebeat forwards Apache access logs to the Elastic Stack, where the activity is searched, visualized, triaged, and documented.

The lab focuses on identifying patterns commonly associated with early-stage reconnaissance, including rapid requests, repeated `404` responses, sensitive-path enumeration, unusual user agents, and requests originating from a single source within a short time window.

> [!IMPORTANT]
> All testing in this repository is intended only for systems owned by the lab operator or environments where explicit authorization has been granted.

## Objectives

- Build a safe and isolated web reconnaissance detection environment
- Collect Apache access logs using Filebeat
- Forward and analyze logs in Elasticsearch and Kibana
- Simulate controlled web discovery activity from Kali Linux
- Develop practical detection logic for suspicious HTTP behavior
- Perform SOC Level 1 triage and incident investigation
- Document evidence, findings, containment, and recovery activities
- Map the detection use case to the MITRE ATT&CK framework

## Lab Architecture

```text
                         VirtualBox Host-Only Network
                              192.168.56.0/24

+---------------------------+      HTTP requests      +---------------------------+
| Kali Linux               | ----------------------> | Ubuntu Web Server         |
| Authorized test machine  |                         | Monitored endpoint         |
| 192.168.56.122           |                         | 192.168.56.123             |
|                           |                         |                           |
| - curl                    |                         | - Apache2                 |
| - Nmap                    |                         | - Filebeat                |
| - Gobuster                |                         | - access.log / error.log  |
+---------------------------+                         +-------------+-------------+
                                                                  |
                                                                  | Beats / TCP 5044
                                                                  v
                                                    +---------------------------+
                                                    | Ubuntu ELK Server         |
                                                    | 192.168.56.121            |
                                                    |                           |
                                                    | - Logstash                |
                                                    | - Elasticsearch           |
                                                    | - Kibana                  |
                                                    +---------------------------+
```

For full details, see [Network Topology](documentation/01-network-topology.md).

## Environment

| System | Role | IP address | Main components |
|---|---|---:|---|
| Ubuntu ELK Server | Centralized SIEM | `192.168.56.121` | Elasticsearch, Logstash, Kibana |
| Kali Linux | Authorized attack simulator | `192.168.56.122` | curl, Nmap, Gobuster |
| Ubuntu Server | Monitored web server | `192.168.56.123` | Apache2, Filebeat, UFW |

## Repository Structure

```text
soc-web-recon-detection-lab/
├── README.md
├── LICENSE
├── detection/
│   ├── kibana-queries.md
│   └── web-recon-detector.sh
├── documentation/
│   ├── 01-network-topology.md
│   ├── 02-apache-filebeat-onboarding.md
│   ├── 03-attack-simulation.md
│   ├── 04-detection-and-triage.md
│   ├── 05-incident-response.md
│   └── 06-mitre-attack-mapping.md
├── filebeat/
│   └── filebeat.yml.example
├── logstash/
│   └── apache-filebeat.conf.example
├── reports/
│   └── incident-report-template.md
├── samples/
│   └── sanitized-apache-access.log
└── screenshots/
    └── README.md
```

## Detection Scenario

The detection scenario assumes that the Kali Linux host generates multiple HTTP requests against the Ubuntu web server. The activity may include:

- Web service discovery
- Requests to common administrative or sensitive paths
- Directory and file enumeration
- Repeated `404 Not Found` responses
- High request volume from one source IP
- Automated-tool user-agent strings

### Primary Detection Logic

An event should be investigated when one or more of the following conditions are observed:

1. A single source generates a high number of requests within a short time window.
2. A source generates repeated `404` responses while requesting many unique paths.
3. Requests target sensitive locations such as `/admin`, `/.env`, `/.git`, `/backup`, or `/phpmyadmin`.
4. The user-agent indicates an automated reconnaissance tool.
5. Multiple indicators occur together from the same source.

The threshold values are intentionally adjustable because normal traffic patterns vary between environments.

## Quick Start

### 1. Install Apache and Filebeat on the monitored server

```bash
sudo apt update
sudo apt install apache2 -y
sudo systemctl enable --now apache2
```

Use the example configuration in [`filebeat/filebeat.yml.example`](filebeat/filebeat.yml.example), then validate:

```bash
sudo filebeat test config -e
sudo filebeat test output -e
sudo systemctl enable --now filebeat
```

### 2. Confirm log ingestion

On Ubuntu Web Server:

```bash
curl http://127.0.0.1/
sudo tail -f /var/log/apache2/access.log
```

In Kibana Discover, search:

```text
host.ip : "192.168.56.123" and event.dataset : "apache.access"
```

### 3. Generate authorized test traffic

From Kali Linux:

```bash
curl -I http://192.168.56.123/
for path in admin login backup test .env .git/config phpmyadmin; do
  curl -s -o /dev/null -w "%{http_code} %{url_effective}\n" "http://192.168.56.123/$path"
done
```

Optional tools may be used only within this controlled lab. See [Attack Simulation](documentation/03-attack-simulation.md).

### 4. Investigate in Kibana

Use the queries in [`detection/kibana-queries.md`](detection/kibana-queries.md) to identify suspicious sources, targeted paths, response codes, and user agents.

### 5. Validate with the local detector

```bash
chmod +x detection/web-recon-detector.sh
sudo ./detection/web-recon-detector.sh /var/log/apache2/access.log
```

## SOC Investigation Workflow

1. **Alert review**: validate the detection timestamp, source IP, destination, and rule criteria.
2. **Scope analysis**: determine request count, unique paths, response codes, and time range.
3. **Evidence review**: inspect Apache access logs and related system or firewall logs.
4. **Classification**: determine whether the activity is expected, benign automation, or suspicious reconnaissance.
5. **Containment**: block the source only when justified and approved.
6. **Verification**: confirm that the block is effective and legitimate access continues.
7. **Documentation**: record the timeline, evidence, decision, and lessons learned.

## Example Findings

```text
Source IP       : 192.168.56.122
Destination IP  : 192.168.56.123
Observed action : Multiple requests to non-existent and sensitive paths
Response pattern: High number of HTTP 404 responses
Assessment      : Authorized reconnaissance simulation
Severity        : Low in lab; potentially Medium in production
Disposition     : True positive, authorized test activity
```

## MITRE ATT&CK Mapping

This project primarily maps to:

- **TA0043 Reconnaissance**
- **T1595 Active Scanning**
- **T1595.002 Vulnerability Scanning** when scanning behavior is simulated

See [MITRE ATT&CK Mapping](documentation/06-mitre-attack-mapping.md) for context and limitations.

## Evidence Checklist

Add your own screenshots under `screenshots/` using the recommended names:

- `01-virtualbox-lab.png`
- `02-apache-service-and-port.png`
- `03-filebeat-output-test.png`
- `04-kibana-apache-events.png`
- `05-recon-traffic-generation.png`
- `06-kibana-detection-result.png`
- `07-containment-validation.png`

Do not upload passwords, API keys, session cookies, personal usernames, public IP addresses, or other sensitive information.

## Skills Demonstrated

- Elastic Stack log monitoring
- Apache access-log analysis
- Filebeat log onboarding
- Detection engineering fundamentals
- Kibana Query Language
- SOC alert triage and investigation
- Incident response documentation
- Linux administration and UFW containment
- MITRE ATT&CK mapping
- Technical security documentation

## Future Improvements

- Create an Elastic detection rule with a defined time window and threshold
- Build a Kibana dashboard for source IP, URI, response code, and user agent
- Add GeoIP enrichment for approved non-lab data sources
- Add alert notifications and case-management integration
- Compare reconnaissance activity with normal web traffic
- Introduce reverse-proxy or WAF logs for additional visibility

## Disclaimer

This repository is for education, defensive security research, and authorized laboratory testing only. Do not use the procedures against systems without explicit permission.

## Author

**Elfan Mahrobi**  
IT Security Engineer | SOC and SIEM Learner | Cybersecurity Home Lab Builder
