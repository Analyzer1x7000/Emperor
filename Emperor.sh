#!/bin/bash

# Colors
RED='\033[1;31m'
YELLOW='\033[1;33m'
GREEN='\033[1;32m'
NOCOLOR='\033[0m'

# Error handling function
handle_error() {
    local artifact=$1
    echo -e "${RED}[!] Encountered at least one error while retrieving ${artifact}. See more details at $output_dir/0 - Emperor_Output.txt${NOCOLOR}\n"
}

print_done() {
    echo -e "${GREEN}\n[ done ]\n${NOCOLOR}"
}

getSysctl_Kernel_Info () {
    # Pull sysctl and kernel information using "sysctl -a"
    echo -e "${YELLOW}[+] Pulling sysctl and kernel information...${NOCOLOR}"
    sysctl -a > "$output_dir/sysctl_info.txt" || handle_error "sysctl information"
    print_done
}

getRunningProcesses () {
    # Get a list of running processes
    echo -e "${YELLOW}[+] Getting a list of running processes...${NOCOLOR}"
    ps aux > "$output_dir/running_processes.txt" || handle_error "running processes"
    print_done
}

getRunningProcesses_Verbose () {
    # Get a list of running processes
    echo -e "${YELLOW}[+] Getting a verbose list of running processes...${NOCOLOR}"
    pstree -p -n > "$output_dir/running_processes_verbose.txt" || handle_error "verbose running processes"
    print_done
}

getRunningProcesses_Resources_Usage () {
    # Get a list of running processes
    echo -e "${YELLOW}[+] Getting a list of running processes and resource usage...${NOCOLOR}"
    pstree -p -n > "$output_dir/running_processes_and_resource_usage.txt" || handle_error "running processes and resource usage"
    print_done
}

getRunningProcesses_Files_Hashes () {
    echo -e "${YELLOW}[+] Copying running processes, associated files, and hashes...${NOCOLOR}"
    # Define the hash output file
    HASH_OUTPUT_FILE="$output_dir/process_hashes.txt"
    # Get a list of open files and the processes that opened them
    lsof -F0 | awk -F'\0' '/^p/{pid=$2} /^c/{cmd=$2} /^n/{file=$2; print pid, cmd, file}' | while read -r pid cmd file; do
        # Create a subdirectory for each process
        PROCESS_DIR="$output_dir/$pid"
        mkdir -p "$PROCESS_DIR" || handle_error "creating process directory for PID $pid"

        # Copy the open file to the process subdirectory
        cp --parents "$file" "$PROCESS_DIR" 2>/dev/null || handle_error "copying file $file for PID $pid"

        # Log the process information and file path
        echo "PID: $pid" >> "$PROCESS_DIR/process_info.txt"
        echo "Command: $cmd" >> "$PROCESS_DIR/process_info.txt"
        echo "File: $file" >> "$PROCESS_DIR/process_info.txt"
        echo -e "\n" >> "$PROCESS_DIR/process_info.txt"
    done

    # Compute MD5 and SHA256 hashes of the running processes
    echo "Process Hashes:" > "$HASH_OUTPUT_FILE"
    for PID in $(ps -e -o pid --no-headers); do
        echo "PID: $PID" >> "$HASH_OUTPUT_FILE"
        echo "MD5:" >> "$HASH_OUTPUT_FILE"
        md5sum /proc/$PID/exe 2>/dev/null >> "$HASH_OUTPUT_FILE" || handle_error "MD5 hash for PID $PID"
        echo "SHA256:" >> "$HASH_OUTPUT_FILE"
        sha256sum /proc/$PID/exe 2>/dev/null >> "$HASH_OUTPUT_FILE" || handle_error "SHA256 hash for PID $PID"
        echo -e "\n" >> "$HASH_OUTPUT_FILE"
    done
    print_done
}

getFileSystem () {
    # Enumerate the entire file system
    echo -e "${YELLOW}[+] Enumerating the file system...${NOCOLOR}"
    sudo find / > "$output_dir/file_system.txt" || handle_error "file system enumeration"
    print_done
}

getFirewall_Rules () {
    # Enumerate firewall rules
    echo -e "${YELLOW}[+] Enumerating firewall rules...${NOCOLOR}"
    sudo iptables -L > "$output_dir/firewall_rules.txt" || handle_error "firewall rules"
    print_done
}

getActiveConnections_PIDs_CmdLines_Args () {
    # Get a list of active connections, associated processes, PIDs, and command lines and arguments
    echo -e "${YELLOW}[+] Getting a list of active connections and associated information...${NOCOLOR}"
    netstat -anveps > "$output_dir/active_connections.txt" || handle_error "active connections"
    lsof -i -n -P > "$output_dir/active_connections_details.txt" || handle_error "active connections details"
    print_done
}

getInstalledPackages () {
    # Get a list of installed packages
    echo -e "${YELLOW}[+] Getting a list of installed packages...${NOCOLOR}"
    dpkg -l > "$output_dir/installed_packages" || handle_error "installed packages"
    print_done
}

getExecutables_Scripts_Hashes () {
    # Pull copies of all executables and shell/script files + their hashes
    echo -e "${YELLOW}[+] Pulling all executable, shell, and script files...${NOCOLOR}"
    sudo find / -type f \( -perm -u=x -o -name "*.sh" -o -name "*.bash" -o -name "*.zsh" -o -name "*.elf" \) 2>/dev/null | while read -r FILE; do
        # Create the target directory structure
        TARGET_DIR="$output_dir/executables_shell_and_script_files"
        mkdir -p "$TARGET_DIR" || handle_error "creating target directory for executables and scripts"
        
        # Copy the file to the destination directory
        cp "$FILE" "$TARGET_DIR" 2>/dev/null || handle_error " or copying file $FILE.\nSome errors are expected, and are usually due to built-in file protection mechanisms.\n"

        # Generate MD5 and SHA256 hashes and save them to the destination directory
        md5sum "$FILE" > "$TARGET_DIR/$(basename "$FILE").md5" || handle_error "MD5 hash for file $FILE"
        sha256sum "$FILE" > "$TARGET_DIR/$(basename "$FILE").sha256" || handle_error "SHA256 hash for file $FILE"
    done
    print_done
}

getMountedFileSystems () {
    # Pull a list of mounted filesystems
    echo -e "${YELLOW}[+] Pulling a list of mounted filesystems...${NOCOLOR}"
    df -hT | awk 'NR>1 {print "Filesystem: "$1"\nType: "$2"\nMounted on: "$7"\nSize: "$3"\nUsed: "$4"\nAvailable: "$5"\nUse%: "$6"\n"}' > "$output_dir/mounts" || handle_error "mounted filesystems"
    print_done
}

getPROC_Directory () {
    # Pull a copy of the /proc/ directory
    echo -e "${YELLOW}[+] Pulling the /proc directory...${NOCOLOR}"
    rsync -aL --exclude '*/task/*/mem' --exclude '*/mem' --exclude '*/clear_refs' --exclude '*/attr/*' --exclude '*/smaps' --exclude '*/smaps_rollup' --exclude '*/numa_maps' --exclude '*/coredump_filter' /proc "$output_dir/proc" || handle_error "/proc"
    print_done
}

getHOME_Directory () {
    # Pull a copy of the entire /home directory
    echo -e "${YELLOW}[+] Pulling a copy of /home/...${NOCOLOR}"
    cp -r /home "$output_dir/home" || handle_error "/home"
    print_done
}

getVAR_Directory () {
    # Pull a copy of the entire /var directory
    echo -e "${YELLOW}[+] Pulling a copy of /var/...${NOCOLOR}"
    cp -r /var "$output_dir/var" || handle_error "/var"
    print_done
}

getETC_Directory () {
    # Pull a copy of the entire /etc directory
    echo -e "${YELLOW}[+] Pulling the /etc directory...${NOCOLOR}"
    cp -r /etc "$output_dir/etc" || handle_error "/etc"
    print_done
}

getUSR_Directory () {
    # Pull a copy of the entire /usr directory
    echo -e "${YELLOW}[+] Pulling the /usr directory...${NOCOLOR}"
    cp -r /usr "$output_dir/usr" || handle_error "/usr"
    print_done
}

getTMP_Directory () {
    # Pull a copy of /tmp/ folder
    echo -e "${YELLOW}[+] Pulling a copy of /tmp/...${NOCOLOR}"
    cp -r /tmp "$output_dir/tmp_copy" || handle_error "/tmp"
    print_done
}

getShellHistory () {
    # Pull shell history from ~/.bash_history and ~/zsh_history
    echo -e "${YELLOW}[+] Pulling shell history...${NOCOLOR}"
    cp ~/.bash_history "$output_dir/bash_history" || handle_error "~/.bash_history"
    cp ~/zsh_history "$output_dir/zsh_history" || handle_error "~/zsh_history"
    print_done
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

getSysctl_Kernel_Info
getRunningProcesses
getRunningProcesses_Verbose
getRunningProcesses_Resources_Usage
getRunningProcesses_Files_Hashes
getFileSystem
getFirewall_Rules
getActiveConnections_PIDs_CmdLines_Args
getInstalledPackages
getExecutables_Scripts_Hashes
getMountedFileSystems
getPROC_Directory
getHOME_Directory
getVAR_Directory
getETC_Directory
getUSR_Directory
getTMP_Directory
getShellHistory

echo -e "${GREEN}Incident response data collection completed successfully.${NOCOLOR}\n"
echo -e "Output was saved to ${YELLOW}\"$output_dir/0 - Emperor_Output.txt\".${NOCOLOR}\n"
echo -e "Incident response package saved to ${YELLOW}\"$output_dir/\".${NOCOLOR}\nPlease zip the IR folder and pass it to the IR team. Reach out for further instructions."

# End of script
