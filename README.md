# Mopslig - My Open Source License Generator 

These scripts can be used to generate license keys, verifycation hashes,
extraction "pseudo" keys, extraction hashes and a license object,
in which all license types are stored.

## Prerequisites
- pp - perl PAR packager
- perl File::Slurp;
- perl JSON::XS;
- perl Getopt::Long;
- perl Time::Piece;
- perl Digest::SHA;
- perl Digest::SHA1;
- perl Crypt::PBKDF2;
- perl Crypt::PBKDF2::Hash::HMACSHA2;

## Usage:
- edit config.json
- run 

```sh
$./mopslig.pl sure
```
- this will generate "keys/serial numbers", hashes, extraction keys 
(pseudo keys in this version, clients are offline) and extraction hashes.
  - key - is used as main license key for client
  - key_hash - is generated for key and is used to verify that key is valid. (PBKDF2 HMACSHA2 512)
  - extraction_key - is extracted from key by a retarded function (but it works for me)
  - extraction_hash - this is the same ask key_has is to key, except it is generated for extraction_key

- build binary files 
```sh
 ./build-client-lic.pl
 ./build-imprint-lic.pl
 ./build-validate-lic.pl
 ./build-verify-key.pl 
 ```
- pick one of generated serial numbers from data/serials.txt 
- generate client.lic and check exit code. You can generate client license file to other file too,
but you will have to change test_it.pl later. 

```sh 
$ ./client-lic --generate --key YOUR_LICENSE_KEY --output client.lic
```

- validate license file ./validate-lic, check exit code 

```sh 
$ ./validate-lic --validate
```

- read imprint.lic file
```sh
$ ./imprint-lic --key YOUR_LICENSE_KEY --imprint-file imprint.lic


### Files

#### key.lic 
> your license key should be stored here (mopslig.pl generates one default key - START-DE12-FA34-UL56-T789)
You don't need to save your license key in this file but binary validate-lic requires this file if 
you don't use --key when running it. It reads key.lic content and uses it as license key in validation
process.

#### config.json
>JSON file with informations about package names and key
```json
{
  "licenses": {
    "valid_since": "2016-08",
      "valid_until": "2017-07",
    "amounts": {
      "start": 10,
      "plus":  10,
      "premium": 10
    },
    "types": {
      "plus": {
        "kbsusers": {
          "license_amount": 20,
          "valid_since": "2016-08",
          "valid_until": "2017-07"
        },
        "valid_since": "2016-08",
        "valid_until": "2017-07"
      },
      "premium": {
        "kbsusers": {
          "license_amount": 50,
          "valid_since": "2016-08",
          "valid_until": "2017-07"
        },
        "valid_since": "2016-08",
        "valid_until": "2017-07"
      },
      "start": {
        "kbsusers": {
          "license_amount": 5,
          "valid_since": "2016-08",
          "valid_until": "2017-07"
        },
        "valid_since": "2016-08",
        "valid_until": "2017-07"
      }      
    }
  }
}
```

#### mopslig.pl
> will generate license keys,verification hashes, extraction  "pseudo keys" 
and extraction hashes for extracting license files from licenses object

```sh
$ ./mopslig.pl 

Are you sure?

Your files will be OVERWRITEN.
Settings are read from ./config.json file.
If you're really sure you want to generate NEW serial numbers and hashes, please say 'sure'.

Usage:   ./mopslig.pl sure      --no-dots       --debug

```

#### build-client-lic.pl 
> Reads data/build-id, config.json and replaces MOPSLIG_BUILD_ID and MOPSLIG_LICSENSE_CONFIG
by values from those two files.

#### client-lic.template
> Almost complete perl file only sompe parts are replaced from generated files in data/ foler.

#### client-lic.tmp
> This file exist only after ./build-client-lic.pl ran - it's complete perl script. 
It is used by the perl pp command to build client-lic binary.

#### client-lic
> Binary file build from client-lic.tmp by pp command


#### build-imprint-lic.pl 
> Reads data/build-id and replaces MOPSLIG_BUILD_ID in imprint-lic.template.

#### imprint-lic.template
> Almost complete perl file only sompe parts are replaced from generated files in data/ foler.

#### imprint-lic.tmp
> This file exist only after ./build-imprint-lic.pl ran - it's complete perl script. 
It is used by the perl pp command to build imprint-lic binary.

#### build-validate-lic.pl 
> Reads data/build-id, data/extraction-hashes.txt and replaces MOPSLIG_BUILD_ID and MOPSLIG_EXTRACTION_HASHES
by values from those two files.

#### validate-lic.template
> Almost complete perl file only sompe parts are replaced from generated files in data/ foler.

#### validate-lic.tmp
> This file exist only after ./build-validate-lic.pl ran - it's complete perl script. 
It is used by the perl pp command to build validate-lic binary.

#### build-verify-key.pl 
> Reads data/build-id, data/verify-hashes.txt and replaces MOPSLIG_BUILD_ID and MOPSLIG_VERIFY_HASHES
by values from those two files.

#### verify-key.template
> Almost complete perl file only sompe parts are replaced from generated files in data/ foler.

#### verify-key.tmp
> This file exist only after ./build-verify-key.pl ran - it's complete perl script. 
It is used by the perl pp command to build verify-key binary.

### Todos

  - Improve documentation
  - Add support for --imprint-to in validate-lic
  - Add support for --no-default-key to mopslig.pl 


