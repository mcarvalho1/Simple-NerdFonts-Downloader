# Nerd Fonts Downloader Script

## Introduction

Testing various Linux distributions, I consistently found it cumbersome to download and install them on the system. Consequently, I resolved to develop a script that streamlines the entire process, enabling me to avoid expending excessive time on customizing my shell or system.

## Installation

### Dependencies

Be aware that this script downloads (with your authorization only) the dependencies below: </br>
_Note: If you already have one, it will proceed with the process._

- `wget`
- `unzip`
- `tar`
- `fontconfig`

### Supported Distributions

The script supports the following base distributions:

- `Debian/Ubuntu`
- `Fedora`
- `Arch Linux`

### Download and Run

To install Nerd Fonts using the script:

1. Download the script:

    ```bash
    wget https://raw.githubusercontent.com/mcarvalho1/Nerd-fonts-Downloader-Script/master/nf_downloader.sh
    ```

2. Make the script executable:

    ```bash
    chmod +x nf_downloader.sh
    ```

3. Run the script:

    ```bash
    ./nf_downloader.sh
    ```

## Usage

### Choosing the Base Distribution

When you run the script, it will prompt you to choose your base distribution. Enter the number corresponding to your distribution (Debian/Ubuntu, Fedora, or Arch Linux).

### Selecting Fonts and Extensions

The script will then display a list of Nerd Fonts with corresponding numbers. Choose the desired font by entering the number. Next, select the extension (`.zip` or `.tar.xz`) by entering the corresponding number.

## Examples

Here are some examples of using the script:

1. To install a Nerd Font, run the script and follow the prompts:

    ```bash
    ./nf_downloader.sh
    ```

    Select your base distribution, then choose the font by entering its corresponding number when prompted. Afterward, you will be asked to choose the extension (`zip` or `tar.xz`).

    After making your choices, the script will download and install the selected Nerd Font.

2. For another installation, run the script again:

    ```bash
    ./nf_downloader.sh
    ```

    Repeat the steps to select a different font or extension.

## Contributing

I hope you enjoy the script and that it's as useful to you as it was to me.
If you wish, open a pull request applying new features or even bugs that may occur over time.

## License

This script is licensed under the [MIT License](LICENSE).
