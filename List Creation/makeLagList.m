% makeLagList
%
% Creates a presentation order list for a experiment with items are
% repeated twice at a variety of lags.  Optionally, you can also include
% some non-repeated items; these items are identified by having a lag of
% "0" in the completed list.
%
% According to Aaron Benjamin, creating a list like this is NP-hard.  This
% script attempts to just brute-force it through repeated random attempts.
% There is no guarantee it will succeed.
%
% If you don't like the list you get, running the script again will
% probably give you a different one.
%
% One tip for this type of design (from Jonathan Tullis) is to create a
% list that only represents, say, 1/4 of your total items.  Then
% concatenate together 4 copies of the list to form your final list.  This
% ensures that the lag conditions will be roughly equal in their average
% distance to the final test.  EXACTLY equating this distance is really
% hard if not impossible.
%
%  9.30.09 - S.Fraundorf - based off some code by Mike Diaz
% 11.23.09 - S.Fraundorf - prompt user for info so you don't have to edit
%                           the MATLAB fxn
% 10.15.10 - S.Fraundorf - don't write the file if attempt to create the
%                           list was unsuccessful.  display updates if
%                           working on a large # of fit attempts.

%% FIXED PARAMETERS
maxfails=300;  %number of list making attempts before abort
%
% You can increase this parameter if you want.  The script will try longer
% to find a solution.

%% USER ENTRY
lags = NaN;
while isnan(lags)
    lags = parseNumberList(inputstring('Enter a LIST OF LAGS, separated by commas (e.g. 1,2,4): '));
end
nStudyItems = inputnumber('Enter number of items PER LAG CONDITION: ');
nNoRepeat = inputnumber('Enter number of NON-REPEATED items (may be 0): ');
outputfilename = inputstring('Enter filename for completed list: ');

%% SET UP THE LIST
listLen=nNoRepeat+2*numel(lags)*nStudyItems;

if listLen < max(lags)+nStudyItems
    error('need more distractors')
end

firstNoRepeat= (numel(lags)*nStudyItems)+1; % item ID of first non-repeated item

%% SET UP LIST MATRIX
ITEMID = 1; % column index for Item ID
PRESNO = 2; % column index for Pres No
LAGCOND = 3; % column index for Lag Condition

%% SEED RANDOM # GENERATOR
rand('state',sum(100*clock)); 

%% ASSEMBLE LIST

%fit lags in the list from largest to smallest
lags=sort(lags);
lags=lags(end:-1:1); 

numfails = 0;
done = 0;

while ~done
    finalList = zeros(listLen,3); % list matrix
    openSpots=1:listLen;
    fail=0;
    
    if mod(numfails,1000) == 0  % if using a large # of fit attempts, update the user periodically
                                % on the progress
        fprintf('Attempt #%d...\n', numfails+1);
    end

    nextItemID = 1; % each list attempt starts with item 1

    for lag=lags % start with longest lag
        for repeat=1:nStudyItems % assign all items w/in this lag
            options=openSpots;
            for a=1:numel(openSpots) % check the open spots to see if they are usable
                if isempty(find(openSpots==openSpots(a)+lag, 1)) %if the second presentation is not open for this lag, don't consider it an option
                    options(options==openSpots(a))=[]; %delete option
                end
            end
            
            if isempty(options) % this attempt to create a list has failed, start over
                fail=1;
                numfails = numfails + 1; % abort if too many fails
                break
            else
               % at least one option, so pick randomly from them
               choice=options(floor(rand(1)*numel(options)+1));
            
               % save the trial data and advance the Item ID counter
              finalList(choice,1:3)     = [nextItemID,1,lag]; % presentation 1
              finalList(choice+lag,1:3) = [nextItemID,2,lag]; % presentation 2
              nextItemID = nextItemID + 1;

              % remove these slots from the list of open spots
              openSpots(openSpots==choice)=[];
              openSpots(openSpots==choice+lag)=[];
            end
        end
        if fail % once one fail has been encountered, give up and start over
            break
        end
    end
    
    % check the result of this attempt
    if ~fail % no failures encountered, list is done!
        
        % add the non-repeated items
        nextItemID = firstNoRepeat;
        for a=1:size(finalList,1)
            if finalList(a,1) == 0
                finalList(a,1:3)=[nextItemID,1,0]; % non-repeated item
                nextItemID = nextItemID+1;
            end
        end
        
        fprintf('Successfully created list; now saving.\n')
        done=1;
    elseif numfails > maxfails
        fprintf('Maximum failures reached.\n')
        done=1; % abort if too many failures so we don't get stuck in a loop
    end
end

%% SAVE THE COMPLETED LIST
% 
if ~fail
  % open the file
  outputfile = fopen(outputfilename, 'w');
  fprintf(outputfile, 'ITEMID,PRESENTATION,LAG\n');

  for i=1:size(finalList,1)
       
   % export file
   fprintf(outputfile,'%2.0f,%2.0f,%2.0f', finalList(i,1), finalList(i,2), finalList(i,3));
   if i < size(finalList,1)
     fprintf(outputfile,'\n');
   end
  end 
  
  fclose(outputfile);
end

fprintf('Done!\n');
fclose(outputfile);