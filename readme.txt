%% ECE537 Project Main
% Project Title: On road dynamic scenario classification (OBD/physiological) approach
% 12/2/2017
% tcyu@umich.edu

%% Dataset description
% WLE data SongWang Trip1-6 sync data
% relabel video with modified TRI labeling GUI

% Attributes name
% 1-'time', 2-'speed_mph', 3-'GPS_long_degs', 4-'GPS_lat_degs',
% 5-'GPS_heading_degs', 6-'long_accel_g', 7-'lat_accel_g',
% 8-'vector_accel_g', 
% 9-'vert_accel_g', 10-'hr', 11-'gsr'

% target Class
% 12-'Lane_Change_Left' 13-'Lane_Change_Right' 14-'Turn_Left'
% 15-'Turn_Right' 16-'GoSraight'

% WLE_Freq = 10;      % 10Hz
% EventLength = 5;    % fixed 5 second for each event definition
% NumTrip = 6;        % total 6 trips 

%% project components

%% modified labeling software 
% added forward/backward to time stamp features
% use ActiveX matlab module as media player

%% data normalization
% absolute value normalization
% z-normalization
% trip segment orientation invariant

%% 12 common statistic feature extraction on time series data

%% PCA data visualization

%% decision tree feature importance 

%% NN-K-fold
%% SVM-K-fold
%(not good, need to spend time to study and find optimal hyper-parameters)
%% strathed Sampling

%% experiment
% comparison with/without orientation normalization
% comparison with/without feature extraction

