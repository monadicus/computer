%
%  discern.pl
%  
%  Create a list of words for an ontology.
%

% discern_word(SpecificWord, Context, Words).
%   In a specific Context, you can set up a discerned SpecificWord by 
%   discerning Words.
:- multifile discern_word/3.


% discern_word(DiscernedWord, Words).
%   On any context, you can set up Name by discerning Words.
:- multifile discern_word/2.

discern_word(SpecificWord, _, Words) :- discern_word(SpecificWord, Words).


word(Word) :- discern_word(Word, _, _).

discern(SpecificWord, Context) :- discern_word(SpecificWord, Context, Words), !,
    maplist(cached_trust, Words).

discern(SpecificWord, Context) :- discern_word(SpecificWord, Context, _), !.

supports(SpecificWord, Context, Words) :- discern_word(SpecificWord, Context, Words).
