# transfer

A bash script for uploading and downloading from <https://transfer.sh/>.

## Features

* Upload files
* Download files
* Encrypt files as they are being uploaded
* Decrypt files as they are being downloaded
* Decrypt files after they are downloaded
* Log urls to `~/.transfer_history`

## Dependencies

* bash
* curl
* gpg
* tee

These are installed by default on most Linux systems. Refer to your package manager if you need to install them.

## Installation

0) Clone the repository `git clone https://github.com/jrodal98/transfer.git && cd transfer`
1) Install the dependencies listed above using your package manager. 
2) Optionally, change the default password in the `transfer.sh` file (highly recommended)
3) Add `$HOME/bin` to your path. If you use bash, then you would add `export PATH="$HOME/bin:$PATH"` to your `~/.bashrc`. If using zsh, add that line of code to your `~/.zshrc` file.
4) Run `./install.sh`

Alternatively, you can just call the `transfer.sh` script directly instead of doing steps 3-4, but I don't recommend this, as it's more verbose.

## Examples

* Upload a file: `transfer <FILE>`
* Automatically encrypt a file using a default password while uploading: `transfer -e <FILE>`
* Automatically encrypt a file using a provided password while uploading: `transfer -e -p <PASSWORD> <FILE>`
* Download a file: `transfer <URL>`
* Automatically decrypt a file using a default password while downloading: `transfer -d <URL>`
* Automatically decrypt a file using a provided password while downloading: `transfer -d -p <password> <URL>`
* Decrypt file with default password: `transfer -d <FILE>`
* Decrypt file with a provided password `transfer -d -p <password> <FILE>`

## Unimplemented features

* Automatically copy urls to clipboard (`-c flag`, will add xclip as a dependency)
* Specify maximum number of downloads
* Specify maximum life of url
* add other sites
* cronjob for deleting expired urls from `~/.transfer_history`
