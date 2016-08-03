#!/bin/bash
OPTIND=1         # Reset in case getopts has been used previously in the shell.

function remove_files {
	rm -rf ./data
	unlink ./client.lic
	unlink ./key.lic
	rm -rf ./*.tmp
	unlink ./client-lic
	unlink ./validate-lic
	unlink ./verify-key
	unlink ./imprint-lic
	echo "files removed"
}

function usage {
	echo "Use -y if you want to delete files";
}

unset iwant

while getopts ":y" opt; do
  case $opt in
    y)
      remove_files
      iwant=y
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      ;;
  esac
done

if [ -z "$iwant" ]
then
   usage
   exit
fi