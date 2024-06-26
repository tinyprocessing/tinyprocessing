#!/bin/bash

usage()
{
    echo "USAGE: $0 [-v] [-h]"
    echo ""
    echo "    -v is the verbose flag and prints information as the script runs."
    echo "    -h is the help flag and prints this message."
    echo ""
    echo "    Command line replacement for the Symantec VIP Access GUI app."
    echo "    Echoes and copies to the copy/paste buffer the one time password"
    echo "    that the Symantec VIP Access GUI app would provide."
    exit 1
}

verbose()
{
	if [ "${VERBOSE}" = true ];
	then
	    echo "    $1"
	fi
}

while getopts "hv" opt; do
    case ${opt} in
        h)
            usage
            ;;
        v)
            VERBOSE=true
            ;;
        *)
            usage
            ;;
    esac
done
shift $((OPTIND-1))

# As documented by p120ph37, he identified the AES_KEY by tracing the crypto library calls that the Symantec VIP Access app makes.
AES_KEY=D0D0D0E0D0D0DFDFDF2C34323937D7AE

SERIAL_NUMBER=$(ioreg -c IOPlatformExpertDevice -d 2 | awk -F\" '/IOPlatformSerialNumber/{print $(NF-1)}')
verbose "SERIAL_NUMBER is ${SERIAL_NUMBER}"

KEYCHAIN=/Users/${USER}/Library/Keychains/VIPAccess.keychain
verbose "KEYCHAIN is ${KEYCHAIN}"

KEYCHAIN_PASSWORD=${SERIAL_NUMBER}SymantecVIPAccess${USER}

security unlock-keychain -p ${KEYCHAIN_PASSWORD} ${KEYCHAIN}

ID_CRYPT=$(security find-generic-password -gl CredentialStore ${KEYCHAIN} 2>&1 | egrep 'acct"<blob>' | awk -F\<blob\>= '{print $2}' | awk -F\" '{print $2}')
verbose "ID_CRYPT is $ID_CRYPT"

KEY_CRYPT=$(security find-generic-password -gl CredentialStore ${KEYCHAIN} 2>&1 | grep password: | awk '{print $2}' | awk -F\" '{print $2}')
verbose "KEY_CRYPT is $KEY_CRYPT"

security lock-keychain ${KEYCHAIN}

ID_PLAIN=$(openssl enc -aes-128-cbc -d -K ${AES_KEY} -iv 0 -a <<< ${ID_CRYPT} | sed -e 's#Symantec$##')
verbose "ID_PLAIN is $ID_PLAIN"

KEY_PLAIN=$(openssl enc -aes-128-cbc -d -K ${AES_KEY} -iv 0 -a <<< ${KEY_CRYPT} | xxd -p)
verbose "KEY_PLAIN is ${KEY_PLAIN}"


OTP=$(oathtool --totp ${KEY_PLAIN})
verbose "OTP is ${OTP}"

echo ${OTP} | tr -d \\n | pbcopy
echo -e 'connect "2 Step Verification”\n<username>\<password>\n'${OTP}'\ny' | /opt/cisco/secureclient/bin/vpn -s

