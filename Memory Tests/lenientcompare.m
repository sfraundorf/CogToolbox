function lenientscore=lenientcompare(correctanswer,subjectresponse)

% lenientscore = lenientcompare(correctanswer, subjectresponse)
%
% Returns integer score LENIENTSCORE from 1-100 based on how similar 2
% strings, CORRECTANSWER and SUBJECTRESPONSE, are to one another.
%
% This is based on the amount of overlap between the characters in
% SUBJECTRESPONSE and CORRECTRESPONSE, disregarding letter order.  It's
% CASE INSENTIIVE.
%
% 95 is the highest score possible without an exact correct-order match
%
% Adapted from an algorithm by Brady Butterfield in REALbasic
%
% 11.11.06 - J. R. Finley - first version
% 08.21.12 - S. Fraundorf - removed an unused variable

  %% trim any whitespace and convert to lowercase for both correctanswer and subjectresponse
  correctanswer=lower(strtrim(correctanswer));
  subjectresponse=lower(strtrim(subjectresponse));
  
  %% these will allow us to revert to the original values of the two strings if needed 
  subjectresponseOriginal=subjectresponse;
  
  %% initialize the counter for number of character matches
  nummatches=0;

  if strcmp(correctanswer,subjectresponse)    %% if the 2 strings are EXACTLY the same, give score of 100
    lenientscore=100;
  else   %% otherwise, calculate a score for partial match
      
    correctlength=length(correctanswer);
    subresponselength=length(subjectresponse);
    lengthboth=length([correctanswer subjectresponse]);
    
    %% look for first occurrences of letters in subjectresponse that match a
    %% letter in correctanswer, and delete each of those as we go, so that it's only counted once
    for i=1:correctlength
        charfindresult=strfind(subjectresponse,correctanswer(i)); %% use 'strfind' to look in subjectresponse for occurrences of the ith letter in correctanswer
        if charfindresult  
            subjectresponse(charfindresult(1))='';  %% remove first occurrence of correctanswer(i) in subjectresponse
            nummatches=nummatches+1;   %% increase match counter
        end
    end
    
    %% do same thing for correctanswer, but reset subjectresponse first
    subjectresponse=subjectresponseOriginal;
    for i=1:subresponselength
        charfindresult=strfind(correctanswer,subjectresponse(i));
        if charfindresult
           correctanswer(charfindresult(1))='';  
           nummatches=nummatches+1;
        end
    end

    %% Convert to a % of matches, but multiply by 95 instead of 100, so the
    %% highest score you can get without an exact match is 95.
    %% If we didn't do it this way, a subject response of "rats" when the 
    %% correct answer is "star" would give score 100.
    %% Also, we use 'ceil' to round up to the nearest integer.
    lenientscore=ceil(95*nummatches/lengthboth);
    
  end
