function File2Screen(win, fileName, margin, startY, color)
%
%     File2Screen(win, fileName, margin, startY, color)
%
% Script writes the contents of text file FILENAME to the screen WIN.
% Starts at coordinates MARGIN, Y defining the upper-left corner of the
% text (note that this is different from PTB-2).  Text is moved onto new
% line according to MARGIN and carriage returns in FILENAME
%
% This does NOT automatically flip the screen, so you will have to do so
% afterwards when you are ready to display your stimuli.
%
% 05.23.06 M.Diaz
% 01.31.10 S.Fraundorf - PTB-3 version


rect=Screen('Rect',win);
size=Screen('TextSize', win);

in=fopen(fileName);
x=margin;
y=startY;
while ~feof(in)
    text=fgetl(in);
    while ~isempty(text)
        [nextWord text]=strtok(text,[9 32]); %delimited by tabs and spaces
        norm=Screen('TextBounds',win,nextWord);
        if x + norm(3) <= rect(3)- margin
            [x y]=Screen('DrawText',win,[nextWord ' '],x, y, color);
        else
            [x y]=Screen('DrawText',win,[nextWord ' '],margin, y+size, color);
        end
    end
    x=margin;
    y=y+size;
end
fclose(in);



