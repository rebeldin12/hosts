cat << 'EOF' > check_hosts.sh
#!/bin/bash

# Functie cu 3 parametri:
# $1 = nume host
# $2 = adresa IP
# $3 = server DNS
verifica_ip_dns() {
    local host="$1"
    local ip="$2"
    local dns_server="$3"

    # 1. Verifica validitatea formatului adresei IPv4
    if ! [[ "$ip" =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ ]]; then
        echo "[INVALID] Format IP incorect pentru $host: $ip"
        return 1
    fi

    IFS='.' read -ra octeti <<< "$ip"
    for oct in "${octeti[@]}"; do
        if (( oct < 0 || oct > 255 )); then
            echo "[INVALID] Adresa IP invalida pentru $host: $ip"
            return 1
        fi
    done

    # 2. Verifica asocierea host -> IP folosind serverul DNS furnizat ($3)
    local resolved_ip
    resolved_ip=$(nslookup "$host" "$dns_server" 2>/dev/null | awk '/^Address: / { print $2 }' | tail -n 1 | tr -d '\r')

    if [ "$ip" == "$resolved_ip" ]; then
        echo "[OK] $host -> $ip (confirmat de serverul DNS $dns_server)"
        return 0
    else
        echo "[NECONCORDANTA] $host: in fisier este $ip, dar DNS ($dns_server) returneaza '${resolved_ip:-nimic}'"
        return 2
    fi
}

HOSTS_FILE="/etc/hosts"
DNS_SERVER="${1:-8.8.8.8}"

while read -r ip host rest; do
    [[ -z "$ip" || "$ip" == \#* ]] && continue
    verifica_ip_dns "$host" "$ip" "$DNS_SERVER"
done < "$HOSTS_FILE"
EOF


echo "# Modificat de Studentul A" >> check_hosts.sh
