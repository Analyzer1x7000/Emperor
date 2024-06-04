#!/bin/bash

# Colors
RED='\033[1;31m'
YELLOW='\033[1;33m'
GREEN='\033[1;32m'
NOCOLOR='\033[0m' # No Color

# Define the output directory
output_dir="~/IR"
mkdir -p "$output_dir"

# Redirect all output to a log file
echo "[+] Creating output file at "$output_dir/0 - Emperor_Output.txt""
exec > >(tee -i "$output_dir/0 - Emperor_Output.txt") 2>&1
echo "[ done ]"

# Memory Dump
# Pull a full memory dump (requires root privileges and tools like 'dd' or 'makedumpfile')
echo "[+] Pulling a full memory dump..."
dd if=/dev/mem of="$output_dir/memory_dump.bin" bs=1M count=1024
echo "[ done ]"

# Running Processes
# Get a list of running processes
echo "[+] Getting a list of running processes..."
ps aux > "$output_dir/running_processes.txt"
echo "[ done ]"

# Active connections, processes, & PIDs
# Get a list of active connections, associated processes, PIDs, and command lines and arguments
echo "Getting a list of active connections and associated information..."
netstat -tuln > "$output_dir/active_connections.txt"
lsof -i -n -P > "$output_dir/active_connections_details.txt"
echo "[ done ]"

# Pull a copy of /var/log/
echo "Pulling a copy of /var/log/..."
cp -r /var/log "$output_dir/var_log"
echo "[ done ]"

# Pull user and group information from /etc/passwd, /etc/shadow, and /etc/group
echo "Pulling user and group information..."
cp /etc/passwd "$output_dir/passwd"
cp /etc/shadow "$output_dir/shadow"
cp /etc/group "$output_dir/group"
echo "[ done ]"

# Pull network information from /var/log/secure and /var/log/auth.log
echo "Pulling network information from logs..."
cp /var/log/secure "$output_dir/secure_log"
cp /var/log/auth.log "$output_dir/auth_log"
echo "[ done ]"

# Pull log and configuration files from /etc/ and /var/spool/cron/, as well as /etc/hosts
echo "Pulling log and configuration files from /etc/ and /var/spool/cron/..."
cp -r /etc "$output_dir/etc"
cp -r /var/spool/cron "$output_dir/var_spool_cron"
cp /etc/hosts "$output_dir/hosts"
echo "[ done ]"

# Pull shell history from ~/.bash_history and ~/zsh_history
echo "Pulling shell history..."
cp ~/.bash_history "$output_dir/bash_history"
cp ~/zsh_history "$output_dir/zsh_history"
echo "[ done ]"

# Pull a copy of the audit log from /var/log/audit/audit.log
echo "Pulling a copy of the audit log..."
cp /var/log/audit/audit.log "$output_dir/audit_log"
echo "[ done ]"

# Pull sysctl and kernel information using "sysctl -a"
echo "Pulling sysctl and kernel information..."
sysctl -a > "$output_dir/sysctl_info.txt"
echo "[ done ]"

# Pull a copy of /tmp/ and /var/tmp/
echo "Pulling a copy of /tmp/ and /var/tmp/..."
cp -r /tmp "$output_dir/tmp_copy"
cp -r /var/tmp "$output_dir/var_tmp_copy"
echo "[ done ]"

# Zip the IR folder and place it into /tmp/
echo "Zipping the IR folder..."
zip -r "$output_dir.zip" "$output_dir"
echo "[ done ]\n\n"

echo "${GREEN}Incident response data collection completed successfully.${NOCOLOR}\n"
echo "Output was saved to ${YELLOW}"$output_dir/0 - Emperor_Output.txt".${NOCOLOR}\n"
echo "Incident response package saved to ${YELLOW}$output_dir.${NOCOLOR}"

# End of script
