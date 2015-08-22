function [x y]=WriteLineHighlight(win, text, color, margin, x, y, highlightwords, highlightcolor, linespacing)
%
%      [newx, newy]=WriteLineHighlight(win, text, color, margin, x, y, highlightwords, highlightcolor, linespacing)
%
% --This function is now subsumed within WriteLine, so you can just use
%   that.  It's preserved here merely for compatibility with experiment
%   scripts that call WriteLineHighlight.--
%
% function writes a string TEXT to position x,y on screen WIN in color
% COLOR starting at the current cursor position.  If TEXT goes beyond the
% margin MARGIN, words wrapped onto next line.  Words are delimited by
% spaces, tabs and carriage returns.  Paragraphs are delimited by | (pipe)
%
% HIGHLIGHTWORDS is a single string or a cell array of words that will be
% written in color HIGHLIGHTCOLOR.  If no words or highlight color is specified,
% then no words will be highlighted.  (N.B. punctuation marks are ignored,
% but capitalization is NOT.)
%
% LINESPACING specifies the spacing between lines relative to the
% height of the text.  The default is 1 (1:1 ratio).
%
% 07.12.07 - S.Fraundorf - created based on M.Diaz's WriteLine
% 11.22.09 - S.Fraundorf - added support for multiple paragraphs
% 01.30.10 - S.Fraundorf - PTB-3 version
% 09.13.10 - S.Fraundorf - won't crash if long blank spaces. 
%                          minor updates to be more PTB3-like
% 08.23.12 - S.Fraundorf - now just calls WriteLine

WriteLine(win, text, color, margin, x, y, linespacing, highlightcolor, highlightwords)