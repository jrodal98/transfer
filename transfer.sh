#!/usr/bin/env bash
# www.jrodal.dev

PASSWORD="$(pass transfer 2>/dev/null)" || { PASSWORD="6NR2spUqe%vMqA#9G#ySq"; echo "pass command failed - setting $PASSWORD as default password."; }
SITE="transfer.sh"

function main () {
    check_dependencies
    parse_args $@ # $INPUT, $SITE, and $PASSWORD are defined in this function
    transfer_data 
}

function check_dependencies() {
    command -v gpg >/dev/null 2>&1 || { echo "Install gnupg using your favorite package manager." >&2; exit 1; }
    command -v curl >/dev/null 2>&1 || { echo "Install curl using your favorite package manager." >&2; exit 1; }
    command -v tee >/dev/null 2>&1 || { echo "Install tee using your favorite package manager." >&2; exit 1; }
    command -v tar >/dev/null 2>&1 || { echo "Install tar using your favorite package manager." >&2; exit 1; }
}


function usage ()
{
    echo "Usage :  $0 [options] [path to file, directory, or url]

    Options:
    -d|decrypt              Decrypt while downloading or decrypt file
    -e|encrypt              Encrypt while uploading
    -h|help                 Display this message
    -p|password <PASSWORD>  Supply a password for encryption or decryption"

}

#-----------------------------------------------------------------------
#  Handle command line arguments
#-----------------------------------------------------------------------
# TODO: add a -s option for site (allow uploads/downloads from multiple sites)
# TODO: add a -c flag to copy to xclip
# TODO: add a max days option. Just have a default MAX=14 variable and pass it when uploading
function parse_args() {
    local opt OPTIND
    while getopts "dehp:" opt; do
        case $opt in

            d) d=true;;

            e) e=true;;

            h) usage; exit 0;;

            p) PASSWORD=$OPTARG; echo "Using provided password instead of default" >&2;;

            * ) echo -e "\n  Option does not exist : OPTARG\n"
                usage; exit 1;;

            esac    # --- end of case ---
        done
        shift $((OPTIND-1))

        if [[ $# -ne 1 ]]; then
            usage
            exit 1
        fi

        INPUT=$1

    }

function download_mode() {
    local OUTFILE
    echo "Url detected - attempting to download $INPUT" >&2
    OUTFILE="transfer$(date +%s)_$(basename $INPUT)"
    if [ $d ]; then
        echo "Decrypting while downloading..." >&2
        curl $INPUT --progress-bar | gpg --batch --passphrase $PASSWORD -d > $OUTFILE && echo $OUTFILE
    else
        curl $INPUT -o $OUTFILE --progress-bar && echo $OUTFILE
    fi
}

function encrypt_and_upload_dir() {
    echo "archiving, compressing, encrypting, and uploading $INPUT.tar.gz" >&2
    case $SITE in
        transfer.sh)
            tar -zcvO $INPUT | gpg --batch --passphrase $PASSWORD --symmetric -o- | curl -X PUT --upload-file "-" "https://transfer.sh/$(basename $INPUT).tar.gz" --progress-bar -w " $(date +%c)\n"| tee -a $HOME/.transfer_history
            ;;
        *)
            echo "$SITE not supported." >&2
            exit 1
    esac
}

function upload_dir() {
    echo "archiving, compressing, and uploading $INPUT.tar.gz with NO ENCRYPTION..." >&2
    case $SITE in
        transfer.sh)
            tar -zcvO $INPUT | curl -X PUT --upload-file "-" "https://transfer.sh/$(basename $INPUT).tar.gz" --progress-bar -w " $(date +%c)\n"| tee -a $HOME/.transfer_history
            ;;
        *)
            echo "$SITE not supported." >&2
            exit 1
    esac
}


function decrypt_file() {
    local OUTFILE
    echo "Attempting to decrypt $INPUT..." >&2
    OUTFILE="$(dirname $INPUT)/decrypted$(date +%s)_$(basename $INPUT)"
    gpg --batch --passphrase $PASSWORD -o $OUTFILE -d $INPUT && echo "Decrypted $INPUT into $OUTFILE"
}

function encrypt_and_upload_file() {
    echo "encrypting and uploading $INPUT..." >&2
    case $SITE in
        transfer.sh)
            gpg --batch --passphrase $PASSWORD --symmetric -o- $INPUT | curl -X PUT --upload-file "-" "https://transfer.sh/$(basename $INPUT)" --progress-bar -w " $(date +%c)\n"| tee -a $HOME/.transfer_history
            ;;
        *)
            echo "$SITE not supported." >&2
            exit 1
    esac
}

function upload_file() {
    echo "uploading $INPUT with NO ENCRYPTION..." >&2
    case $SITE in
        transfer.sh)
            curl --upload-file $INPUT "https://transfer.sh/$(basename $INPUT)" --progress-bar -w " $(date +%c)\n"| tee -a $HOME/.transfer_history
            ;;
        *)
            echo "$SITE not supported." >&2
            exit 1
    esac
}


function transfer_data() {
    regex='(https?|ftp|file)://[-A-Za-z0-9\+&@#/%?=~_|!:,.;]*[-A-Za-z0-9\+&@#/%=~_|]'
    if [[ $INPUT =~ $regex ]]; then
        download_mode $@
    elif [[ -d $INPUT ]]; then
        dir_mode $@
    elif [[ -f $INPUT ]]; then
        file_mode $@
    else
        echo "ERROR: $INPUT is either an invalid path or malformed url." >&2
        exit 1
    fi
}

function file_mode() {
    if [ $d ]; then
        decrypt_file $@
    elif [ $e ]; then
        encrypt_and_upload_file $@
    else
        upload_file $@
    fi
}

function dir_mode() {
    echo "$INPUT has been detected as a directory..." >&2
    if [ $d ]; then
        echo "ERROR: as far as I know, directories cannot be encrypted and decrypted..." >&2
        exit 1
    elif [ $e ]; then
        encrypt_and_upload_dir $@
    else
        upload_dir $@
    fi
}

main $@