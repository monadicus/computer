# Computer ("hopscotch")

[![Build Status](https://travis-ci.org/monadicus/computer.png)](https://travis-ci.org/monadicus/computer) [![Gitter](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/monadicus/computer)


Test-driven system administration in SWI-Prolog, in the style of [Babushka](https://github.com/benhoskings/babushka).

Computer uses [logic programming](https://en.wikipedia.org/wiki/Logic_programming) to describe system targets and rules by which these targets can be met. Prolog's built-in search mechanism makes writing and using these dependencies elegant. Anecdotally, writing deps for Computer has the feel of teaching it about types of packages, rather than the feel of writing package templates.

![Hopscotch for Seniors](https://raw.github.com/wiki/monadicus/computer/img/HopscotchForSeniors.jpg)

## Current status

Experimental but working.

## Features

Computer has some features common to other configuration management frameworks:

- Checking and meeting dependencies (preconditions)
- Testing whether a target installed correctly (post-conditions)
- Ability to use platform-dependent instructions

It also has some interesting differences:

- Can write checks (`met` predicates) without needing to say how to meet them (`meet` predicates)
- The dependencies of a target can vary by platform
- Succinct definition of new classes of packages using logical rules

## Installing computer

### Quickstart

Pick a bootstrap script from the options below. If you're not sure, choose the stable version.

Version | Bootstrap command
------- | -----------------
_0.1.0 (stable)_ | `bash -c "$(curl -fsSL https://raw.githubusercontent.com/monadicus/computer/versions/0.1.0/bootstrap.sh)"`
_master (dev)_ | `bash -c "$(curl -fsSL https://raw.githubusercontent.com/monadicus/computer/master/bootstrap.sh)"`

This will install computer for all users, putting the executable in `/usr/local/bin/computer`.

### Manual version

1. Get Prolog
    - On OS X, with Homebrew: `brew install swi-prolog`
    - On Ubuntu, with apt-get: `sudo apt-get install swi-prolog-nox`
    - On FreeBSD, with pkgng: `sudo pkg install swi-pl`
2. Get git
    - On OS X, with Homebrew: `brew install git`
    - On Ubuntu, with apt-get: `sudo apt-get install git`
    - On FreeBSD, with pkgng: `sudo pkg install git`
3. Clone and set up computer

```bash
# clone the repo
mkdir -p ~/.computer
git clone https://github.com/monadicus/computer ~/.computer/computer

# set up an executable in ~/.computer/bin
mkdir -p ~/.computer/bin
cat >~/.computer/bin/computer <<EOF
#!/bin/sh
exec swipl -q -t main -s ~/.computer/computer/computer.pl "\$@"
EOF
chmod a+x ~/.computer/bin/computer

# add ~/.computer/bin to your PATH
# (the exact commands depend on the shell you use)
echo 'export PATH=~/.computer/bin:$PATH' >>~/.profile
source ~/.profile
```

## Writing deps

Make a `computer-deps/` folder inside your project repo. Each package has two components, a `met/2` goal which checks if the dependency is met, and an `meet/2` goal with instructions on how to actually meet it if it's missing.

For example, suppose I want to write a dep for Python that works on recent Ubuntu flavours. I might write:

```prolog
% python is a target to meet
pkg(python).

% it's installed if it exists at /usr/bin/python
met(python, linux(_)) :- exists_file('/usr/bin/python').

% we can install by running apt-get in shell
meet(python, linux(_)) :-
    % could also use: install_apt('python-dev')
    sh('sudo apt-get install -y python-dev').
```

To install python on a machine, I'd now run `computer meet python`.

To install pip, I might write:

```prolog
pkg(pip).

% pip is installed if we can run it
met(pip, _) :- which(pip).

% on all flavours of linux, try to install the python-pip package
meet(pip, linux(_)) :- install_apt('python-pip').

% on all platforms, pip depends on python
depends(pip, _, [python]).
```
Note our our use of platform specifiers and the `_` wildcard in their place. To see your current platform as described by computer, run `computer platform`. Examples include: `osx`, `linux(precise)` and `linux(raring)`.

## Running deps

### See available deps

This runs every `met/2` statement that's valid for your platform.

`computer scan`

### Install something

This will run the `meet/2` clause for your package, provided a valid one exists for your current platform.

`computer meet python`

### See your platform

To find the right platform code to use in deps you're writing, run:

`computer platform`

It reports the code for the platform you're currently on.

## Where to put your deps

Like both Babushka and Babashka, Computer looks for deps in `~/.computer/deps` and in a folder called `computer-deps` in the current directory, if either exists. This allows you to set up a personal set of deps for your environment, as well as project-specific deps.

## Examples

See [computer-deps](https://github.com/monadicus/computer-deps) repo for working examples.

## Developing

Run `make test` to run the test suite.
