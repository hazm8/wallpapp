#!/usr/bin/env bash
set -ueo pipefail


## Init Api Variables
SEARCHTERM=""
TAGS=""

XRATING=110

FORCE_RES=0

SORTBY="relevance"


## Must be set in order to set XFilter to NSFW
## Format must be in the following format:

## APIKEY="apikey=xyz321"

APIKEY=""

splash_screen() {

  toilet "Wallpapp"
  printf "##################################\n"
  printf "###  Basic Bash by Hazm8  ###\n"
  printf "##################################\n\n"
  printf "What would you like to search?\n "
  printf "___________________________\n"
  printf "\n"
}

set_search_term() {
  printf "\nEnter your search term: "
  read -r SEARCHTERM
  printf "Would you like to add a tag? (y/n): "
  read -r add_tags
  if [[ "$add_tags" == "y" ]]; then
    printf "Enter an adition tag: "
    read -r TAGS
  fi
}


set_xrating() {

  if [ -z "$APIKEY" ]; then
    printf "\nSketchy and Filthy Require API key to be set\n"
  else
    printf "\nSet your NSFW preferences (1 = Cleanest, 2 = Questionable, 3 = Sketchy, 4 = Filthy): "
    read -r xrating_choice
    case $xrating_choice in
      1) XRATING=100 ;;
      2) XRATING=110 ;;
      3) XRATING=011 ;;
      4) XRATING=001 ;;
      *) printf "Invalid input, defaulting to SFW (1). \n"; XRATING=100 ;;
      esac
  fi
}

set_sorting() {

  printf "\nChoose a sorting option:\n"
  printf "1) Hot\n2) Relevant\n3) Random\n"
  read -r sort_choice
  case $sort_choice in
    1) SORTBY="hot" ;;
    2) SORTBY="relevance" ;;
    3) SORTBY="random" ;;
    *) printf "Invalid option, defaulting to Random.\n"; SORTBY="random" ;;
  esac

}

set_force_res() {
  printf "\nWould you like to filter for only landscape images? (y/n):"
  read -r resolution_choice
  case $resolution_choice in
    "y") FORCE_RES=1;;
    "n") FORCE_RES=0;;
    *) printf "Invalid option, defaulting to No \n"; FORCE_RES=0;;
  esac
}


confirm_settings() {
  printf "\nHere are your current settings:\n"
  printf "Search Term: %s\n" "$SEARCHTERM"
  if [[ -n "$TAGS" ]]; then
    printf "Tags: %s\n" "$TAGS"
  else
    printf "Tags: None\n"
  fi
  printf "X-Rating: %s\n" "$XRATING"
  printf "Sorting: %s\n" "$SORTBY"
  printf "Force Resolution: %s\n" "$FORCE_RES"

  printf "\nAre you satisfied with these settings? (y/n): "
  read -r confirm
  if [[ "$confirm" == "n" ]]; then
    printf "\nRestarting configuration...\n"
    main_menu
  fi
}


main_menu() {
  splash_screen
  set_search_term
  set_xrating
  set_sorting
  set_force_res
  confirm_settings
  set_options
}


set_options() {
  printf  "\nUpdating Options..."
  apiSearch_url="https://wallhaven.cc/api/v1/search?q=$SEARCHTERM"

  if [[ -n "$TAGS" ]]; then
    apiSearch_url="$apiSearch_url""+""$TAGS"
  fi

  apiSearch_url="$apiSearch_url&categories=111&purity=$XRATING&sorting=$SORTBY&order=desc&ai_art_filter=0"

  if [[ "$FORCE_RES" == 1 ]]; then
    apiSearch_url="$apiSearch_url&atleast=1920x1080&ratios=landscape"
  fi
  if [ -z "$APIKEY" ]; then
    apiSearch_url="$apiSearch_url&$APIKEY"
  fi

  apiGET "$apiSearch_url"
}


apiGET() {
  printf "\nStarting Download..."
  local search_url="$1"

  echo "$search_url"

  api_response=$(curl -s "$search_url")
  # Parse the JSON response and extract image paths
  if ! img_list=$(echo "$api_response" | jq -r '.data[].path' 2>/dev/null); then
    printf "Error: Failed to parse API response or no valid images found.\n" >&2
    exit 1
  fi

  echo "$img_list"
  wallp_dl "$img_list"
}

mkdir -p ~/Pictures/WallpappDIR/ || >&2

wallp_dl() {
  local dl_list="$1"
  while read -r img; do
    echo "Downloading: $img"
    wget -nc --content-on-error --tries=1 -P ~/Pictures/WallpappDIR/"$SEARCHTERM" "$img" || {
          printf "Failed to download: %s\n" "$img" >&2
          continue
      }
    done <<< "$dl_list"
}

main_menu
