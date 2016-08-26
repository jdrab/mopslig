### verify-key

Verify license key

```sh
Usage:

verify-key      --key           key to verify
                --buid-id       display build-id

Exit codes:

0   - key is valid
1   - key is invalid
2   - missing key
```

### client-lic

Generate client license object
```sh
Usage:

client-lic      --key           License key
                --generate      Generate new license
                --refresh       Generate only if actual license file is invalid
                --output        license file (client.lic)
                --build-id      print build-id
                --help          display this help

Exit codes:

0   - Success
1   - Error: Wrong parameters
2   - Error: invalid key (type)
3   - Error: output file does not exist - only used when refreshing license
```

### validate-lic

Validate license file

```sh
Usage:

validate-lic    --validate              requried parameter for license validation process
                --key                   key to verify
                --imprint-output        where to save license imprint, default is ./imprint.lic
                --license               path to license file or client.lic will be used
                --build-id              display build-id
                --help                  display this help

Exit codes:

0   - License file is valid for this key
1   - License is not valid for key
2   - Error: Wrong parameters
3   - Error: License file does not exits
4   - Error: Key file does not exists
```


### imprint-lic

Read license imprint file

```sh
Usage:

imprint-lic     --key           your license key
                --imprint-file  path to your imprint.lic file
                --build-id      display build-id
                --help          display this help

Exit codes:

0   - Prints license imprint
1   - License is not valid for key
2   - Error: Wrong parameters, prints usage.
3   - Error: Imprint file does not exits
4   - Error: Key is missing
```
