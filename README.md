<h1 align="center">LAQIH</h1>
<p align="center">
  <img src="https://github.com/mehmetsensoyme/LAQIH/blob/main/images/Linuxcnc_logo.png" alt="Image 1" width="150" style="display: inline-block; padding-right: 40px;">
   &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
  <img src="https://github.com/mehmetsensoyme/LAQIH/blob/main/images/QtPyVCP_logo.png" alt="Image 2" width="150" style="display: inline-block;">
</p>

<p align="center">
  <strong style="font-size: 72px;">LinuxCNC and QtPyVCP Installation Helper</strong>
</p>

## System Requirements

To run this project, the following system specifications are recommended:
- **Debian 12 (Latest Stable Version)**
- **Internet connection** for downloading dependencies and updates

## Installation

Follow these steps to install and set up the project:

* **Step 1:** \
To download this script, it is necessary to have git installed. If you don't have git already installed, or if you are unsure, run the following command:
```shell
sudo apt-get update && sudo apt-get install git -y
```

* **Step 2:** \
Once git is installed, use the following command to download LAQIH into your home-directory:

```shell
cd ~ && git clone https://github.com/mehmetsensoyme/LAQIH.git
```

* **Step 3:** \
Finally, start LAQIH by running the next command:

```shell
bash ./LAQIH/laqih.sh
```

## LinuxCNC Widgets Installation Steps

1. **Open a terminal**: Open a new terminal window.

2. **Run the command**: Enter the following command in the terminal to start the installation:

```bash
echo "3" | bash /usr/lib/python3/dist-packages/qtvcp/designer/install_script
```