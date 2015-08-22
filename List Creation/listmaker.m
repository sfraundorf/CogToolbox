% listmaker v. 2.1
%
% This program creates experimental lists, based on the number
% of factors and items specified by the user.  Filler trials may also be 
% included.  Optionally, you can specify the names of factor levels and of items.
%
% 08.xx.09 - S.Fraundorf - first version
% 11.03.09 - S.Fraundorf - fixed a bug when all of the factors had an even
%                            # of levels.  big thanks to Tuan for catching
%                            this.
% 11.24.09 - S.Fraundorf - added filler trials & ability to ensure that no
%                            trial type is immediately repeated.  also
%                            fixed some bugs with the nuisance factors.
% 11.25.09 - S.Fraundorf - ensured that every item ends up in every
%                            condition an equal # of times across lists.
%                            and added disclaimer at startup.

%% PART ZERO: SET UP
clear all
rand('twister',sum(100*clock)); % seed the random # generator
maxfails=30000; % max number of fails at randomization

fprintf('Welcome to listmaker!  This script is a tool for making experimental lists.\n\n');
fprintf('IMPORTANT NOTE: Although listmaker has been tested with a number of simple designs,\n');
fprintf('every experiment is different.  Before you run your experiment, you should check\n');
fprintf('over your output from listmaker to make sure it matches what you want and what you.\n');
fprintf('think you are getting.  listmaker is a tool; it is not a substitute for understanding\n');
fprintf('what is going on in your design.  I am not liable if you run an experiment with a bad\n');
fprintf('design.\n');
listmakerrunning = 1;
while listmakerrunning
  goahead = lower(inputstring('\nI understand the above and want to proceed (y/n)?: '));
  if strcmp(goahead,'n')
      listmakerrunning = 0; % quit
  elseif strcmp(goahead,'y')
% the rest of the program is ALL inside this elseif statement indicates
% they want to use the program

%% PART ONE: GET INFO. ABOUT FACTORS

fprintf('\n\n**PART ONE: Factor set up**\n');
    
% **** GET THE TOTAL NUMBER OF FACTORS ****

balfactors = 0;
nuifactors = 0;

while (balfactors + nuifactors < 1) % must have at least one factor!
  % number of balanced factors
  fprintf('How many balanced factors do you want?  These are factors\nyou want fully balanced as part of the design.\n');
  balfactors = inputnumber('Number of balanced factors: ');
  % number of nuisance factors
  fprintf('\nHow many nuisance factors do you want?  These factors are\npurely RANDOMIZED and not necessarily orthogonally\nmanipulated with items or with the other factors.\n');
  nuifactors = inputnumber('Number of nuisance factors: ');
end

nuifactor1 = balfactors + 1;
nuifactorlast = balfactors + nuifactors;
totalfactors = balfactors + nuifactors;
ISCRITICAL = totalfactors+1; % next column shows if this is filler or critical
FILLERCOND = totalfactors+2; % column for filler conditions
ITEMID = totalfactors+3; % last column is the item number

%% PART TWO: FACTOR LEVELS

fprintf('\n\n**PART TWO: Factor levels**\n');

% **** ASSIGN NAMES TO LEVELS? ****
while 1
    assignnames = lower(inputstring('Assign names to factor levels (y/n)?: '));
    if strcmp(assignnames, 'y');
        usenames = 1;
        break;
    elseif strcmp(assignnames, 'n');
        usenames = 0;
        break;
    end
end

% name & number of levels for each balanced factor
for i=1:balfactors
    fprintf('\n');
    
    % factor name
    textstring = ['Name of balanced factor ' num2str(i) ': '];
    balnames{i} = inputstring(textstring);
    
    % # of levels
    textstring = ['Enter number of levels for balanced factor ' balnames{i} ': '];
    ballevels(i) = inputnumber(textstring, 2);
    
    % level names, if used
    if usenames == 1
        for j=1:ballevels(i)
            textstring = ['Enter name of ' balnames{i} ' level ' num2str(j) ': '];
            levelnames{i,j} = inputstring(textstring);
        end
    end
    
end

% name & number of levels for each nuisance factor
for i=1:nuifactors
    fprintf('\n');
    
    % factor name
    textstring = ['Name of randomized factor ' num2str(i) ': '];
    nuinames{i} = inputstring(textstring);
    
    % # of levels
    textstring = ['Enter number of levels for nuisance factor ' nuinames{i} ': '];
    nuilevels(i) = inputnumber(textstring, 2);
    
    % level names, if used
    if usenames == 1
        for j=1:nuilevels(i) 
            textstring = ['Enter name of ' nuinames{i} ' level ' num2str(j) ': '];
            levelnames{i+balfactors,j} = inputstring(textstring);
        end
    end
end

%% PART THREE: NUMBER OF BLOCKS

fprintf('\n\n**PART THREE: Number of blocks**\n');

% **** GET NUMBER OF CELLS ****
fprintf('How many blocks of the list do you want to balance factors within?\n e.g. 2 for a complete design within each half\n');
numblocks = inputnumber('Number of blocks: ',1);

% **** FIGURE OUT HOW MANY CELLS PER BLOCK ****
if balfactors > 0  % number of lists needed to satisfy balance factors
    balcells = prod(ballevels);
else
    balcells = 1;
end

if nuifactors == 0 % number of lists needed to satisfy nuisance factors
    nuicells = 1;
else
    % since these are not fully crossed we only need enough cells to
    % include all of them without them being confounded
    nuicells = nuilevels(1);
    for i=2:nuifactors
      nuicells = lcm(nuicells,nuilevels(i)); % lcm only takes 2 arguments at a time
    end
end

numlists = lcm(balcells,nuicells);  % min. number of items we need IN ONE BLOCK
                                         % this is also the # of lists
itemsneeded = numlists * numblocks; % min. number of items we need FOR ALL BLOCKS
                                         % (same as numlists if design
                                         % isn't blocked)

%% PART FOUR: ITEM NAMES

fprintf('\n\n**PART FOUR: Item names**\n');
fprintf('Number of critical items must be divisible by %d to have a balanced design.\n', itemsneeded);

% the user decides whether or not to use a list of item names
% if there is not an external list, the items are just numbered 1,2,3,...
while 1
    assignnames = lower(inputstring('\nUse external list of item names (y/n)?: '));
    if strcmp(assignnames, 'n') % NO external list
        externallist = 0;
        break;
    elseif strcmp(assignnames, 'y')
        % try to get an external list
        
        itemfilename=inputstring('Enter item list filename: ');
        itemfile = fopen(itemfilename);
        if itemfile == -1
            fprintf('Unable to open file!\n'); % failed to open file.
               % give the user another chance to decide what to do
        else
            criticalnames = textFileToCellArray(itemfile);
            fclose(itemfile);
            
            % check if the list works
            if strcmp(criticalnames{1},'error') % returned by tFTCA if error
                fprintf('Error in external item list %s.\n', itemfilename);
                % give the user another chance to decide what to do
            else
                % is list the right length?
                numcriticals = size(criticalnames,2); % find out how many items were read
                surplusitems = rem(numcriticals,itemsneeded);
                if ~surplusitems % it fits perfectly
                    externallist = 1; % use this list
                    break
                else
                    % it doesn't fit exactly
                    fprintf('There are %d items listed in the file,\nbut you can only use the first %d in this design.\n', numcriticals, numcriticals-surplusitems);
                    % find out what the user wants to do?
                    goahead = lower(inputstring('Go ahead and use just those items (y/n)?: '));
                    if strcmp(goahead, 'y')
                        numcriticals = numcriticals - surplusitems; % cut off the extra items
                        externallist = 1; % then use this list
                        % right now, this program doesn't support
                        % unbalanced designs
                        break;
                    end % otherwise, give the user another chance to decide what to do
                end
            end
        end
    end
end

% NUMBER OF ITEMS
if externallist
    % number of items is based on the list we just read
    fprintf('Using %d items from file %s.\n', numcriticals, itemfilename);
    % we don't have any calculations to do, just display this so the user
    % knows what's going on
else
    % we need to find out how many items the user
    while 1
      %  fprintf(['\nTotal number of critical items must be divisible by ' num2str(itemsneeded) ...
       %           ' for balanced design.\n']);
        numcriticals = inputnumber('Enter total number of critical items: ', 1);
        if rem(numcriticals, itemsneeded) == 0
            % balanced design
            for i=1:numcriticals  % save the numbers as the item names
                criticalnames{i} = num2str(i);
            end
            break;
        else
            % right now, this program doesn't support unbalanced designs.
            % so if the number of cells doesn't divide evenly into the
            % number of items, we have to make the user enter a new number
            % of items. lo siento.
            fprintf('Unbalanced design not yet implemented. \n');
        end
    end
end

% divide items into blocks
criticalsperblock = numcriticals / numblocks;
repsperblock = criticalsperblock / numlists; % replications WITHIN each block

%% PART FIVE: FILLER TRIALS
fprintf('\n\n**PART FIVE: Filler trials**\n');
while 1
    assignnames = lower(inputstring('Do you want to include filler trials in your design (y/n)?: '));
    if strcmp(assignnames, 'y');
        usefillers = 1;
        break;
    elseif strcmp(assignnames, 'n');
        usefillers = 0;
        break;
    end
end

if usefillers % the rest of this section only applies if you are using fillers
    
    % get the names of the filler levels
    fillerlevels = inputnumber('Enter number of filler CONDITIONS: ', 1);
    
    % assign names
    if fillerlevels == 1
       fillerlevelnames{1} = 'filler'; % no need to name the different conditions
    elseif ~usenames
        % if the user doesn't want to enter names, just name the filler
        % conditions generically
        for i=1:fillerlevels
            fillerlevelnames{i} = ['filler' num2str(i)];
        end
    else
        % get filler condition names from the participant
        for i=1:fillerlevels
            textstring = ['Enter name of filler condition ' num2str(i) ': '];
            fillerlevelnames{i} = inputstring(textstring);
        end
    end
    
    % how many filler needed?
    fillersneeded = fillerlevels * numblocks;
    
    % the user decides whether or not to use a list of item names
    % if there is not an external list, the fillers are just numbered F1,F2,F3,...
    while 1
      assignfillernames = lower(inputstring('\nUse external list of filler names (y/n)?: '));
      if strcmp(assignfillernames, 'n') % NO external list
          externalfillerlist = 0;
          break;
      elseif strcmp(assignnames, 'y')
          % try to get an external list
        
          itemfilename=inputstring('Enter filler list filename: ');
          itemfile = fopen(itemfilename);
          if itemfile == -1
              fprintf('Unable to open file!\n'); % failed to open file.
                 % give the user another chance to decide what to do
          else
            fillernames = textFileToCellArray(itemfile);
            fclose(itemfile);
            
            % check if the list works
            if strcmp(fillernames{1},'ERROR') % returned by tFTCA if error
                fprintf('Error in external filler list %s.\n', itemfilename);
                % give the user another chance to decide what to do
            else
                % is list the right length?
                numfillers = size(fillernames,2); % find out how many items were read
                surplusitems = rem(numfillers,fillersneeded);
                if ~surplusitems % it fits perfectly
                    externalfillerlist = 1; % use this list
                    break
                else
                    % it doesn't fit exactly
                    fprintf('There are %d items listed in the file,\nbut you can only use the first %d in this design.\n', numfillers, numfillers-surplusitems);
                    % find out what the user wants to do?
                    goahead = lower(inputstring('Go ahead and use just those items (y/n)?: '));
                    if strcmp(goahead, 'y')
                        numfillers = numfillers - surplusitems; % cut off the extra items
                        externallist = 1; % then use this list
                        % right now, this program doesn't support
                        % unbalanced designs
                        break;
                    end % otherwise, give the user another chance to decide what to do
                end
            end
          end
      end
    end

   % NUMBER OF FILLERS
   if externalfillerlist
     % number of fillers is based on the list we just read
     fprintf('Using %d fillers from file %s.\n', numfillers, itemfilename);
     % we don't have any calculations to do, just display this so the user
     % knows what's going on
   else
     % we need to find out how many items the user
    while 1
        fprintf('As a reminder, you have %d CRITICAL trials.\n', numcriticals);
        fprintf('How many fillers do you want?\nThe number of fillers must be divisible by %d to have a balanced design.\n', fillersneeded);
        numfillers = inputnumber('Enter total number of fillers: ', 1);
        if rem(numfillers, fillersneeded) == 0
            % balanced design
            for i=1:numfillers  % save the numbers as the item names
                fillernames{i} = ['F' num2str(i)];
            end
            break;
        else
            % right now, this program doesn't support unbalanced designs.
            % so if the number of cells doesn't divide evenly into the
            % number of items, we have to make the user enter a new number
            % of items. lo siento.
            fprintf('Unbalanced design not yet implemented. \n');
        end
    end
   end
   
   % how many fillers of each condition appear in each block?
   fillersperblock = numfillers/numblocks;
   frepsperblock = fillersperblock/fillerlevels;   
else
    numfillers = 0;
    frepsperblock = 0;
    fillersperblock = 0; % there are no fillers if we choose not to use them
end

% TOTAL TRIALS per block, counting both fillers and critical items
totaltrialsperblock = fillersperblock + criticalsperblock;
% note that this is the same as criticalsperblock when there are no fillers

%% PART SIX: ASSIGN ITEMS TO CONDITIONS
%  Here we assign the items to levels of each factor.
%
%  N.B. at this point they are sorted by item numbers and condition.  LATER
%  we will put them in a random order.  right now they are "proto-lists"

% create a blank set of protolists
protolists = zeros(numlists,ITEMID,numcriticals+numfillers);

% --create a list for the balanced factors (which are orthogonally
% manipulated)--
mastercellnumbers = [];
for i=1:numblocks
    listinblock = [];
    % build up the list of cells that will appear in this block
    for j=1:repsperblock % if multiple replications within each block
        listinblock = [listinblock (1:numlists)];
    end
    
    % --add these to the list for the BALANCED FACTORS--   
    % randomize the order that these cells will appear in
    listinblock = randorder(listinblock);
    % add these to the full lists!
    mastercellnumbers = [mastercellnumbers listinblock];
    
end

% translate these into conditions for EACH LIST
for listnum = 1:numlists
    
   % BALANCED factors
   cellnumbers = mastercellnumbers;
   for factornum = 1:balfactors
       % interpret each cell number in terms of the factor
       critlist = rem(cellnumbers,ballevels(factornum)) +1;
       
       % assign the critical list, spread across blocks
       for blocknum=1:numblocks
           protostartpt = ((blocknum-1)*totaltrialsperblock)+1; % this leaves room for fillers
           critstartpt = ((blocknum-1)*criticalsperblock)+1; % no fillers in the list of critical trials
           protolists(listnum,factornum, protostartpt : protostartpt + criticalsperblock -1) = ...
               critlist(critstartpt:critstartpt+criticalsperblock-1);
           
           % mark all the critical trials as CRITICAL
           protolists(listnum,ISCRITICAL,protostartpt : protostartpt + criticalsperblock - 1) = ...
               ones(criticalsperblock,1);
       end
       
       % update for the next factor
       cellnumbers = ceil(cellnumbers/ballevels(factornum));
       
   end
   % iterate BALANCED cell numbers so the next list will be different
   mastercellnumbers(mastercellnumbers>numlists) = 1;
   mastercellnumbers = mastercellnumbers + 1;   
   
   % NUISANCE factors
   % these just get RANDOMIZED, not balanced
   % this means there might be some confounds.  if you really want things
   % to be orthogonal, you need to make them BALANCED factors!
   for factornum = nuifactor1:nuifactorlast % these start several columns over
       for blocknum=1:numblocks % do this WITHIN EACH BLOCK
         itemspercond = criticalsperblock/nuilevels(factornum-balfactors);
         % construct a list of conditions
         cellnumbers = repmat(randperm(nuilevels(factornum-balfactors)),1,itemspercond);
         cellnumbers = randorder(cellnumbers);
         % assign to the list
         protostartpt = ((blocknum-1)*totaltrialsperblock)+1; % this leaves room for fillers
         protolists(listnum,factornum,protostartpt : protostartpt+criticalsperblock-1) = ...
             cellnumbers;
       end
   end
   
   % FILLERS
   % fillers are added (for now) after all the critical trials
   % they get mixed in later (in part 7)
   if usefillers
       for blocknum=1:numblocks
           % build up the list of fillers that will appear in this block           
           listinblock = [];
           for j=1:frepsperblock % if multiple replications within each block
              listinblock = [listinblock (1:fillerlevels)];
           end
           
           % now, assign to the list
           protostartpt = ((blocknum-1)*totaltrialsperblock)+criticalsperblock+1; % after the fillers
           protolists(listnum,FILLERCOND,protostartpt : protostartpt+fillersperblock-1) = ...
               listinblock;           
       end
   end
 
end

% add the item numbers
% these are the SAME for all lists at present to ensure that the items are
% counterbalanced across list in terms of which condition they are in.
%
% in part seven, we randomize the presentation order w/in each list

% create orderings
% n.b. this stuff is legacy code, could be made more efficient
critordering = randperm(numcriticals);
fillerordering = randperm(numfillers);
    
for j=1:(numfillers+numcriticals)
      % go through and handle each item
      if protolists(1,ISCRITICAL,j) == 1
          % critical trial
          % assign a critical ID number to the list
          protolists(:,ITEMID,j) = repmat(critordering(1),numlists,1);
          % chop that number off
          critordering = critordering(2:numel(critordering));
      else
          % filler trial
          % assign a filler ID number to the list
          protolists(:,ITEMID,j) = repmat(fillerordering(1),numlists,1);
          % chop that number off
          fillerordering = fillerordering(2:numel(fillerordering));
      end
end 

%% PART SEVEN: RANDOMIZE ORDER
% NOW, we take the items and put them in a random order

randomizedlists=zeros(size(protolists));

% find out if we need to avoid repeating any condition 2x in a row
fprintf('\n\n**PART SIX: LIST ORDERING**\n'); % user doesn't see anything for the real part 6
fprintf('Do you want to attempt to avoid having 2 trials with identical balanced factors in a row?\n');
fprintf('Note: There may be partial overlaps or overlaps in nuisance factors & fillers.\n');
while 1
    assignnames = lower(inputstring('Attempt to avoid repeated conditions (y/n)?: '));
    if strcmp(assignnames, 'y');
        avoidrepeats = 1;
        numfails = 0; % start counting failures
        break;
    elseif strcmp(assignnames, 'n');
        avoidrepeats = 0;
        break;
    end
end

% right now, in each block, the items cycle through condition in a fixed
% order
% so, we need to randomize within each block
for listnum=1:numlists % each list has a different order

    fprintf('Randomizing list %d ...\n', listnum);
    done = 0; % this gets set to 1 once a list is confirmed as good
    
    while ~done % we may need to try this several times if we are avoiding repeats
        
        % --first, randomize the ORDER OF THE BLOCKS--
        % otherwise, some items will always be in the first half or second
        
        % locate the blocks
        for blocknum=1:numblocks
            blockstart = (blocknum-1)*totaltrialsperblock+1;
            rawblocks{blocknum} = protolists(listnum,:,blockstart:blockstart+totaltrialsperblock-1);
            % kludgy way to do this -- just copy into a cell array
        end
        % decide on a random order for the blocks
        blockorder = randperm(numblocks);
        
        % --now, randomize the trials WITHIN the block--
        for blocknum=1:numblocks
            itemordering = randperm(totaltrialsperblock);
       
            % now, use this ordering to reorder the trials within the block
            blockstart=(blocknum-1)*totaltrialsperblock; % actualy 1 less than the block start, but the first entry here is blockstart+1
            for i=1:totaltrialsperblock
               randomizedlists(listnum,:,i+blockstart) = rawblocks{blockorder(blocknum)}(1,:,itemordering(i));
            end
        end
        
        % list is done, now check it for repeats
        
         if ~avoidrepeats
             done = 1; % if we don't care about repeats, this is fine, no need to check anything
         else
             % NOTE: this is a REALLY kludgy mechanism for checking for
             % repeats.  it creates the list randomly, runs through the
             % list, and recreates the list if it finds a repeat.  this
             % could be greatly improved by having the program try to avoid
             % repeats in the first place when it orders the list.
             failed = 0; % no problems ... yet
             for i=2:numcriticals % 1st trial has no prior trial to check against, start with #2
                 if randomizedlists(listnum,ISCRITICAL,i) ~= randomizedlists(listnum,ISCRITICAL,i-1)
                     % can't be a conflict if one is a filler and the other
                     % isn't.  we're OK so far
                 elseif randomizedlists(listnum,ISCRITICAL,i) ==0
                     % right now there is no checking for repeated fillers
                 else % ok, there are 2 two critical trials
                     lasttrial = randomizedlists(listnum,1:balfactors,i-1);
                     thistrial = randomizedlists(listnum,1:balfactors,i);
                     if size(find(lasttrial == thistrial),2) == balfactors % they ALL match
                        % oh crap, a match
                        failed = 1;
                        numfails = numfails + 1;
                       if numfails >= maxfails
                           fprintf('listmaker was unable to avoid repeated conditions in your design.\nList %d will contain some repeated conditions.\n\n',listnum);
                           done=1; % give up
                       end
                       break; % don't keep checking this list, it's already a failure
                     end
                 end
             end
             % checked all the trials
             if ~failed
                % success on this list!
                done=1;
             end
         end
    end % if there are problems with this list, redo it
end

%% PART EIGHT: SAVE THE LISTS

% get the file prefix from the user
fprintf('\n\n**PART SEVEN: SAVE THE COMPLETED LISTS**\n'); % user doesn't see anything for part 6
fileprefix = inputstring('Enter file prefix for export: ');

% write the files
for listnum=1:numlists
    filename = [fileprefix num2str(listnum) '.csv'];
    currentfile = fopen(filename, 'w');
    
    % set up the header rows
    fprintf(currentfile, 'Trial');
    if usefillers
        fprintf(currentfile, ',IsCritical'); % no need for this if we ONLY have criticals
    end
    fprintf(currentfile, ',ItemID');
    if numblocks > 1
       fprintf(currentfile, ',Block'); % no need to include a block column
    end                               % when there is only 1 block
    for j=1:balfactors
       fprintf(currentfile, ',%s', balnames{j});
    end
    for j=1:nuifactors
       fprintf(currentfile, ',%s', nuinames{j});
    end
    if usefillers
        fprintf(currentfile, ',FillerType');
    end
    fprintf(currentfile, '\n');
    
    % export each individual item
    for j=1:(numcriticals+numfillers)
        % TRIAL NUMBER 
        fprintf(currentfile, '%d', j);
        % ISCRITICAL
        if usefillers  % only print this if we have fillers
            fprintf(currentfile, ',%d', randomizedlists(listnum,ISCRITICAL,j));
        end
        % ITEM ID
        if randomizedlists(listnum,ISCRITICAL,j)
            % look up the critical trial ID
            fprintf(currentfile, ',%s', criticalnames{randomizedlists(listnum,ITEMID,j)});
        else
            % look up the filler trial ID
            fprintf(currentfile, ',%s', fillernames{randomizedlists(listnum,ITEMID,j)});     
        end
        % BLOCK NUMBER
        if numblocks > 1
          fprintf(currentfile, ',%d', ceil(j/totaltrialsperblock));
        end
        % FACTOR DATA
        if randomizedlists(listnum,ISCRITICAL,j)
          % critical trials
          if usenames    % use NAMES for factor levels
              for i=1:totalfactors
                  fprintf(currentfile, ',%s', levelnames{i,randomizedlists(listnum,i,j)});
              end
          else           % use NUMBERS for factor levels
              for i=1:totalfactors
                  fprintf(currentfile, ',%d', randomizedlists(listnum,i,j));
              end
          end
          % at the end of the critical conditions
          if usefillers
              % print a blank column for the filler condition
              fprintf(currentfile, ',n/a');
          end
        else
            % filler trials
            for k=1:totalfactors % print n/a for all the critical conditions
                fprintf(currentfile, ',n/a');
            end
            % note that is always 0 if there are no fillers
            fprintf(currentfile, ',%s', fillerlevelnames{randomizedlists(listnum,FILLERCOND,j)});
        end
        fprintf(currentfile, '\n'); % end row, move to next item
    end
    
    % done with this file
    fclose(currentfile);
    
end

%% PART NINE: WRAP UP
fclose all;
fprintf('\nDone!\nYour lists are now ready to use.\n(But, be sure to check over them first.)\n');

  listmakerrunning = 0; % done, so quit
 end
end