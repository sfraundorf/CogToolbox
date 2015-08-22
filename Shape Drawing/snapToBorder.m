% piccoords = snapToBorder(region, XMid, YMid,picsize)
%
% Returns a rect of coordinates that would align a picture of size PICSIZE
% against the border of rect REGION.  PICSIZE and REGION must both be 1x4
% vectors of coordinates.
%
% If REGION is larger than PICSIZE, the alignment is made according to
% these principles:
%  - Horizontal alignment: to left border if left of screen center,
%                          to right border otherwise
%  - Vertical alignment  : to top border if above screen center,
%                          to bottom border otherwise
% XMID and YMID are the X and Y coordinates to the screen center
%
% I use this function in my visual world experiments.  The ports to which
% the participant moves items are larger than the pictures themselves, to
% make the movement a little more lenient.  Then, snapToBorder is used to
% snap the pictures into the correct location.
%
% 02.08.10 - S.Fraundorf
% 02.22.10 - S.Fraundorf - renamed getPicCoords to snapToBorder

function piccoords = snapToBorder(region, XMid, YMid, picsize)

piccoords = zeros(1,4);

% x coordinates
if region(1) < XMid                             
   piccoords(1) = region(1);
   piccoords(3) = region(1) + picsize(3);
else
   piccoords(3) = region(3);
   piccoords(1) = region(3) - picsize(3);
end

% y coordinates
if region(2) < YMid
   piccoords(2) = region(2);
   piccoords(4) = region(2) + picsize(4);
else
   piccoords(4) = region(4);
   piccoords(2) = region(4) - picsize(4);
end
