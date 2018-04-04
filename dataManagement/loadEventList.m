function eventData = loadEventList(dataPath)
%% load the extracted mapped eventlist-label from datapath to workspace
% input: dataPath to store the data
% output: retrieve eventlist/noeventlist
%% code start here
% only check for .mat file
evenlistDir = dir([dataPath '*.mat']);


num_eventData = length(evenlistDir);

for dataNum = 1:num_eventData
    thisData_path = [evenlistDir(dataNum).folder '\' evenlistDir(dataNum).name];
    eventData.(['trip' num2str(dataNum)]) = load(thisData_path);
end
    
    