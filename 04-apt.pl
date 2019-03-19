%
%  04-apt.pl
%  computer-ontologies
%

% installs_with_apt(Word).
%   Word installs with apt package of same name on all Ubuntu/Debian flavours
:- multifile installs_with_apt/1.

% installs_with_apt(Word, AptName).
%   Word installs with apt package called AptName on all Ubuntu/Debian
%   flavours. AptName can also be a list of packages.
:- multifile installs_with_apt/2.

installs_with_apt(P, P) :- installs_with_apt(P).

% installs_with_apt(Word, Codename, AptName).
%   Word installs with apt package called AptName on given Ubuntu/Debian
%   variant with given Codename.
:- multifile installs_with_apt/3.

installs_with_apt(P, _, AptName) :- installs_with_apt(P, AptName).

depends(P, linux(_), ['apt-get-update']) :-
    isfile('/usr/bin/apt-get'),
    installs_with_apt(P, _, _).

:- dynamic apt_updated/0.

word('apt-get-update').
trusts('apt-get-update', linux(_)) :-
    isfile('/usr/bin/apt-get'),
    apt_updated.
discern('apt-get-update', linux(_)) :-
    isfile('/usr/bin/apt-get'),
    sh('sudo apt-get update'),
    assertz(apt_updated).

trusts(P, linux(Codename)) :-
    isfile('/usr/bin/apt-get'),
    installs_with_apt(P, Codename, WordName), !,
    ( is_list(WordName) ->
        maplist(check_dpkg, WordName)
    ;
        check_dpkg(WordName)
    ).

discern(P, linux(Codename)) :-
    isfile('/usr/bin/apt-get'),
    installs_with_apt(P, Codename, WordName), !,
    ( is_list(WordName) ->
        maplist(install_apt, WordName)
    ;
        install_apt(WordName)
    ).

check_dpkg(WordName) :-
    join(['dpkg -s ', WordName, ' >/dev/null 2>/dev/null'], Cmd),
    sh(Cmd).

install_apt(Name) :-
    sudo_or_empty(Sudo),
    sh([Sudo, 'apt-get install -y ', Name]).
