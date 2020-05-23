# transfer

A bash script for uploading and downloading from <https://transfer.sh/> and <https://0x0.st>.

Submit an issue for support for similar sites.

## Features

* Upload files
* Upload directories (archives them as they are being uploaded)
* Download files
* Encrypt files as they are being uploaded
* Decrypt files as they are being downloaded
* Decrypt files after they are downloaded
* Log urls to `~/.transfer_history`
* Provide default password with `pass`

## Dependencies

* bash
* curl
* gpg
* tee
* tar
* pass (optional)

These are installed by default on most Linux systems. Refer to your package manager if you need to install them.

## Installation

0) Clone the repository `git clone https://github.com/jrodal98/transfer.git && cd transfer`
1) Install the dependencies listed above using your package manager. 
2) Optionally, set a default password using `pass insert transfer` and/or change the default password in the `transfer.sh` file (highly recommended)
3) Add `$HOME/bin` to your path. If you use bash, then you would add `export PATH="$HOME/bin:$PATH"` to your `~/.bashrc`. If using zsh, add that line of code to your `~/.zshrc` file.
4) Run `./install.sh`

Alternatively, you can just call the `transfer.sh` script directly instead of doing steps 3-4, but I don't recommend this, as it's more verbose. You could also install the program by running `sudo mv transfer.sh /usr/bin/transfer`, but I'm not sure if there are other shell scripts called transfer in the wild, so this could be dangerous.

## Examples

* Upload a file or directory: `transfer <FILE|DIRECTORY>`
* Automatically encrypt a file or directory using a default password while uploading: `transfer -e <FILE|DIRECTORY>`
* Automatically encrypt a file or directory using a provided password while uploading: `transfer -e -p <PASSWORD> <FILE|DIRECTORY>`
* Download a file: `transfer <URL>`
* Automatically decrypt a file using a default password while downloading: `transfer -d <URL>`
* Automatically decrypt a file using a provided password while downloading: `transfer -d -p <password> <URL>`
* Decrypt file with default password: `transfer -d <FILE>`
* Decrypt file with a provided password `transfer -d -p <password> <FILE>`
* Do all of the above but upload to <https://0x0.st> instead: `transfer -s 0x0.st <everything else>`

## Unimplemented features

* Automatically copy urls to clipboard (`-c flag`, will add xclip as a dependency)
* Specify maximum number of downloads
* Specify maximum life of url
* cronjob for deleting expired urls from `~/.transfer_history`
