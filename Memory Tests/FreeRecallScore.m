% FreeRecallScore(delimiter)
%
% Does guided scoring of free recall data -- e.g., from the freerecall
% function in this toolbox.  Subject responses are entered in a CSV text
% file, one on each line (note: the file MUST have the extension .csv).
% These responses are compared against a pre-defined CSV of target items,
% and a final file is produced indicating which items the subject did or
% did not recall.
%
% When subject response does not match anything in the list of targets,
% the program prompts the user to decide to how to score it.
% 
% Optionally, the CSV of TARGETS may also contain a second column that
% specifies the condition each item was in.  If different items are in
% different conditions across lists, you will need to run this program
% once for each list.
%
% If the CSV of subject responses contains RT (as produced by freerecall.m)
% those are also retained in the final file.
%
% Optional parameter DELIMITER specifies the column delimiter in the files;
% assumed to be a comma if nothing is specified.
%
% This could be handled to be even more versatile with the type of target
% and response files it handles.
%
% 10.22.09 S.Fraundorf - first version
% 11.23.09 S.Fraundorf - genericized this so it works on more than just my
%                           data
% 11.26.09 S.Fraundorf - added DELIMITER parameter and ability to reproduce
%                          the RTs defined in freerecall.m

function FreeRecallScore(delimiter)

%% ASSIGN A DELIMITER IF NONE SPECIFIED
if nargin < 1
    delimiter = ','; % default is comma-delimited
end

%% GET PATHS FROM THE USER
fprintf('Please enter the path and filename of your list of TARGETS:\n');
listfilepath = inputstring('> ');

fprintf('Please enter the folder and file prefix for your raw data:\n(e.g. memorydata/recall if your files are memorydata/recall1.txt, memorydata/recall2.txt, etc.)\n');
memoryfilepath = inputstring('> ');

fprintf('Please enter list of subject numbers to score (e.g. 1-3,5):\n');
subjToScore = NaN;
while isnan(subjToScore)
    subjToScore = parseNumberList(inputstring('> '));
end

fprintf('Please enter the EXPORT path and filename:\n(e.g. memorydata/scored to save files as memorydata/scored1.txt, etc.\n');
exportpath = inputstring('> ');

%% LOAD UP THE LIST OF CORRECT ITEMS

% find out if the list has a list of conditions in it
infile = fopen(listfilepath);
testline = fgetl(infile);
if find(testline==delimiter,1)
   includecondition = 1;
   headerrow = 'SUBJECT,ITEM,CONDITION,';
else
   includecondition = 0;
   headerrow = 'SUBJECT,ITEM,';
end
fclose(infile);

% read the file fo' realz
infile = fopen(listfilepath);
if includecondition
  targetlist = textscan(infile,'%s%s','Delimiter',delimiter);
else
  targetlist = textscan(infile,'%s','Delimiter',delimiter);
end
fclose(infile);

%% EXAMINE THE RESPONSE FILES

% are there RTs included?
infile = fopen([memoryfilepath num2str(subjToScore(1)) '.csv']);
testline = fgetl(infile);
if find(testline==delimiter,1)
   includeRTs = 1;
   headerrow = [headerrow 'RECALLED,STARTRT,ENDRT'];
else
   includeRTs = 0;
   headerrow = [headerrow 'RECALLED'];
end
fclose(infile);

%% READ EACH SUBJECT'S TEST DATA

for subjno = subjToScore
    
    fprintf('\nScoring subject %d ...\n', subjno);
    
    % set all the words to 'not recalled'
    targetlist{3} = zeros(numel(targetlist{1}),1);
    % clear RTs
    targetlist{4} = repmat(-2,numel(targetlist{1}),1);
    targetlist{5} = repmat(-2,numel(targetlist{1}),1);
            
    % open the response file
    filename = [memoryfilepath num2str(subjno) '.csv'];
    memfile = fopen(filename);
        
    while ~feof(memfile)
       % get the next line
        nextline = fgetl(memfile);
        while strcmp(nextline,'WORD,START,END') || strcmp(nextline,'WORD')
            nextline = fgetl(memfile); % throw out the header row
        end
        
        % parse line
        if includeRTs
            responsedata = strtokMultiple(nextline,delimiter);
        else % line is JUST the word
            responsedata{1}{1} = {nextline};
        end
            
        % try to find a matching word in the list
        found = 0;
        while ~found
                
           % search the target list for this word
           for i=1:numel(targetlist{1})
               if strcmp(targetlist{1}{i}, stripPunctuation(responsedata{1}{1})) % compare
                 % match found
                 targetlist{3}(i) = 1; % set this word to found
                 if includeRTs && targetlist{4}(i) == -2
                     % update the RT information
                     % n.b. if the subject recalls the same word >1, the
                     % RTs for the FIRST recall are used
                    targetlist{4}(i) = str2double(responsedata{1}{2});
                    targetlist{5}(i) = str2double(responsedata{1}{3});
                 end
                 found = 1;
                 break; % done searching
                end
           end
            
           if ~found % still didn't find a match
                % prompt the user to score this
               fprintf('Subject #%d- response not found in master list: %s\n', subjno, responsedata{1}{1})
               fprintf('Enter word to score as, or ''none'' to not score\n')
               responsedata{1} = inputstring('> '); 
               if strcmp(responsedata{1}, 'none')
                   found = 1; % give up
               end
           end
       end % now, go back and look for THIS word (that the scorer just typed in)

    end  % done SCORING this subject
    
    % save the data to the output file
    outfile = fopen([exportpath num2str(subjno) '.csv'], 'w');
    % print the header row
    fprintf(outfile, '%s\n', headerrow); % defined above
    % save the recall data
    for i=1:numel(targetlist{1})
        fprintf(outfile,'%d,%s', subjno, targetlist{1}{i}); % subject # and item
        if includecondition
            fprintf(outfile,',%s',targetlist{2}{i}); % condition, IF defiend
        end
        fprintf(outfile,',%d', targetlist{3}(i)); % is recalled?
        if includeRTs
            fprintf(outfile,',%3.4f,%3.4f\n', targetlist{4}(i), targetlist{5}(i));
        else
            fprintf(outfile,'\n');
        end
    end
    fclose(outfile); % done saving
 
end % all done with this subject ... go on to the next one

fprintf('\nDone!\n');
clear all