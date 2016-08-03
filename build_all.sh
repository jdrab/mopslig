#!/bin/bash
OPTIND=1         # Reset in case getopts has been used previously in the shell.

function build_all {
  echo "Mopslig is generating keys,hashes and all.."
  ./mopslig.pl sure
  echo "Building client-lic"
	./build-client-lic.pl
  echo "Building verify-key"
  ./build-verify-key.pl
  echo "Building validate-lic"
  ./build-validate-lic.pl
  echo "Buiding imprint-lic"
  ./build-imprint-lic.pl
  echo "Done"
  echo "Don't forget to pick one of generated keys from data/serials.txt and write it to key.lic\n"	
}

function usage {
	echo "Use -y if you want to build files";
}

unset buildit

while getopts ":y" opt; do
  case $opt in
    y)
      build_all
      buildit=y
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      ;;
  esac
done

if [ -z "$buildit" ]
then
   usage
   exit
fi