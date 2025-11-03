#!/usr/bin/env bash
# SSH host selector for tmux-popup with icons and smart host detection
# Designed to be run inside a tmux popup

# Recent hosts tracking file
RECENT_HOSTS="${XDG_CACHE_HOME:-$HOME/.cache}/tmux-ssh-recent"
mkdir -p "$(dirname "$RECENT_HOSTS")"

# Function to get icon based on hostname patterns
get_host_icon() {
    host="$1"
    case "$host" in
        *prod*|*production*) echo "🔒" ;;
        *stage*|*staging*)   echo "🚧" ;;
        *dev*|*develop*)     echo "🔧" ;;
        *test*)              echo "🧪" ;;
        *docker*|*container*) echo "🐳" ;;
        *aws*|*ec2*|*cloud*) echo "☁️" ;;
        *ubuntu*|*buntu*|*debian*|*linux*) echo "🐧" ;;
        *mac*|*darwin*)      echo "🍎" ;;
        *web*|*www*)         echo "🌐" ;;
        *db*|*database*)     echo "💾" ;;
        *git*)               echo "" ;;
        localhost|127.*)     echo "🏠" ;;
        *)                   echo "🖥️" ;;
    esac
}

# Function to list known hosts from SSH history
list_known_hosts() {
    # Parse known_hosts file for hostnames
    # Handle both hashed and plain format
    {
        # Plain format hostnames (not hashed)
        awk '
            /^[^#|]/ {
                # Split on comma and space to handle multiple formats
                split($1, hosts, ",")
                for (i in hosts) {
                    host = hosts[i]
                    # Remove port numbers if present
                    gsub(/:\[?[0-9]+\]?$/, "", host)
                    # Remove brackets from IPv6
                    gsub(/[\[\]]/, "", host)
                    # Skip if it looks like an IP address, wildcard, or common services
                    if (host !~ /^[0-9.]+$/ && 
                        host !~ /^[0-9a-f:]+$/ && 
                        host !~ /[*?!]/ && 
                        host != "github.com" &&
                        host != "gitlab.com" &&
                        host != "bitbucket.org" &&
                        host != "" &&
                        length(host) > 0) {
                        print host
                    }
                }
            }
        ' ~/.ssh/known_hosts ~/.ssh/known_hosts.old 2>/dev/null
        
        # Also include SSH config hosts as they're likely to be used
        awk '
            /^Host / {
                for (i=2; i<=NF; i++) {
                    host = $i
                    # Skip wildcards and common services
                    if (host !~ /[*?!]/ && 
                        host != "github.com" &&
                        host != "gitlab.com" &&
                        host != "bitbucket.org") {
                        print host
                    }
                }
            }
        ' ~/.ssh/config ~/.ssh/config.d/* 2>/dev/null
    } | sort -u
}

# Function to list recent hosts
list_recent_hosts() {
    if [ -f "$RECENT_HOSTS" ]; then
        # Show last 10 unique recent hosts
        tac "$RECENT_HOSTS" 2>/dev/null | awk '!seen[$0]++' | head -10
    fi
}

# Function to format hosts with icons and labels
format_hosts() {
    label="$1"
    while read -r host; do
        [ -z "$host" ] && continue
        icon=$(get_host_icon "$host")
        printf "%s  %-30s  %s\n" "$icon" "$host" "$label"
    done
}

# Build host list with recent hosts at top
{
    list_recent_hosts | format_hosts "⭐ recent"
    echo "---"
    list_known_hosts | format_hosts ""
} | fzf-tmux -p 80%,70% \
    --ansi \
    --border-label ' SSH Connect ' \
    --prompt '🖥️  ' \
    --header '  Select host to connect • ^r reload • ESC cancel' \
    --bind 'tab:down,btab:up' \
    --bind 'ctrl-r:reload({
        list_recent_hosts() {
            if [ -f "'"$RECENT_HOSTS"'" ]; then
                tac "'"$RECENT_HOSTS"'" 2>/dev/null | awk "!seen[\$0]++" | head -10
            fi
        }
        list_known_hosts() {
            {
                awk "/^[^#|]/ {
                    split(\$1, hosts, \",\")
                    for (i in hosts) {
                        host = hosts[i]
                        gsub(/:\[?[0-9]+\]?\$/, \"\", host)
                        gsub(/[\[\]]/, \"\", host)
                        if (host !~ /^[0-9.]+\$/ && 
                            host !~ /^[0-9a-f:]+\$/ && 
                            host !~ /[*?!]/ && 
                            host != \"github.com\" &&
                            host != \"gitlab.com\" &&
                            host != \"bitbucket.org\" &&
                            host != \"\" &&
                            length(host) > 0) {
                            print host
                        }
                    }
                }" ~/.ssh/known_hosts ~/.ssh/known_hosts.old 2>/dev/null
                awk "/^Host / {
                    for (i=2; i<=NF; i++) {
                        host = \$i
                        if (host !~ /[*?!]/ && 
                            host != \"github.com\" &&
                            host != \"gitlab.com\" &&
                            host != \"bitbucket.org\") {
                            print host
                        }
                    }
                }" ~/.ssh/config ~/.ssh/config.d/* 2>/dev/null
            } | sort -u
        }
        format_hosts() {
            label="$1"
            while read -r host; do
                [ -z "$host" ] && continue
                case "$host" in
                    *prod*|*production*) icon="🔒" ;;
                    *stage*|*staging*)   icon="🚧" ;;
                    *dev*|*develop*)     icon="🔧" ;;
                    *test*)              icon="🧪" ;;
                    *docker*|*container*) icon="🐳" ;;
                    *aws*|*ec2*|*cloud*) icon="☁️" ;;
                    *ubuntu*|*buntu*|*debian*|*linux*) icon="🐧" ;;
                    *mac*|*darwin*)      icon="🍎" ;;
                    *web*|*www*)         icon="🌐" ;;
                    *db*|*database*)     icon="💾" ;;
                    *git*)               icon="" ;;
                    localhost|127.*)     icon="🏠" ;;
                    *)                   icon="🖥️" ;;
                esac
                printf "%s  %-30s  %s\n" "$icon" "$host" "$label"
            done
        }
        {
            list_recent_hosts | format_hosts "⭐ recent"
            echo "---"
            list_known_hosts | format_hosts ""
        }
    })' \
    --preview 'bash -c '\''
        host={2}
        echo "=== SSH Configuration ==="
        ssh -G "$host" 2>/dev/null | grep -E "^(hostname|user|port|identityfile)" | \
            awk "{printf \"%-15s: %s\\n\", toupper(substr(\$1,1,1)) substr(\$1,2), substr(\$0, index(\$0,\$2))}"
        echo ""
        echo "=== Connection Status ==="
        actual_host=$(ssh -G "$host" 2>/dev/null | awk "/^hostname / {print \$2}")
        test -z "$actual_host" && actual_host="$host"
        if timeout 1 nc -z "$actual_host" 22 2>/dev/null; then
            echo "✓ Reachable"
        else
            echo "✗ Unreachable"
        fi
        if test -f "'"$RECENT_HOSTS"'" && grep -q "^$host\$" "'"$RECENT_HOSTS"'" 2>/dev/null; then
            echo ""
            echo "=== Recent Connection ==="
            echo "Previously connected"
        fi
    '\''' \
    --preview-window 'right:50%' \
    --delimiter ' ' \
    --with-nth 1,2,3 | awk '{print $2}'
