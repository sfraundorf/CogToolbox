% outputstring = hourmin(seconds)
%
% Provides nicely formatted output in 12-hour format from the CLOCK
% function.  Always includes hour and minutes; if optional parameter
% SECONDS is 1; also adds the seconds.
%
% 07.11.08 - S.Fraundorf

function outputstring = hourmin(seconds)
   
   if nargin == 0 % default = don't include seconds
       seconds= 0;
   end
   
   currenttime = fix(clock); % get the time
   hoursnum = currenttime(4); % parse out the hours
   minutesnum = currenttime(5); % parse out the minutes
   
   % is this AM or PM?
   pm = 0;
   if hoursnum > 11
       pm = 1;
   end
   if hoursnum > 12  % convert 24-hour to 12-hour time
       hoursnum = hoursnum - 12;
   elseif hoursnum == 0 % convert 0-o'-clock to 12
       hoursnum = 12;
   end
   
   % create the output string
   outputstring = [num2str(hoursnum) ':' num2strLZ(minutesnum, '%d', 2)]; 
   
   % add seconds, if requested
   if seconds > 0
       outputstring = [outputstring ':' num2str(currenttime(6))];
   end
   
   % add AM/PM
   if pm
     outputstring = [outputstring ' PM'];
   else
     outputstring = [outputstring ' AM'];
   end
   
end