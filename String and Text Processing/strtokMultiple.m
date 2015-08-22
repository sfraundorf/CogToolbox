% tokenset = strtokMultiple(string,delimiter)
%
% Completely tokenizes string STRING, delimited by character DELIMITER,
% and returns each token as a separate element of a cell array.  (This is
% different from regular strtok, which only works on the FIRST instance.)
%
% 07.28.08 - S.Fraundorf
% 05.17.10 - S.Fraundorf - fixed this so it only returns one layer of cell
% array

function tokenset = strtokMultiple(string, delimiter)

  if numel(find(string == delimiter)) == 0 % doesn't have any of the delimiter
      tokenset = {string};
  else

    i = 1;
    while find(string == delimiter) % keep running strtok until we're done
        [tokenset{i} string] = strtok(string, delimiter);
        i = i+1;
    end
  end

end