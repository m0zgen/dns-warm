#!/bin/bash
# Author: Yevgeniy Goncharov aka xck, http://sys-adm.in
# Warm.txt domain checker

# Sys env / paths / etc
# -------------------------------------------------------------------------------------------\
PATH=$PATH:/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin
SCRIPT_PATH=$(cd `dirname "${BASH_SOURCE[0]}"` && pwd); cd $SCRIPT_PATH

# -------------------------------------------------------------------------------------------\
DOMAIN_LIST="warm.txt"
NXDOMAIN_LIST="nxdomains.log"

echo "Checking domains for NXDOMAIN..."
echo "------------------------------"

# Check passed arguments for domain list file
if [ $# -gt 0 ]; then
    DOMAIN_LIST="$1"
fi

if [ ! -f "$DOMAIN_LIST" ]; then
    echo "Error: File '$DOMAIN_LIST' not found."
    exit 1
fi

# Clear the NXDOMAIN list file if it exists
if [ -f "$NXDOMAIN_LIST" ]; then
    > "$NXDOMAIN_LIST"
fi

while IFS= read -r domain; do
    # Skip empty lines
    if [ -z "$domain" ]; then
        continue
    fi

    # If line contains # or is a comment, skip it
    if [[ "$domain" =~ ^# ]]; then
        continue
    fi

    # Use 'host' to check the domain
    # '-t A' requests the A record
    # 2>/dev/null redirects stderr to /dev/null to avoid outputting errors if the domain does not exist
    if host -t A "$domain" >/dev/null 2>&1; then
        echo "$domain: ✅ AVAILABLE"
    else
        echo "$domain: ❌ NXDOMAIN (or another DNS error). Trying dig..."

        DIG_OUTPUT=$(dig +noall +answer +rcdcode "$domain" A 2>/dev/null)

        # Check the RCODE return code from dig
        if echo "$DIG_OUTPUT" | grep -q "status: NXDOMAIN"; then
            echo "$domain: ❌ NXDOMAIN (via dig)"
        elif [ -z "$DIG_OUTPUT" ]; then
            echo "$domain: ❌ Unavailable / DNS error (dig returned no data)"
        else
            echo "DNS error ❌ / Unreachable (via dig, status: $(echo "$DIG_OUTPUT" | grep "status:" | awk '{print $NF}'))"
        fi

        # Export name to nxdomain list
        echo "$domain" >> "$NXDOMAIN_LIST"
        
    fi
done < "$DOMAIN_LIST"

echo "------------------------------"
echo "Checking completed."