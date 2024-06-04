#!/bin/bash

# Colors
RED='\033[1;31m'
YELLOW='\033[1;33m'
GREEN='\033[1;32m'
NOCOLOR='\033[0m'

# Error handling function
handle_error() {
    local artifact=$1
    echo -e "${RED}[!] Encountered an error retrieving ${artifact}. See more details at $output_dir/0 - Emperor_Output.txt${NOCOLOR}\n"
}

print_done() {
    echo -e "${GREEN}\n[ done ]\n${NOCOLOR}"
}

# Welcome message and prompt for output path
echo -e "${YELLOW}Welcome to Emperor. Output will be saved to a folder named 'IR'. What is the desired path for this folder?${NOCOLOR} (Format: /home/ubuntu/Desktop/)"
read -r output_base_path

# Define the output directory
output_dir="${output_base_path%/}/IR"
mkdir -p "$output_dir"

# Redirect all output to a log file
echo -e "${YELLOW}[+] Creating output file at \"$output_dir/0 - Emperor_Output.txt\"\n${NOCOLOR}"
exec > >(tee -i "$output_dir/0 - Emperor_Output.txt") 2>&1
print_done

# Get a list of running processes
echo "Getting a list of running processes..."
ps aux > "$output_dir/running_processes.txt"

# Get a list of active connections, associated processes, PIDs, and command lines and arguments
echo -e "${YELLOW}[+] Getting a list of active connections and associated information...${NOCOLOR}"
netstat -anveps > "$output_dir/active_connections.txt" || handle_error "active connections"
lsof -i -n -P > "$output_dir/active_connections_details.txt" || handle_error "active connections details"
print_done

# Pull a copy of /var/log/
echo -e "${YELLOW}[+] Pulling a copy of /var/log/...${NOCOLOR}"
cp -r /var/log "$output_dir/var_log" || handle_error "/var/log"
print_done

# Pull user and group information from /etc/passwd, /etc/shadow, and /etc/group
echo -e "${YELLOW}[+] Pulling user and group information...${NOCOLOR}"
cp /etc/passwd "$output_dir/passwd" || handle_error "/etc/passwd"
cp /etc/shadow "$output_dir/shadow" || handle_error "/etc/shadow"
cp /etc/group "$output_dir/group" || handle_error "/etc/group"
print_done

# Pull network information from /var/log/secure and /var/log/auth.log
echo -e "${YELLOW}[+] Pulling network information from logs...${NOCOLOR}"
cp /var/log/secure "$output_dir/secure_log" || handle_error "/var/log/secure"
cp /var/log/auth.log "$output_dir/auth_log" || handle_error "/var/log/auth.log"
print_done

# Pull log and configuration files from /etc/ and /var/spool/cron/, as well as /etc/hosts
echo -e "${YELLOW}[+] Pulling log and configuration files from /etc/ and /var/spool/cron/...${NOCOLOR}"
cp -r /etc "$output_dir/etc" || handle_error "/etc"
cp -r /var/spool/cron "$output_dir/var_spool_cron" || handle_error "/var/spool/cron"
cp /etc/hosts "$output_dir/hosts" || handle_error "/etc/hosts"
print_done

# Pull shell history from ~/.bash_history and ~/zsh_history
echo -e "${YELLOW}[+] Pulling shell history...${NOCOLOR}"
cp ~/.bash_history "$output_dir/bash_history" || handle_error "~/.bash_history"
cp ~/zsh_history "$output_dir/zsh_history" || handle_error "~/zsh_history"
print_done

# Pull a copy of the audit log from /var/log/audit/audit.log
echo -e "${YELLOW}[+] Pulling a copy of the audit log...${NOCOLOR}"
cp /var/log/audit/audit.log "$output_dir/audit_log" || handle_error "/var/log/audit/audit.log"
print_done

# Pull sysctl and kernel information using "sysctl -a"
echo -e "${YELLOW}[+] Pulling sysctl and kernel information...${NOCOLOR}"
sysctl -a > "$output_dir/sysctl_info.txt" || handle_error "sysctl information"
print_done

# Pull a copy of /tmp/ and /var/tmp/
echo -e "${YELLOW}[+] Pulling a copy of /tmp/ and /var/tmp/...${NOCOLOR}"
cp -r /tmp "$output_dir/tmp_copy" || handle_error "/tmp"
cp -r /var/tmp "$output_dir/var_tmp_copy" || handle_error "/var/tmp"
print_done

echo -e "${GREEN}Incident response data collection completed successfully.${NOCOLOR}\n"
echo -e "Output was saved to ${YELLOW}\"$output_dir/0 - Emperor_Output.txt\".${NOCOLOR}\n"
echo -e "Incident response package saved to ${YELLOW}\"$output_dir/\".${NOCOLOR}\nPlease zip the IR folder and pass it to the IR team. Reach out for further instructions."

# End of script
