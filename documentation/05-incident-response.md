# Incident Response Workflow

## Identification

- Record alert time and detection rule
- Identify source and destination
- Preserve relevant Apache and SIEM evidence
- Determine whether the activity was authorized

## Containment

For a verified unauthorized source in this isolated lab:

```bash
sudo ufw deny from 192.168.56.122 to any port 80 proto tcp
sudo ufw status numbered
```

Do not apply blocking rules in production without approval and impact assessment.

## Verification

From Kali Linux:

```bash
curl --connect-timeout 5 http://192.168.56.123/
```

On Ubuntu Web Server:

```bash
sudo ufw status verbose
sudo tail -n 20 /var/log/apache2/access.log
```

## Recovery

Remove the temporary lab rule after validation:

```bash
sudo ufw status numbered
sudo ufw delete <rule-number>
```

## Lessons Learned

- Tune thresholds using normal traffic baselines
- Maintain an allowlist for approved scanners
- Alert on combinations of volume, unique paths, status codes, and user agents
- Document every containment action and rollback step
