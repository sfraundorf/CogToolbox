%
%      [newx, newy, textend]=WriteLine(win, text, color, margin, x, y, linespacing, highlightcolor, highlightwords, yPositionIsBaseline)
%
% function writes a string TEXT to position x,y on screen WIN in color
% COLOR starting at the current cursor position.  If TEXT goes beyond the
% margin MARGIN, words wrapped onto next line.
%
% Words are delimited by spaces, tabs and carriage returns.  Paragraphs
% (with a blank line in between) are delimited by | (pipe). 
%
% x, y are the upper-left corner of the text box (note that this is
% DIFFERENT from PTB-2)
%
% LINESPACING specifies the spacing between lines relative to the
% height of the text.  The default is 1 (1:1 ratio).
%
% Note that this function does NOT automatically flip the screen, so you
% will have to do that afterwards when you are ready to display what you've
% drawn.
%
% Text may be modified by a limited number of markup codes, e.g.
%    'The <bold>Scottish knight</bold> won the tournament'
% puts 'Scottish knight' in boldface
%
% Recognized markup codes:
%   Line break - <br>
%     --> start a new line without a paragraph break (blank line) in between
%   Color - <color> or <highlight>
%     --> this changes the text color to the code specified in HIGHLIGHTCOLOR
%         default is bright red (RGB: #ff0000) if no other color specified
%     --> right now, the highlight color must be the same throughout a block
%         of text.  sorry :(
%     --> additionally, any words in cell array HIGHLIGHTWORDS are also
%         highlighted in the same color
%   Boldface - <b>, <bold>, or <strong>
%   Italics  - <i>, <ital>, <em>, <italic>, or <italics>
%   Underline - <u>, <un>, <under>, or <underline>
%   Outline (Mac only) - <out> or <outline>
%   Condensed (Mac only) - <con>, <condense>, or <condensed>
%   Expanded (Mac only) - <ex>, <extend>, or <extended>
%   All Caps - <caps>, <upper>
%
% Returns the new X and Y coordinates after the text is finshed writing.
% Optionally, also returns TEXTEND, a vector of coordinates where the text
% itself ended (e.g. before any spaces or newline characters are added).
%
% 05.18.06 M.Diaz
% 07.16.07 S.Fraundorf - added linespacing parameter
% 11.22.09 S.Fraundorf - allowed use of | to delimit paragraphs
% 01.25.10 S.Fraundorf - PTB-3 version
% 01.31.10 S.Fraundorf - changed so that new paragraphs start back at the
%                          original X rather than margin.  this allows the
%                          use of consistent tab-indented paragraphs
% 02.01.10 S.Fraundorf - changed so that it won't crash if no text
% 09.13.10 S.Fraundorf - won't crash if long blank spaces. 
% 11.18.10 S.Fraundorf - added support for markup codes!  improved
%                          efficiency of paragraph segmentation
% 01.07.11 S.Fraundorf - added <br> tag
% 01.24.11 S.Fraundorf - text now starts at MARGIN rather than X after a
%                          <br>, just as with a soft linewrap
% 07.05.11 S.Fraundorf - further updates to deal with cases where the
%                          function is called w/ no text to display
% 09.21.11 S.Fraundorf - fixed a bug causing freezes when markup codes were
%                          in caps
% 02.08.12 S.Fraundorf - when no text to write, textend is still set (as
%                          the location you started off with)
% 08.23.12 S.Fraundorf - added ability to specify a cell array of words to
%                          highlight, as per the old WriteLineHighlight
% 08.24.12 S.Fraundorf - fixed a bug where, if no highlighted words were
%                          requested, punctuation marks would be
%                          highlighted.
% 11.04.16 S.Fraundorf - added ability to set yPositionIsBaseline - needed
%                          to display text properly on some systems

function [x, y, textend]=WriteLine(win, text, color, margin, x, y, linespacing, highlightcolor, highlightwords, yPositionIsBaseline)

delimiters = [9 10 13 32];

% default parameters
if nargin < 10       
    % get the default if not specified
    yPositionIsBaseline = Screen('Preference', 'DefaultTextYPositionIsBaseline');    
    if nargin < 9  
        highlightwords = {};
        if nargin < 8
            highlightcolor = [255 0 0]; % bright red            
        end     
    end
end 

% do any highlighting?
if nargin < 9 || isempty(highlightwords) 
    usehighlight = false;
else
    usehighlight = true;
    % if a single word to highlight, convert to cell array
    if ischar(highlightwords)
        highlightwords = {highlightwords};
    end      
end

% default line spacing
if nargin < 7 || isempty(linespacing)
    linespacing = 1;
end

% get screen & text parameters
rect=Screen('Rect',win);
size=Screen('TextSize',win);
style=Screen('TextStyle',win);
xstart = x;
ystart = y;

% divide text into paragraphs
if isempty(text)
    textend = [xstart ystart];
    return;
end
paragraphs = textscan(text,'%s','Delimiter','|');
if isempty(paragraphs) % nothing to write
    textend = [xstart ystart];
    return;
end
paragraphs = paragraphs{1};

% initialize font settings
curcolor = color;
caps = false;

% write the paragraphs
for i=1:numel(paragraphs)
    
    while ~isempty(paragraphs{i}) % write this whole paragraph
      [nextWord paragraphs{i}]=strtok(paragraphs{i},delimiters); %delimited by tabs, spaces and returns
      
      % look for any markup tags
      markupcodes = [];
      code = 0;
      while ~isempty(find(nextWord=='<',1)) && ~isempty(find(nextWord== '>',1))   
          code = code + 1; % add to # of markupcode finds          
          codeposn = find(nextWord=='<',1);
          markupcodes{code} = analyzeMarkupCode(nextWord,codeposn);
          
          % apply markup OPENING tags
          switch lower(markupcodes{code})
              case {'<color>', '<highlight>'}
                  % colored text
                  curcolor = highlightcolor;
              case {'<b>', '<strong>', '<bold>'}
                  % bold
                  style = style + 1;
                  Screen('TextStyle',win,style);
              case {'<i>', '<em>', '<ital>', '<italic>', '<italics>'}
                  % italics
                  style = style + 2;
                  Screen('TextStyle',win,style);
              case {'<u>', '<un>', '<under>', '<underline>'}
                  % underline
                  style = style + 4;
                  Screen('TextStyle',win,style);
              case {'<out>', '<outline>'}
                  % outline
                  style = style + 8;
                  Screen('TextStyle',win,style);
              case {'<con>', '<condense>', '<condensed>'}
                  % condense
                  style = style + 16;
                  Screen('TextStyle',win,style);
              case {'<ex>', '<extend>', '<extended>'}
                  % extended
                  style = style + 32;
                  Screen('TextStyle',win,style);
              case {'<upper>', '<caps>'}
                  % caps
                  caps = true;
          end          
          
          % remove the markup code from the word
          nextWord = stripString(nextWord, markupcodes{code});
      end
      
      if any(~ismember(nextWord,delimiters)) % at least 1 non-blank character here
          if caps
              nextWord = upper(nextWord);
          end
          norm = Screen('TextBounds',win,nextWord);
          textend = [x+norm(3) y]; % ending location of the TEXT ITSELF, before any spaces/newlines
          % determine the color for this word
          if usehighlight && matchesInStringSet(stripPunctuation(nextWord),highlightwords,1) % see if this matches in the highlight set
             writecolor = highlightcolor; % use the special highlighting color
          else
             writecolor = curcolor; % use the regular color
          end
          % draw the text
          if textend(1) <= rect(3)- margin
            [x, y]=Screen('DrawText',win,[nextWord ' '],x, y, writecolor, [], yPositionIsBaseline);
          else
            [x, y]=Screen('DrawText',win,[nextWord ' '],margin, y+floor(size*linespacing), writecolor, [], yPositionIsBaseline);
          end
      end
      
      % handle any CLOSING markup tags, AFTER the text is written
      for j=1:code
          switch lower(markupcodes{j})
              case {'</color>', '</highlight>'}
                  % color
                  curcolor = color;
              case {'</b>', '</strong>', '</bold>'}
                  % bold
                  style = style - 1;
                  Screen('TextStyle',win,style);
              case {'</i>', '</em>', '</ital>', '</italic>', '</italics>'}
                  % italics
                  style = style - 2;
                  Screen('TextStyle',win,style);
              case {'</u>', '</un>', '</under>', '</underline>'}
                  % underline
                  style = style - 4;
                  Screen('TextStyle',win,style);
              case {'</out>', '</outline>'}
                  % outline
                  style = style - 8;
                  Screen('TextStyle',win,style);
              case {'</con>', '</condense>', '</condensed>'}
                  % condense
                  style = style - 16;
                  Screen('TextStyle',win,style);
              case {'</ex>', '</extend>', '</extended>'}
                  % extended
                  style = style - 32;
                  Screen('TextStyle',win,style);
              case {'</upper>', '</caps>'}
                  % caps
                  caps = false;
              case {'<br>'}
                  % start a new line
                  y = y + floor(size*linespacing);
                  x = margin;
          end
      end
    end % end of paragraph
      
    % add a blank line before next paragraph, IF there is one
    if i < numel(paragraphs)
        y = y + floor(size*linespacing*2);
        x = xstart;
    end
    
end