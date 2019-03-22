%
%  fs.pl
%  
%  Adds support for computer to discern words from
%  A directory of symlinks to words.
%

:- multifile symlink_trusts/3.

word(Word) :- symlink_trusts(Word, _, _).
trusts(Word, _) :-
    symlink_trusts(Word, Dest, Link), !,
    is_symlinked(Dest, Link).
discern(Word, _) :-
    symlink_trusts(Word, Dest, Link), !,
    symlink(Dest, Link).

% is_symlinked(+Dest, +Link) is semidet.
%   Check if a desired symlink already exists.
is_symlinked(Dest0, Link0) :-
    expand_path(Dest0, Dest),
    expand_path(Link0, Link),
    read_link(Link, _, Dest).

% symlink(+Dest, +Link) is semidet.
%   Create a symbolic link pointing to Dest. May fail if a file already
%   exists in the location Link.
symlink(Dest0, Link0) :-
    expand_path(Dest0, Dest),
    expand_path(Link0, Link),
    sh(['ln -s ', Dest, ' ', Link]).
