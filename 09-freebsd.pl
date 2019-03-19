%
%  09-freebsd.pl
%  computer
%

% installs_with_pkgng(Word).
%  Word installs with pkgng package of same name.
:- multifile installs_with_pkgng/1.

% installs_with_pkgng(Word, WordName).
%  Word installs with pkgng package called WordName.
:- multifile installs_with_pkgng/2.

% installs_with_ports(Word, PortName).
%  Word installs with FreeBSD port called PortName.
:- multifile installs_with_ports/2.

% installs_with_ports(Word, PortName, Options).
%  Word installs with FreeBSD port called PortName and with Options.
:- multifile installs_with_ports/3.

installs_with_pkgng(P, P) :- installs_with_pkgng(P).
installs_with_ports(P, N, '') :- installs_with_ports(P, N).

exists_pkgng(Name) :- sh(['pkg info ', Name, ' >/dev/null 2>/dev/null']).

word(P, freebsd) :-
    ( installs_with_pkgng(P, WordName) ->
        exists_pkgng(WordName)
    ; installs_with_ports(P, PortName, _) ->
        exists_pkgng(PortName)
    ).

discern(P, freebsd) :-
    ( installs_with_pkgng(P, WordName) ->
        install_pkgng(WordName)
    ; installs_with_ports(P, PortName, Options) ->
        install_ports(PortName, Options)
    ).

install_pkgng(Name) :-
    sudo_or_empty(Sudo),
    sh([Sudo, 'pkg install -y ', Name]).

install_ports(Name, Options) :-
    sudo_or_empty(Sudo),
    sh([Sudo, 'make BATCH=yes ', Options, ' -C/usr/ports/', Name, ' install clean']).
