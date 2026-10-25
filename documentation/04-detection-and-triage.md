# Detection and SOC Triage

## Detection Hypothesis

If one source requests many unique or sensitive web paths and receives repeated `404` responses in a short period, the source may be performing web reconnaissance or content discovery.

## Initial Triage Questions

1. Which source IP generated the requests?
2. How many requests occurred and over what period?
3. How many unique URLs were requested?
4. Which response codes were returned?
5. Were sensitive paths targeted?
6. Was the user agent associated with automation?
7. Did any request return `200`, `301`, `302`, `401`, or `403`?
8. Is the source expected, authorized, or part of a known scanner?

## Suggested Severity

- **Low**: authorized test activity with no successful access
- **Medium**: unapproved scanning, repeated sensitive-path requests, or successful discovery
- **High**: reconnaissance followed by exploitation indicators or unauthorized access

## False Positives

- Vulnerability-management scanners
- Search-engine crawlers
- Availability monitoring systems
- Application health checks
- Developers testing routes
- Misconfigured integrations

## Validation

Correlate Apache logs with system logs, firewall logs, change records, vulnerability-scanning schedules, and owner confirmation before escalation.
