# Tweezer [![Build Status](https://travis-ci.org/glittershark/tweezer.svg?branch=master)](https://travis-ci.org/glittershark/tweezer) [![Test Coverage](https://codeclimate.com/github/glittershark/tweezer/badges/coverage.svg)](https://codeclimate.com/github/glittershark/tweezer/coverage)

**Tweezer** is a CLI tool for editing your Gemfile that goes to great extents to
ensure the Gemfile remains both valid and idiomatic

Tweezer is currently usable, but should be considered a WIP in that it's
reasonably untested and might muck up your Gemfile in any number of nasty ways
(which is irrelevant if your Gemfile is in source control (and if it's not
what're you doing with your life)), and that it doesn't actually provide for the
use-case that I started writing it for yet.

## Installation

```sh
gem install tweezer
```

## Usage

For full documentation, run `tweezer help` and `tweezer help COMMAND`.

### Adding new gems - `tweezer add`
```sh
tweezer add rake # Adds rake to the end of the default group in your Gemfile

tweezer add rake '~> 0.9.6' # Adds rake ~> 0.9.6 to the end of the default group
                            # in your Gemfile

tweezer add rspec --group test # Adds rspec to the 'test' group in your gemfile.
                               # Tweezer will do this in a way that results in
                               # the most idiomatic possible Gemfile
```

### Changing attributes of existing gems - `tweezer alter`
```sh
tweezer alter rake -v '~> 10.4.2' # Changes rake in the gemfile to be pinned to
                                  # 10.4.2

tweezer alter rake -p '~/code/rake' # Changes rake in the gemfile to be
                                    # installed from `~/code/rake`
```

## Why?

[Gemrat][] exists and is pretty cool, but has two problems with it that prevent
it from serving my use-case:

1. It uses naïve string-manipulation to edit the Gemfile. **Tweezer**, by
   comparison, uses the [parser][] and [unparser][] gems to do an actual
   modification of the AST of your gemfile. 

2. Gemrat only really satisfies the use-case of "install and save to Gemfile",
   covered by tools like `npm install --save` for other languages. **Tweezer**,
   by comparison, either allows or will allow much more advanced modifications
   of the gemfile, including adding gems to groups, deleting groups, modifying
   versions, sources, etc. of gems, and more.

My original use-case was for local-development of a gem that was used by one of
my apps, which required rather frequently switching my gemfile between `gem
'mygem', '~> 1.0.0'` and `gem 'mygem', path: '/path/to/local/gem'`. I wanted to
automate that using a mapping in my editor, and here we are.

[Gemrat]: https://github.com/DruRly/gemrat
[parser]: https://github.com/whitequark/parser
[unparser]: https://github.com/mbj/unparser
