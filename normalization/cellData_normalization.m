function norm_cellData = cellData_normalization(cellData)
% Recall the attri definition
% 1-'speed_mph', 2-'GPS_long_degs', 3-'GPS_lat_degs',
% 4-'GPS_heading_degs', 5-'long_accel_g', 6-'lat_accel_g',
% 7-'vector_accel_g', 
% 8-'vert_accel_g', 9-'hr', 10-'gsr'
norm_cellData = zeros(size(cellData,1),size(cellData,2));

% 70mph -> 31.111meter per sec
SPEEDMID = 70*(1.60934*1000/3600);
% [60,120] limit for heart rate
HRLOW = 60;
HRHIGH = 120;
% [30,150] upper limit for scl
SCLLOW = 30;
SCLHIGH = 150;


% norm speed to mileph to meterps 
norm_cellData(:,1) = (cellData(:,1).*(1.60934*1000/3600))./SPEEDMID;
% norm GPS_lat and long
[norm_cellData(:,2),norm_cellData(:,3)] = GPS_normalization(cellData(:,[2 3]));
% norm GPS_heading_degs [0,360) to [-pi,pi)
norm_cellData(:,4) =  cellData(:,4).*(pi/180)-pi;
% attri 5 - 8 are small enough
norm_cellData(:,5:8) =  cellData(:,5:8);
% norm heart rate (hr) set boundary
norm_cellData(:,9) = (cellData(:,9)-HRLOW)./(HRHIGH-HRLOW);
% norm SCL (scl-low frequency components of GSR) set boundary
norm_cellData(:,10) = (cellData(:,10)-SCLLOW)./(SCLHIGH-SCLLOW);

end

function [norm_x,norm_y] = GPS_normalization(GPS_data)
% default mph limit: 70mph : 70*1.6*1000/3600 = 31.11 meters per sec
% 5 sec windows
window_len = 5;
spd_upper = 31.111;
coord_mean = spd_upper*window_len;

% step1. lat,long to UTM coord
Long = GPS_data(:,1);
Lat = GPS_data(:,2);
[coord_x,coord_y,~]=ll2utm(Lat,Long);

% step2. absolute normalization based on vehicle speed limit
scale_norm_x = (coord_x-coord_x(1))./coord_mean;
scale_norm_y = (coord_y-coord_y(1))./coord_mean;

% step3.turn all segment with zero orientation

% - get segment orientation
%segAngle = getSegmentAngle(scale_norm_x,scale_norm_y);
% - rotate the segment to zero orientation
%[norm_x,norm_y]=rotate2Ori(scale_norm_x,scale_norm_y,segAngle);
norm_x = scale_norm_x;
norm_y = scale_norm_y;
end



