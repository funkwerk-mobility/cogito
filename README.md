[![CI](https://github.com/funkwerk-mobility/cogito/workflows/CI/badge.svg)](https://github.com/funkwerk-mobility/cogito/actions?query=workflow%3ACI)
[![License](https://img.shields.io/badge/license-MPL_2.0-blue.svg)](https://raw.githubusercontent.com/funkwerk-mobility/mocked/master/LICENSE)

# cōgitō

cōgitō analyses D code and calculates its [cognitive complexity].

## Installing and usage

Run `make install build/release/bin/cogito`.

It will download and install the frontend and build a binary.
Then you can run it on some D source:

Run `./build/release/bin/cogito src/main.d`.

## Example output

```
module app: 5 (src/main.d)
accumulateResult: 5 (src/main.d:9)
accumulateResult.(λ): 0 (src/main.d:12)
accumulateResult.(λ): 2 (src/main.d:16)
(λ): 0 (src/main.d:33)
```

## Command line options

Property name | Allowed values | Description
-------------------|------------------|-----
--threshold | Positive numbers | Fail if the source score exceeds this threshold.
--aggregate-threshold | Positive numbers | Fail if an aggregate score exceeds this threshold.
--module-threshold | Positive numbers | Fail if a function score exceeds this threshold.
--format | `flat`, `verbose`, `debug` and `silent` | See below.
--config | string | Configuration file.
--help | – | Show a help message.

## Formats

Flat format outputs only the functions violating a limit. If no limits
are set, it prints all functions with their source file name and line
number.

Verbose is the same as flat but it always prints all scores.

Debug output adds column numbers and scores inside aggregates.

Silent format produces no output, but returns an error if one of the
thresholds is exceeded.

## Configuration

A configuration file can be used to specify different scores for specific modules.
The configuration is a list of modules names in brackets with the corresponding
score, followed by symbol specifications in this module. For example:

```
[cogito.list = 123]
MyStruct = 12
MyStruct.f = 8

[cogito.meter = 32]
```

If an element doesn't exceed the normal score, but there is a configuration for
it, it also causes an error, because the configuration in this case should be removed.

The default configuration file is `cogito.conf`. Another file name can be
specified with `--config` command line option. Set `--config` to `-` to read
from the standard input.

## Return codes

The return code of the program provides some information on what kind of error
occurred.

- 0: Success
- 1: Command line arguments are invalid
- 2: Some source files contain errors
- 3: Function threshold violation
- 4: Aggregate threshold violation
- 5: Module threshold violation
- 6: Redundant threshold configuration found

[cognitive complexity]: https://sonarsource.com/docs/CognitiveComplexity.pdf
