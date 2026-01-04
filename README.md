# DNS Warm

Selective ~popular collection domains.

# Lists

- `warm.txt` - Static list which contains ~1000 popular domains
- `mixin.txt` - Automate generated list which contains ~1000 popular domains from different sources (excluding `warm.txt` items)

Filtrate nxdomains to warm:

```shell
grep -vFf nxdomains.log warm.txt > clean_warm.txt; mv clean_warm.txt warm.txt; echo "" > nxdomains.log
```

# Sources

- Cloudflare: https://radar.cloudflare.com/
- Cisco Umbrella: https://umbrella-static.s3-us-west-1.amazonaws.com/index.html
- Moz: https://moz.com/top500
- Tranco: https://tranco-list.eu/
