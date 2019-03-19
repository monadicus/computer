%
%  06-meta.pl
%  computer-ontologies
%

% meta_word(Name, Context, Words).
%   In a specific Context, you can set up Name by discerning Words.
:- multifile meta_word/3.


% meta_word(Name, Words).
%   On any context, you can set up Name by discerning Words.
:- multifile meta_word/2.

meta_word(W, _, Words) :- meta_word(W, Words).


word(W) :- meta_word(W, _, _).

discern(W, Context) :- meta_word(W, Context, Words), !,
    maplist(cached_trust, Words).

discern(W, Context) :- meta_word(W, Context, _), !.

supports(W, Context, Words) :- meta_word(W, Context, Words).
