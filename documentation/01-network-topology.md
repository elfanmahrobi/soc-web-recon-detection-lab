# Network Topology

## Overview

The lab runs on Oracle VirtualBox using the isolated Host-Only network `192.168.56.0/24`.

| Host | IP address | Role |
|---|---:|---|
| Ubuntu ELK Server | `192.168.56.121` | Log processing, indexing, visualization, and investigation |
| Kali Linux | `192.168.56.122` | Authorized reconnaissance simulation |
| Ubuntu Web Server | `192.168.56.123` | Apache web service and monitored endpoint |

## Required Flows

- Kali Linux to Ubuntu Web Server: TCP/80 for controlled HTTP testing
- Ubuntu Web Server to ELK Server: TCP/5044 for Filebeat to Logstash
- Analyst workstation to Kibana: TCP/5601 when permitted by the lab design
- ELK internal communication: Elasticsearch and Kibana service ports as locally configured

## Validation

```bash
# From Kali Linux
ping -c 3 192.168.56.123
curl -I http://192.168.56.123/

# From Ubuntu Web Server
ping -c 3 192.168.56.121
nc -vz 192.168.56.121 5044
```

Keep the lab isolated and do not bridge the attack-simulation interface to an untrusted network.
