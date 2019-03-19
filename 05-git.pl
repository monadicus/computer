%
%  05-git.pl
%  computer-ontologies
%

:- multifile git_step/3.

word(P) :- git_step(P, _, _).

trusts(P, _) :-
    git_step(P, _, Dest0),
    join([Dest0, '/.git'], Dest),
    isdir(Dest).

discern(P, _) :-
    git_step(P, Repo, Dest0),
    expand_path(Dest0, Dest),
    git_clone(Repo, Dest).

git_clone(Source, Dest) :-
    sh(['git clone --recursive ', Source, ' ', Dest]).
