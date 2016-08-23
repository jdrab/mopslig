#!/bin/bash
OPTIND=1         # Reset in case getopts has been used previously in the shell.

function remove_files {
	rm -rf ../data/*
  unlink ../tmp/imprint.lic
	unlink ../tmp/client.lic
	unlink ../tmp/key.lic
	rm -rf ../tmp/*.tmp
	unlink ../build/client-lic
	unlink ../build/validate-lic
	unlink ../build/verify-key
	unlink ../build/imprint-lic
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