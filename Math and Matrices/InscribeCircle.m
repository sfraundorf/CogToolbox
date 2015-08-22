function [x, y]=InscribeCircle(center, radius, angle)
% 
%     [x, y]=InscribeCircle(center, radius, angle)
% 
% function returns the x-y coordinates for a point inscribed in a circle
% with radius RADIUS and center CENTER.  ANGLE is calculated clockwise from
% horizontal vector going right from center.
% 
% 05.20.06 M.Diaz
% 11.21.09 S.Fraundorf - capitalized function name to match file

rad=angle/180*pi;

x=center+cos(rad)*radius;
y=center+sin(rad)*radius;