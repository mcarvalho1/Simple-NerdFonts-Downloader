#!/bin/bash

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

declare -a versions=(
  3.1.1
  3.1.0
  3.0.2
  3.0.1
  3.0.0
)

# Functions to install dependencies on different distros.
install_dependencies_debian() {
  sudo apt-get update
  sudo apt-get install -y wget unzip tar fontconfig
}

install_dependencies_fedora() {
  sudo dnf install -y wget unzip tar fontconfig
}

install_dependencies_arch() {
  sudo pacman -Sy --noconfirm wget unzip tar fontconfig
}

install_dependency() {
  local dependency=$1

  if ! command -v "$dependency" &> /dev/null; then
I     read -p "The '$dependency' command is not installed. Do you want to install it? (y/n): " install_dependency_choice     ■ read without -r will mangle backslashes.
    if [ "$install_dependency_choice" == "y" ]; then
      case $distro in
        "debian") install_dependencies_debian ;;
        "fedora") install_dependencies_fedora ;;
        "arch") install_dependencies_arch ;;
        *) echo "Unsupported distribution. Exiting."; exit 1 ;;
      esac
    else
      echo "Exiting. Make sure to have '$dependency' installed to continue."
      exit 1
    fi
  fi
}

echo "Select your base distribution:"
echo "[1] - Debian/Ubuntu"
echo "[2] - Fedora"
echo "[3] - Arch Linux"

read -rp "Enter the number of your base distribution: " distro_choice

case "$distro_choice" in
  1) distro="debian";;
  2) distro="fedora";;
  3) distro="arch";;
  *) echo "Invalid choice. Exiting."; exit 1 ;;
esac

dependencies=("wget" "unzip" "tar" "fc-cache")
for dep in "${dependencies[@]}"; do
  install_dependency "$dep"
done

echo "Choose the font to install or select 'All' to download all fonts:"
for i in "${!fonts[@]}"; do
  echo "[$((i+1))] - ${fonts[$i]}"
done

echo "[$((${#fonts[@]} + 1))] - All Fonts"

read -rp "Enter your choice: " font_choice

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

echo "Choose version to install:"
for i in "${!versions[@]}"; do
  echo "[$((i+1))] - ${versions[$i]}"
done

read -rp "Enter your choice: " version_choice

download_and_install_font() {
  local selected_font="$1"
  local extension="$2"
  local version="$3"
  local zip_file="${selected_font}${extension}"
  local download_url="https://github.com/ryanoasis/nerd-fonts/releases/download/v${version}/${zip_file}"

  echo "$zip_file"
  echo "$download_url"

  echo "Downloading and installing '$selected_font'..."

  wget --quiet "$download_url" -O "$zip_file" || { echo "Error: Unable to download '$selected_font'."; return 1; }

  if [[ "$extension" == ".zip" ]]; then
    unzip -q "$zip_file" -d "${HOME}/.local/share/fonts" || { echo "Error: Unable to extract '$selected_font'."; return 1; }
  else
    tar -xf "$zip_file" -C "${HOME}/.local/share/fonts" || { echo "Error: Unable to extract '$selected_font'."; return 1; }
  fi

  rm "$zip_file"
  echo "'$selected_font' installed successfully."
}

if ! [[ "$version_choice" =~ ^[1-9][0-9]*$ && "$version_choice" -le ${#versions[@]} ]]; then
  echo "Invalid version choice. Exiting."
  exit 1
fi

version="${versions[$((version_choice-1))]}"

if [ "$font_choice" -eq "${#fonts[@]}+1" ]; then
  for font in "${fonts[@]}"; do
    download_and_install_font "$font", ".zip", "$version"
  done
else
  if ! [[ "$font_choice" =~ ^[1-9][0-9]*$ && "$font_choice" -le ${#fonts[@]} ]]; then
    echo "Invalid font choice. Exiting."
    exit 1
  fi

  selected_font="${fonts[$((font_choice-1))]}"
  download_and_install_font "$selected_font" "$extension" "$version"
fi

if command -v fc-cache &> /dev/null; then
  fc-cache -f > /dev/null || { echo "Error: Unable to update font cache. Exiting."; exit 1; }
  echo "Font cache updated."
else
  echo "Command 'fc-cache' not found. Make sure to have the necessary dependencies installed to update the font cache."
fi
