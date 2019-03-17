#!/bin/bash -e
#
#  bootstrap_dev.sh
#
#  Install computer for the current user only.
#

function has_exec() {
  [ ! -z "$(which $1)" ]
}

function missing_exec() {
  [ -z "$(which $1)" ]
}

is_apt_updated=0
function apt_update() {
  if [ $is_apt_updated -eq 0 ]; then
    sudo apt-get update
    is_apt_updated=1
  fi
}

is_brew_updated=0
function brew_update() {
  if [ $is_brew_updated -eq 0 ]; then
    brew update
    is_brew_updated=1
  fi
}

function install_git() {
  echo 'Trying to install git'
  case $(uname -s) in
    Darwin)
      if has_exec brew; then
        brew_update
        brew install git
      else
        bail "Please install Homebrew and retry"
      fi
      ;;
    Linux)
      if has_exec apt-get; then
        apt_update
        sudo apt-get install -y git
      elif has_exec yum; then
        # XXX yum update?
        sudo yum install git
      else
        bail "Unknown linux variant"
      fi
      ;;
    FreeBSD)
      if has_exec pkg; then
        sudo pkg install -y git
      else
        bail "Old FreeBSD version without pkgng"
      fi
      ;;
    *)
      bail "Unknown operating system $(uname -s)"
      ;;
  esac
}

function install_prolog() {
  echo 'Trying to install prolog'
  case $(uname -s) in
    Darwin)
      if has_exec brew; then
        brew_update
        brew install swi-prolog
      else
        bail "Please install Homebrew and retry"
      fi
      ;;
    Linux)
      if has_exec apt-get; then
        apt_update
        sudo apt-get install -y swi-prolog-nox
      elif has_exec yum; then
        sudo yum install swi-prolog
      else
        bail "Unknown linux variant"
      fi
      ;;
    FreeBSD)
      if has_exec pkg; then
        sudo pkg install -y swi-pl
      else
        bail "Old FreeBSD version without pkgng"
      fi
      ;;
    *)
      bail "Unknown operating system $(uname -s)"
      ;;
  esac
}

function bail()
{
  echo "$1 -- bailing"
  exit 1
}

function check_in_path() {
  echo $PATH | tr ':' '\n' | grep -x -c "$1";
}


function checkout_computer() {
  echo 'Trying to check out computer'
  mkdir -p ~/.computer/bin
  git clone https://github.com/monadicus/computer ~/.computer/computer
  cat >~/.computer/bin/computer <<EOF
#!/bin/sh
exec swipl -q -t main -s ~/.computer/computer/computer.pl "\$@"
EOF
  chmod a+x ~/.computer/bin/computer
  if [ ! -d ~/.computer/computer -o ! -x ~/.computer/bin/computer ]; then
    bail "Ran into a problem checking out computer"
  fi
}

function put_computer_in_path() {
  echo 'Checking if computer is in PATH'
  if [ -f ~/.bash_profile ]; then
    echo 'export PATH=~/.computer/bin:$PATH' >>~/.bash_profile
    source ~/.bash_profile
  elif [ -f ~/.profile ]; then
    echo 'export PATH=~/.computer/bin:$PATH' >>~/.profile
    source ~/.profile
  fi
  if missing_exec computer; then
    bail "Couldn't set up computer in PATH. Add ~/.computer/bin to your PATH in your shell's rc."
  fi
}

function main() {
  echo 'BOOTSTRAPPING COMPUTER'

  if missing_exec git; then
    install_git
  fi
  echo 'Git: OK'

  if missing_exec swipl; then
    install_prolog
  fi
  echo 'Prolog: OK'

  if [ ! -d ~/.computer/computer ]; then
    checkout_computer
  fi
  echo 'Computer: OK'

  hash -r
  if missing_exec computer; then
    put_computer_in_path
  fi
  echo 'Computer in PATH: OK'
  echo 'DONE'
}

main
