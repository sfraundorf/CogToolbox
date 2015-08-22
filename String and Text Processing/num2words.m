% words = num2words(number)
%
% Converts NUMBER to a string with the name of the number written out (e.g.
% 'Two' or 'Seventy-Three'
%
% Currently, 0 <= number <= 9999
%
% 01.26.10 - S.Fraundorf - first version

function words = num2words(number)

if number < 0 || number > 9999
    % these numbers are not supported
    error('number must be between 0 and 9999 inclusive');
elseif number == 0
    words = 'Zero';
else
    words = [];
    
    % thousands digit
    if number > 1000
        words = [words num2words(floor(number/1000)) ' Thousand'];
        number = mod(number,1000);
        if number == 0
            return;
        elseif number > 100
            words = [words ', '];
        else
            words = [words ' and '];
        end
    end
    
    % hundreds digit
    if number > 100
        words = [words num2words(floor(number/100)) ' Hundred'];
        number = mod(number,100);
        if number == 0
            return;
        else
            words = [words ' and '];
        end
    end
    
    % tens digit
    if number > 90
        words = [words 'Ninety-'];
        number = number - 90;
    elseif number == 90
        words = [words 'Ninety'];
        return;
    elseif number > 80
        words = [words 'Eighty-'];
        number = number - 80;
    elseif number == 80
        words = [words 'Eighty'];
        return;
    elseif number > 70
        words = [words 'Seventy-'];
        number = number - 70;        
    elseif number == 70
        words = [words 'Seventy'];
        return;        
    elseif number > 60
        words = [words 'Sixty-'];
        number = number - 60;
    elseif number == 60
        words = [words 'Sixty'];
        return;        
    elseif number > 50
        words = [words 'Fifty-'];
        number = number - 50;
    elseif number == 50
        words = [words 'Fifty'];
        return;        
    elseif number > 40
        words = [words 'Forty-'];
        number = number - 40;
    elseif number == 40
        words = [words 'Forty'];
        return;        
    elseif number > 30
        words = [words 'Thirty-'];
        number = number - 30;
    elseif number == 30
        words = [words 'Thirty'];
        return;        
    elseif number > 20
        words = [words 'Twenty-'];
        number = number - 20;
    elseif number == 20
        words = [words 'Twenty'];
        return;        
    end
    
    % ones digit & teens
    switch number
        case 1
            words = [words 'One'];
        case 2
            words = [words 'Two'];
        case 3
            words = [words 'Three'];
        case 4
            words = [words 'Four'];
        case 5
            words = [words 'Five'];
        case 6
            words = [words 'Six'];
        case 7
            words = [words 'Seven'];
        case 8
            words = [words 'Eight'];
        case 9
            words = [words 'Nine'];
        case 10
            words = [words 'Ten'];
        case 11
            words = [words 'Eleven'];
        case 12
            words = [words 'Twelve'];
        case 13
            words = [words 'Thirteen'];
        case 14
            words = [words 'Fourteen'];
        case 15
            words = [words 'Fifteen'];
        case 16
            words = [words 'Sixteen'];
        case 17
            words = [words 'Seventeen'];
        case 18
            words = [words 'Eighteen'];
        case 19
            words = [words 'Nineteen'];
    end
end