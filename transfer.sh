#!/usr/bin/env bash
# www.jrodal.dev

# TODO: refactor code into functions

PASSWORD="defaultpasswordhere" # default password for encryption and decryption

command -v gpg >/dev/null 2>&1 || { echo "Install gnupg using your favorite package manager." >&2; exit 1; }
command -v curl >/dev/null 2>&1 || { echo "Install curl using your favorite package manager." >&2; exit 1; }
command -v tee >/dev/null 2>&1 || { echo "Install tee using your favorite package manager." >&2; exit 1; }
command -v tar >/dev/null 2>&1 || { echo "Install tar using your favorite package manager." >&2; exit 1; }

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
while getopts "dehp:" opt
do
    case $opt in

        d) d=true;;

        e) e=true;;

        h) usage; exit 0;;

        p) PASSWORD=$OPTARG;;

        * ) echo -e "\n  Option does not exist : OPTARG\n"
            usage; exit 1;;

        esac    # --- end of case ---
    done
    shift $((OPTIND-1))

    if [[ $# -ne 1 ]]; then
        usage
        exit 1
    fi

    regex='(https?|ftp|file)://[-A-Za-z0-9\+&@#/%?=~_|!:,.;]*[-A-Za-z0-9\+&@#/%=~_|]'
    if [[ $1 =~ $regex ]]; then
        echo "Url detected - attempting to download $1" >&2
        OUTFILE="transfer$(date +%s)_$(basename $1)"
        if [ $d ]; then
            echo "Decrypting while downloading..." >&2
            curl $1 --progress-bar | gpg --batch --passphrase $PASSWORD -d > $OUTFILE && echo $OUTFILE
        else
            curl $1 -o $OUTFILE --progress-bar && echo $OUTFILE
        fi
    elif [[ -d $1 ]]; then
        echo "$1 has been detected as a directory..." >&2
        if [ $d ]; then
            echo "Attempting to decrypt $1..." >&2
            OUTFILE="$(dirname $1)/decrypted$(date +%s)_$(basename $1)"
            gpg --batch --passphrase $PASSWORD -o $OUTFILE -d $1 && echo "Decrypted $1 into $OUTFILE"
        elif [ $e ]; then
            echo "archiving, compressing, encrypting, and uploading $1.tar.gz" >&2
            tar -zcvO $1 | gpg --batch --passphrase $PASSWORD --symmetric -o- | curl -X PUT --upload-file "-" "https://transfer.sh/$(basename $1).tar.gz" --progress-bar -w " $(date +%c)\n"| tee -a $HOME/.transfer_history
        else
            echo "archiving, compressing, and uploading $1.tar.gz with NO ENCRYPTION..." >&2
            tar -zcvO $1 | curl -X PUT --upload-file "-" "https://transfer.sh/$(basename $1).tar.gz" --progress-bar -w " $(date +%c)\n"| tee -a $HOME/.transfer_history
        fi
    elif [[ -f $1 ]]; then
        if [ $d ]; then
            echo "Attempting to decrypt $1..." >&2
            OUTFILE="$(dirname $1)/decrypted$(date +%s)_$(basename $1)"
            gpg --batch --passphrase $PASSWORD -o $OUTFILE -d $1 && echo "Decrypted $1 into $OUTFILE"
        elif [ $e ]; then
            echo "encrypting and uploading $1..." >&2
            gpg --batch --passphrase $PASSWORD --symmetric -o- $1 | curl -X PUT --upload-file "-" "https://transfer.sh/$(basename $1)" --progress-bar -w " $(date +%c)\n"| tee -a $HOME/.transfer_history
        else
            echo "uploading $1 with NO ENCRYPTION..." >&2
            curl --upload-file $1 "https://transfer.sh/$(basename $1)" --progress-bar -w " $(date +%c)\n"| tee -a $HOME/.transfer_history
        fi
    else
        echo "ERROR: $1 is either an invalid path or malformed url." >&2
        exit 1
    fi

