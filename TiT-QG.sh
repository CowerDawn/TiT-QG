#!/bin/bash

neofetch_installed=false

install_package() {
    sudo pacman -S "$1"
}

remove_package() {
    sudo pacman -R "$1"
}

open_program() {
    "$1" &
}

close_program() {
    pkill "$1"
}

open_tty() {
    chvt 2
}

install_neofetch() {
    if [ "$neofetch_installed" = false ]; then
        install_package "neofetch"
        neofetch_installed=true
    fi
    neofetch --ascii_distro linux
}

clear_screen() {
    exec "$0"
}

show_help() {
    echo "Available commands:"
    echo "  install [package name] - Installs a package"
    echo "  remove [package name]  - Removes a package"
    echo "  open [program]         - Opens a program"
    echo "  close [program]        - Closes a program"
    echo "  tty                    - Opens a TTY session"
    echo "  neofetch               - Installs and runs neofetch"
    echo "  clear                  - Clears the screen and restarts the program"
    echo "  help                   - Shows this help"
    echo "  exit                   - Exits the program"
    echo "  nano [filename]        - Searches for a file and opens it with nano"
    echo "  psearch [package name] - Searches for a package in the pacman repository"
    echo "  term                   - Opens a regular terminal temporarily"
}

search_and_open_file() {
    files=($(find / -name "$1" 2>/dev/null))
    num_files=${#files[@]}

    if [ "$num_files" -eq 0 ]; then
        echo "File not found: $1"
    elif [ "$num_files" -eq 1 ]; then
        nano "${files[0]}"
    else
        echo "Multiple files found. Please choose one:"
        for i in "${!files[@]}"; do
            echo "$((i+1)). ${files[$i]}"
        done
        read -p "Enter the number of the file to open: " choice
        if [[ "$choice" =~ ^[0-9]+$ ]] && [ "$choice" -ge 1 ] && [ "$choice" -le "$num_files" ]; then
            nano "${files[$((choice-1))]}"
        else
            echo "Invalid choice. Aborting."
        fi
    fi
}

search_package() {
    pacman -Ss "$1"
}

open_regular_terminal() {
    echo "Press 'Esc' to return to TiT-QG."
    stty -echo
    while true; do
        read -rsn1 input
        if [ "$input" = $'\e' ]; then
            break
        fi
    done
    stty echo
    echo "Returning to TiT-QG."
}

ascii_art="

░▒▓████████▓▒░▒▓█▓▒░▒▓████████▓▒░▒▓██████▓▒░ ░▒▓██████▓▒░  
   ░▒▓█▓▒░   ░▒▓█▓▒░  ░▒▓█▓▒░  ░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░ 
   ░▒▓█▓▒░   ░▒▓█▓▒░  ░▒▓█▓▒░  ░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░        
   ░▒▓█▓▒░   ░▒▓█▓▒░  ░▒▓█▓▒░  ░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒▒▓███▓▒░ 
   ░▒▓█▓▒░   ░▒▓█▓▒░  ░▒▓█▓▒░  ░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░ 
   ░▒▓█▓▒░   ░▒▓█▓▒░  ░▒▓█▓▒░  ░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░ 
   ░▒▓█▓▒░   ░▒▓█▓▒░  ░▒▓█▓▒░   ░▒▓██████▓▒░ ░▒▓██████▓▒░  
                                  ░▒▓█▓▒░                  
                                   ░▒▓██▓▒░                

"

echo "$ascii_art"

while true; do
    read -e -p "$ " command

    command="${command#$}"

    read -r cmd arg <<< "$command"

    case "$cmd" in
        install)
            install_package "$arg"
            ;;
        remove)
            remove_package "$arg"
            ;;
        open)
            open_program "$arg"
            ;;
        close)
            close_program "$arg"
            ;;
        tty)
            open_tty
            ;;
        neofetch)
            install_neofetch
            ;;
        clear)
            clear_screen
            ;;
        help)
            show_help
            ;;
        exit)
            break
            ;;
        nano)
            search_and_open_file "$arg"
            ;;
        psearch)
            search_package "$arg"
            ;;
        term)
            open_regular_terminal
            ;;
        *)
            echo "Unknown command: $cmd"
            ;;
    esac
done
