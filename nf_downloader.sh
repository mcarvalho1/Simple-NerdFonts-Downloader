#!/bin/bash

declare distro extension font_choice version
declare -a fonts=(
  0xProto
  3270
  Agave
  AnonymousPro
  Arimo
  AurulentSansMono
  BigBlueTerminal
  BitstreamVeraSansMono
  CascadiaCode
  CascadiaMono
  CodeNewRoman
  ComicShannsMono
  CommitMono
  Cousine
  D2Coding
  DaddyTimeMono
  DejaVuSansMono
  DroidSansMono
  EnvyCodeR
  FantasqueSansMono
  FiraCode
  FiraMono
  FontPatcher
  GeistMono
  Go-Mono
  Gohu
  Hack
  Hasklig
  HeavyData
  Hermit
  iA-Writer
  IBMPlexMono
  Inconsolata
  InconsolataGo
  InconsolataLGC
  IntelOneMono
  Iosevka
  IosevkaTerm
  IosevkaTermSlab
  JetBrainsMono
  Lekton
  LiberationMono
  Lilex
  MartianMono
  Meslo
  Monaspace
  Monofur
  Monoid
  Mononoki
  MPlus
  NerdFontsSymbolsOnly
  Noto
  OpenDyslexic
  Overpass
  ProFont
  ProggyClean
  RobotoMono
  ShareTechMono
  SourceCodePro
  SpaceMono
  Terminus
  Tinos
  Ubuntu
  UbuntuMono
  VictorMono
)

# Functions to install dependencies on different distros.
install_message="Installing dependencies. Please wait..."

install_dependencies_debian() {
  echo "$install_message"
  sudo apt-get update > /dev/null 2>&1
  sudo apt-get install -y wget unzip tar fontconfig jq > /dev/null 2>&1
}

install_dependencies_fedora() {
  echo "$install_message"
  sudo dnf install -y wget unzip tar fontconfig jq > /dev/null 2>&1
}

install_dependencies_arch() {
  echo "$install_message"
  sudo pacman -Sy --noconfirm wget unzip tar fontconfig jq > /dev/null 2>&1
}

install_dependencies_osx() {
  echo "$install_message"
  yes | brew install wget unzip gnu-tar fontconfig jq > /dev/null 2>&1

  status=$?
  if [ $status -eq 1 ]; then exit 1; fi
}

install_dependencies() {
  read -rp "Installing: wget, unzip, tar, fontconfig and jq. Do you want to continue? (y/n): " install_dependency_choice

  if [ "$install_dependency_choice" == "y" ]; then
    case $distro in
      "debian") install_dependencies_debian ;;
      "fedora") install_dependencies_fedora ;;
      "arch") install_dependencies_arch ;;
      "osx") install_dependencies_osx ;;
      *) echo "Unsupported distribution. Exiting."; exit 1 ;;
    esac
  else
    echo "Exiting. Make sure to have the dependencies installed to continue."
    exit 1
  fi
}

# Functions to make selections
choose_distro() {
  echo "Select your base distribution:"
  echo "[1] - Debian/Ubuntu"
  echo "[2] - Fedora"
  echo "[3] - Arch: Linux"
  echo "[4] - OSX"

  read -rp "Enter the number of your base distribution: " distro_choice

  case "$distro_choice" in
    1) distro="debian";;
    2) distro="fedora";;
    3) distro="arch";;
    4) distro="osx";;
    *) echo "Invalid choice. Exiting."; exit 1 ;;
  esac
}

choose_font() {
  echo "Choose the font to install or select 'All' to download all fonts:"
  for i in "${!fonts[@]}"; do
    echo "[$((i+1))] - ${fonts[$i]}"
  done

  echo "[$((${#fonts[@]} + 1))] - All Fonts"

  read -rp "Enter your choice: " font_choice
}

choose_extension() {
  echo "Choose the extension to install:"
  echo "[1] - .zip"
  echo "[2] - .tar.xz"

  read -rp "Enter the number of the desired extension: " extension_choice

  if ! [[ "$extension_choice" =~ ^[1-2]$ ]]; then
    echo "Invalid extension choice. Exiting."
    exit 1
  fi


  case "$extension_choice" in
    1) extension=".zip";;
    2) extension=".tar.xz";;
  esac
}

choose_version() {
  latest_version=$(curl -s "https://api.github.com/repos/ryanoasis/nerd-fonts/tags" | jq -r '.[0].name')

  echo "Choose version to install, enter a specific version using the vX.Y.Z format (latest Nerd Font version: $latest_version)"
  read -rp "Enter your choice: " version
}

download_and_install_font() {
  local selected_font="$1"
  local extension="$2"
  local version="$3"
  local distro="$4"
  local zip_file="${selected_font}${extension}"
  local download_url="https://github.com/ryanoasis/nerd-fonts/releases/download/${version}/${zip_file}"
  local font_dir=""

  case $distro in
    "osx") font_dir="/Library/Fonts";;
    *) 
      font_dir="${HOME}/.local/share/fonts"
      mkdir -p "$font_dir"
      ;;
  esac

  echo "Downloading and installing '$selected_font'..."

  wget --quiet "$download_url" -O "$zip_file" || { echo "Error: Unable to download '$selected_font'."; return 1; }

  if [[ "$extension" == ".zip" ]]; then
    unzip -q "$zip_file" -d "$font_dir" || { echo "Error: Unable to extract '$selected_font'."; return 1; }
  else
    tar -xf "$zip_file" -C "$font_dir" || { echo "Error: Unable to extract '$selected_font'."; return 1; }
  fi

  rm "$zip_file"
  echo "'$selected_font' installed successfully."
}

choose_distro
install_dependencies
choose_font
choose_extension
choose_version

if [ "$font_choice" -eq "$((${#fonts[@]} + 1))" ]; then
  for font in "${fonts[@]}"; do
    download_and_install_font "$font" "$extension" "$version" "$distro"
  done
else
  if ! [[ "$font_choice" =~ ^[1-9][0-9]*$ && "$font_choice" -le ${#fonts[@]} ]]; then
    echo "Invalid font choice. Exiting."
    exit 1
  fi

  selected_font="${fonts[$((font_choice-1))]}"
  download_and_install_font "$selected_font" "$extension" "$version" "$distro"
fi

if command -v fc-cache &> /dev/null; then
  fc-cache -f > /dev/null || { echo "Error: Unable to update font cache. Exiting."; exit 1; }
  echo "Font cache updated."
else
  echo "Command 'fc-cache' not found. Make sure to have the necessary dependencies installed to update the font cache."
fi
