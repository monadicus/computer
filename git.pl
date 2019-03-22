%
%  git.pl
%  damons:  This should be changed to git_trusts/3.
:- multifile git_trusts/3.

word(Word) :- git_trusts(Word, _, _).

trusts(Word, _) :-
    git_trusts(Word, _, Dest0),
    join([Dest0, '/.git'], Dest),
    isdir(Dest).

discern(Word, _) :-
    git_trusts(Word, Repo, Dest0),
    expand_path(Dest0, Dest),
    git_clone(Repo, Dest).

git_clone(Source, Dest) :-
    sh(['git clone --recursive ', Source, ' ', Dest]).
