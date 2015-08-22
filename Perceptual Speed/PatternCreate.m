% [segments same] = PatternCreate(setsize)
%
% Used internally by PatternComparison.m to create random patterns.
%
% The patterns consistent of SETSIZE line segments.  The segments are
% segments on an invisible 4 x 4 grid.
%
% Returns two sets of random segments and flag SAME that indicates whether
% or not they are the same.
%
% 01.26.10 - S.Fraundorf - first version

function [segments same] = PatternCreate(setsize)

same = round(rand); % 0 or 1
segments = zeros(2,setsize);

% x1x2x3x
% 4 5 6 7
% x8x9x0x
% 1 2 3 4
% x5x6x7x
% 8 9 0 1
% x2x3x4x
possiblesegments = 24;

% row 1
for i=1:setsize
    done =0;
    while ~done
        done = 1; % assume OK unless an error
        % pick a random line segment
        segments(1,i) = ceil(rand*possiblesegments);
        % make sure this vertex isn't already part of the pattern
        for j=1:(i-1)
            if segments(1,i) == segments(1,j)
                done =0;
                break;
            end
        end
        % pick a new segment, if needed
    end
    % move on to the next line segment
end

% pattern 2 is the same
segments(2,:)= segments(1,:);

if ~same
    done = 0;
    while ~done
      % pick a random line segment to permute
      i = ceil(rand*setsize);
      % change it
      segments(2,i) = ceil(rand*possiblesegments);
      % see if this segment was already part of the pattern
      if numel(find(segments(2,i) == segments(2,:))) == 1 && ...
             segments(2,i) ~= segments(1,i)
          % only ONE copy of this segment
          % AND, it's not the segment we just deleted
          done = 1;
      else
          % put the segment "back" and try again
          segments(2,i) = segments(1,i);
      end
    end % keep picking new segments if needed
end