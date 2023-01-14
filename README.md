# swish - suckless-ish webframework

Swish is a small, "sane" static site generation tool implemented in Bash.
Swish is a fork of sw - the suckless webframework.

## Why fork?

I wanted:

* a differing HTML layout 
* flake support, which I didn't expect to gain traction upstream
* standard and extended markdown support without configuration
* to distance myself and my software a bit from the suckless "movement" 

## Installation

A `Makefile` is provided.
Use `make install`,
overriding the variable `DESTDIR`
if you need to install somewhere other that `/usr/local`.

Additionally, a nix flake  is provided
so that you may depend on it as an input for your own flakes.

I will not be providing a `shell.nix` or other "legacy" Nix provisions.
If you'd like them, please feel free to open a pull request with the changes.

## Usage

### Configuration
Copy swish.conf and style.css to your working directory
and edit them to fit your needs.

### Running swish

Run from your working directory:
```console
$ sw.ish /path/to/site
```

Where 'site' is the folder where your website is located.
The static version of the website is created under 'out'.

## Credits

Swish is a fork of sw - the suckless webframework.
My thanks to the original authors for a good base for hacking.

### Original Author 

* Nibble <develsec.org> 

### Contributors to sw

* pancake <nopcode.org>
* Andrew Antle
