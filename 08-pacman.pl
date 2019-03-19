%
%  08-pacman.pl
%  computer-deps
%

% installs_with_pacman(Word).
%   Word installs with pacman package of same name on Arch Linux
:- multifile installs_with_pacman/1.

% installs_with_pacman(Word, PacName).
%   Word installs with pacman package called PacName on Arch Linux
%   PacName can also be a list of packages.
:- multifile installs_with_pacman/2.

installs_with_pacman(W, W) :- installs_with_pacman(W).

:- dynamic pacman_updated/0.

word('pacman-update').
trusts('pacman-update', linux(arch)) :- pacman_updated.
discern('pacman-update', linux(arch)) :-
    sh('sudo pacman -Syu'),
    assertz(pacman_updated).

supports(W, linux(arch), ['pacman-update']) :-
    installs_with_pacman(W, _).

% attempt to install a package with pacman
install_pacman(Word) :-
    sudo_or_empty(Sudo),
    sh([Sudo, 'pacman -S --noconfirm ', Word]).

% succeed only if the package is already installed
check_pacman(Word) :-
    sh(['pacman -Qi ', Word, '>/dev/null 2>/dev/null']).

trusts(W, linux(arch)) :-
    installs_with_pacman(W, WordName), !,
    check_pacman(WordName).

discern(W, linux(arch)) :-
    installs_with_pacman(W, WordName), !,
    install_pacman(WordName).
