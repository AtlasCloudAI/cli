#!/bin/sh
set -eu

export PATH="$(pwd)/bin:$PATH"
export TERM=xterm-256color

pause() {
  sleep "${1:-0.5}"
}

type_line() {
  text="$1"
  i=1
  printf "\033[1;36m$\033[0m "
  while [ "$i" -le "${#text}" ]; do
    printf "%s" "$(printf "%s" "$text" | cut -c "$i")"
    sleep 0.025
    i=$((i + 1))
  done
  printf "\n"
}

run_cmd() {
  type_line "$1"
  shift
  "$@"
  printf "\n"
  pause 0.8
}

clear
printf "\033[1;37mAtlasCloud CLI\033[0m\n"
printf "Call LLM, image, and video models from your shell.\n\n"
pause 0.8

run_cmd "atlas version" atlas version
run_cmd "atlas --help" atlas --help
run_cmd "atlas generate image --help" sh -c 'atlas generate image --help | sed -n "1,28p"'

type_line 'atlas generate image google/nano-banana-2/text-to-image -p "a cat"'
printf "\033[2m# Authenticate once with: atlas auth login\033[0m\n"
printf "\033[2m# Then run generation commands with --wait or --no-wait.\033[0m\n\n"
pause 1.0

printf "\033[1;32mReady:\033[0m curl -fsSL https://raw.githubusercontent.com/AtlasCloudAI/cli/main/install.sh | sh\n"
pause 2.0
