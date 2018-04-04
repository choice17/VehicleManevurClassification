function [segAngle,mean_x,mean_y] = getSegmentAngle(scale_norm_x,scale_norm_y)
% objective: get the orientation of the segment
% input: norm_x and norm_y - norm x,y coordinate start with origin position
% output: segment angle (based on the mean coord position to origin)

% suppose norm_x and norm_y is at origin (0,0)
assert(scale_norm_x(1)==0 && scale_norm_y(1)==0,'segment does not begin at origin');

% get mean position of the event segment
mean_x = mean(scale_norm_x);
mean_y = mean(scale_norm_y);

% to pi and -pi 
% ** note: 0 - east side | pi/2 - north | pi - west | -pi - south
segAngle =  atan2(mean_y,mean_x);

end