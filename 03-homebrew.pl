%
%  03-homebrew.pl
%  computer-deps
%
%  Helpers for working with Homebrew.
%  http://mxcl.github.io/homebrew/
%

command_word(brew).

discern(brew, osx) :-
    sh('ruby -e "$(curl -fsSL https://raw.github.com/mxcl/homebrew/go)"').

% installs_with_brew(Word).
%  Word installs with homebrew package of same name.
:- multifile installs_with_brew/1.

% installs_with_brew(Word, BrewName).
%  Word installs with homebrew package called BrewName.
:- multifile installs_with_brew/2.

% installs_with_brew(Word, BrewName, Options).
%  Word installs with homebrew package called BrewName and with Options.
:- multifile installs_with_brew/3.

installs_with_brew(P, P) :- installs_with_brew(P).
installs_with_brew(P, N, '') :- installs_with_brew(P, N).

depends(P, osx, [brew, 'brew-update']) :- installs_with_brew(P, _).

:- dynamic brew_updated/0.

word('brew-update').
trusts('brew-update', osx) :- brew_updated.
discern('brew-update', osx) :-
    sh('brew update'),
    assertz(brew_updated).

word(P, osx) :-
    installs_with_brew(P, WordName, _), !,
    join(['/usr/local/Cellar/', WordName], Dir),
    isdir(Dir).

discern(P, osx) :-
    installs_with_brew(P, WordName, Options), !,
    install_brew(WordName, Options).

install_brew(Name, Options) :-
    sh(['brew install ', Name, ' ', Options]).

% brew_tap(P, TapName).
%   An extra set of Homebrew packages.
:- multifile brew_tap/2.

% taps are targets
word(P) :- brew_tap(P, _).

word(P, osx) :-
    brew_tap(P, TapName), !,
    join(['/usr/local/Library/Taps/', TapName], Path),
    isdir(Path).

discern(P, osx) :-
    brew_tap(P, TapName), !,
    sh(['brew tap ', TapName]).


brew_tap('brew-cask-tap', 'caskroom/homebrew-cask').
word('brew-cask').
depends('brew-cask', osx, ['brew-cask-tap']).
installs_with_brew('brew-cask').

word('brew-cask-configured').
depends('brew-cask-configured', osx, ['brew-cask']).
word('brew-cask-configured', osx) :- isdir('/opt/homebrew-cask/Caskroom').
discern('brew-cask-configured', osx) :- sh('brew cask').

% installs_with_brew_cask(Word).
%  Word installs with homebrew-cask package of same name.
:- multifile installs_with_brew_cask/1.

% installs_with_brew_cask(Word, BrewName).
%  Word installs with homebrew-cask package called BrewName.
:- multifile installs_with_brew_cask/2.

% installs_with_brew_cask(Word, BrewName, Options).
%  Word installs with homebrew-cask package called BrewName and with Options.
:- multifile installs_with_brew_cask/3.

:- multifile cask_word/1.

:- multifile cask_word/2.

cask_word(P, P) :- cask_word(P).
word(P) :- cask_word(P, _).
installs_with_brew_cask(P, BrewName) :- cask_word(P, BrewName).
installs_with_brew_cask(P, P) :- installs_with_brew_cask(P).
installs_with_brew_cask(P, N, '') :- installs_with_brew_cask(P, N).
depends(P, osx, ['brew-cask-configured', 'brew-update']) :- cask_word(P, _).

word(P, osx) :-
    installs_with_brew_cask(P, WordName, _), !,
    join(['/opt/homebrew-cask/Caskroom/', WordName], Dir),
    isdir(Dir).

discern(P, osx) :-
    installs_with_brew_cask(P, WordName, Options), !,
    install_brew_cask(WordName, Options).

install_brew_cask(Name, Options) :-
    sh(['brew cask install ', Name, ' ', Options]).
