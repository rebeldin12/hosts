cat << 'EOF' > check_hosts.sh
#!/bin/bash

HOSTS_FILE="/etc/hosts"

while read -r ip host rest; do
    # Ignoră liniile goale sau comentariile
    [[ -z "$ip" || "$ip" == \#* ]] && continue

    # Verifică validitatea formatului IPv4 (4 octeți între 0 și 255)
    if [[ "$ip" =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ ]]; then
        valid=1
        IFS='.' read -ra octeti <<< "$ip"
        for oct in "${octeti[@]}"; do
            if (( oct < 0 || oct > 255 )); then
                valid=0
                break
            fi
        done

        if [ "$valid" -eq 1 ]; then
            echo "[VALID] $host -> $ip"
        else
            echo "[INVALID] Octeti in afara intervalului 0-255 pentru $host: $ip"
        fi
    else
        echo "[INVALID] Format IP gresit pentru $host: $ip"
    fi
done < "$HOSTS_FILE"
EOF
chmod +x check_hosts.sh
