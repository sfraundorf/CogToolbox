function success = emailResults(filenames, emailaddress)

% success = emailResults(filenames, emailaddress)
%
% THIS FUNCTION ONLY WORKS AS-IS ON THE UIUC CAMPUS.  (But, all you'd have
% to edit is the first line, to change the name of the SMTP server).
%
% E-mails experiment results (or any other file!) to yourself as an
% attachment.  The subject line of the e-mail is 'Results: ' plus the name
% of the file.
%
% Parameter FILENAMES is a string specifying the name of a file, or
% a cell array specifying MULTIPLE files to attach.
%
% Parameter EMAILADDRESS is a string specifying the e-mail address to which
% you want to send the files.
%
% Returns 0 if the file was successfully emailed or -1 if not.
%
% 10.08.10 - S.Fraundorf - first version
% 10.28.10 - S.Fraundorf - updated to new server.  fixed subject line when
%                          sending more than 1 file
% 11.06.10 - S.Fraundorf - correctly returns 0 when file e-mailed OK
% 11.30.10 - S.Fraundorf - fixed error handling to work with newer versions of
%                           MATLAB
% 08.21.12 - S.Fraundorf - display warning message if it fails to email

servername = 'cyrus.psych.illinois.edu';
% for UIUC psych dept

try
    % set the SMTP server
    setpref('Internet', 'SMTP_Server', servername);
        
    % use the e-mail address as the OUTGOING address as well
    setpref('Internet', 'E_mail', emailaddress);
   
    % convert to cell array if character
    if ischar(filenames)
        filenames = {filenames};
    end
        
    % set a subject line for the e-mail
    if numel(filenames) > 1
        subjline = ['Results: ' filenames{1} ' and others'];
    else
        subjline = ['Results: ' filenames{1}];
    end
        
    % send the e-mail
    sendmail(emailaddress, subjline, ...
        'Results e-mailed by MATLAB function emailResults from the CogToolbox.', ...
        filenames);
    success = 0;
  
catch
    % report an error
    warning('CogToolbox:emailResults:FailedToEmail', 'Attempt to email results failed.');
    success = -1;
end