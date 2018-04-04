function projectData = importSyncData()
%% sync fileName 
fileLocation = '../data/';
fileName =  {'Trip1-synchronized.csv', ...
            'Trip2-synchronized.csv', ...
            'Trip3-synchronized.csv', ...
            'Trip4-synchronized.csv', ...
            'Trip5-synchronized.csv', ...
            'Trip6-synchronized.csv'};
videoRange =[1 1;
             2 2;
             3 3;
             4 4;
             5 5;
             6 6];
numTrip = 6;
%% import sync file
syncData = cell(1,6);
for i = 1:numTrip
    syncData{i} = importfile([fileLocation fileName{i}]);
end

%% import label file

%% matching
