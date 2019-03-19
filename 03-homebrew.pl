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

installs_with_brew(W, W) :- installs_with_brew(W).
installs_with_brew(W, N, '') :- installs_with_brew(W, N).

supports(W, osx, [brew, 'brew-update']) :- installs_with_brew(W, _).

:- dynamic brew_updated/0.

word('brew-update').
trusts('brew-update', osx) :- brew_updated.
discern('brew-update', osx) :-
    sh('brew update'),
    assertz(brew_updated).

trusts(W, osx) :-
    installs_with_brew(W, WordName, _), !,
    join(['/usr/local/Cellar/', WordName], Dir),
    isdir(Dir).

discern(W, osx) :-
    installs_with_brew(W, WordName, Options), !,
    install_brew(WordName, Options).

install_brew(Name, Options) :-
    sh(['brew install ', Name, ' ', Options]).

% brew_tap(W, TapName).
%   An extra set of Homebrew packages.
:- multifile brew_tap/2.

% taps are targets
word(W) :- brew_tap(W, _).

trusts(W, osx) :-
    brew_tap(W, TapName), !,
    join(['/usr/local/Library/Taps/', TapName], Path),
    isdir(Path).

discern(W, osx) :-
    brew_tap(W, TapName), !,
    sh(['brew tap ', TapName]).


brew_tap('brew-cask-tap', 'caskroom/homebrew-cask').
word('brew-cask').
supports('brew-cask', osx, ['brew-cask-tap']).
installs_with_brew('brew-cask').

word('brew-cask-configured').
supports('brew-cask-configured', osx, ['brew-cask']).
trusts('brew-cask-configured', osx) :- isdir('/opt/homebrew-cask/Caskroom').
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

cask_word(W, W) :- cask_word(W).
word(W) :- cask_word(W, _).
installs_with_brew_cask(W, BrewName) :- cask_word(W, BrewName).
installs_with_brew_cask(W, W) :- installs_with_brew_cask(W).
installs_with_brew_cask(W, N, '') :- installs_with_brew_cask(W, N).
supports(W, osx, ['brew-cask-configured', 'brew-update']) :- cask_word(W, _).

trusts(W, osx) :-
    installs_with_brew_cask(W, WordName, _), !,
    join(['/opt/homebrew-cask/Caskroom/', WordName], Dir),
    isdir(Dir).

discern(W, osx) :-
    installs_with_brew_cask(W, WordName, Options), !,
    install_brew_cask(WordName, Options).

install_brew_cask(Name, Options) :-
    sh(['brew cask install ', Name, ' ', Options]).
