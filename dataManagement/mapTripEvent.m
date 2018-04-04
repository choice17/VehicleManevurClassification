function mapTripEvent()
%% to map the onroad event labels of TRI video to WLE data
% WLE video-label-sync data mapping for CIS568 data minning
% synchronization on event labels and WLE data 
% @ 29/7/2017 by choi 
% 1.added the capability to choose any (onroad/dynamic trip event) to map on
% the WLE data 
% 2.added addGoStraightEventFlag to enable adding a event Col 'GoStraight' 
% @ 9/8/2017 by choi
% add outDataRate to get down sample output 
% @ 29/11/2017 by Choi
% 3. rewrite the function to mapping eventlist-GoStraightList(noEventList)

%% setup parameter
%path info--------------------------------

filename = 'Trip1-synchronized';
inputfolder = ['../../data/' filename];
outputfolder = ['../../output/' filename];

% sync data lag seconds to video data
% +ve if video is record earlier than wle OBD data
% -ve is OBD data is record earlier than video recording 
% here is the list of video time lag for WLE Song Trip1-6 to OBD time
% Trip1 +57s, Trip2 +35s, Trip3 -26.6s,
% Trip4 +61s, Trip5 -19.7s, Trip6 -24.5s
videoLag = 57;

%Label event attr column selection--------default
%1-'Start Time' 2-'End Time' 3-'Road Status' 4-'Traffic' 5-'Stop' 6-'Yield'
%7-'Traffic Light' 8-'Lane Change Left' 9-'Lane Change Right' 10-'Turn Left'
%11-'Turn Right'  12-'Merge Left' 13-'Merge Right' 14-'Intersection'

%workload col--------------------default
%1-'time' 2-'real-time' 3-'ecg' 4-'hr' 5- 'hrv' 6-'br' 7-'posture'
%8-'activity' 9-'peakaccel' 10-'gsr' 11-'scl' 12-'scr' 13-'driver_wl' 
%14-'expert wl' 15-'traffic_load' 16-'event' 17-'context' 18-'time[s]' 
%19-'speed[mph]' 20-'GPS long[degs] 21-'GPS lat [degs]' 22-'GPS heading[degs]
%23-'long accel[g]' 24-'lat accel[g]' 25-'vector accel[g]' 26-'vert accel[g]'

%for label
timeCol = [1 2];
roadEventCol =[];
dynamicEventCol = [8 9 10 11];

%for WLE data 
WLEAttrIdx = [1 19 20 21 22 23 24 25 26 4 10];

%Sync data freq----------------------------default
WLE_Freq = 10; %Hz
fps = 29.97 ; %fps
sampleLength = 5; % 5seconds consider each event is 5 sec

%add go straight event--------------------flag go zero to turn off
addGoStraightEventFlag = 1;

%time format
time_format = 'MM:SS.FFF';

%output format flag
OutputMatFile = 0;
OutputEventFile = 1;
OutputCSVFile = 0;

%output rate: change the rate to simply get the down sampled output data
%ex. ori freq = 100Hz, downsampleRate = 0.1 -> data rate -> 10Hz
%note. down sample here do not perform any filter
outDataRate = 1;


%% loading file
WLEattrNum = 26; % refer to event label output from WLE video

fprintf(['for now on start mapping event @ ' datestr(now) '\n']);
fprintf('loading event label data ...\n');

csvfile = dir([inputfolder '/*data.csv']);
csvfile = [inputfolder '/' csvfile.name ];

fprintf('loading WLE data ...\n');
fid = fopen(csvfile);
WLE_Raw = textscan(fid,repmat('%s',1,WLEattrNum),'Delimiter',',');
fclose(fid);
WLE_Raw = WLE_Raw(:,WLEAttrIdx);
WLEattr = cleanStr(cellfun(@(x) x(1),WLE_Raw),' ','_');
WLEattr = cleanStr(WLEattr,'[');
WLEattr = cleanStr(WLEattr,']');
WLEdata = cell2mat(cellfun(@(x) str2num(char(x(2:end))),WLE_Raw,'UniformOutput',0));

WLE = array2table(WLEdata,'VariableName',WLEattr);


csvfile = dir([inputfolder '/*label.csv']);
csvfile = [inputfolder '/' csvfile.name ];
fprintf('loading label ...\n');
fid = fopen(csvfile);
tripEvent = textscan(fid,repmat('%s',1,WLEattrNum),'Delimiter',',');
fclose(fid);

%xlsfile = dir([inputfolder '/*label.csv']);
%xlsfile = [inputfolder '/' xlsfile.name];
%[~,~,tripEvent] = xlsread(xlsfile);
 
fprintf('finish loading data\n');
%output: WLE tripEvent
%% retrieve the file matrix
%lcCol = find(cellfun(@(x) ~isempty(x),(regexp(C(1,:),'Lane|lane'))));
fprintf('start mapping the event and WLE data...\n');

% time attri retrieval
timeAttr = cellfun(@(x) x{1}, tripEvent(1,timeCol),'UniformOutput',0);
timeAttrList_raw = [ datenum(tripEvent{1}(2:end),time_format) ...
                 datenum(tripEvent{2}(2:end),time_format)];

timeAttrList_correct = timeAttrList_raw -timeAttrList_raw(1,1)- videoLag/86400;

%sync label (video data) to obd data
timeAttrList = timeAttrList_correct(timeAttrList_correct(:,1)>=0,:);

% road event attri retrieval
roadEventList = cell2mat(cellfun(@(x) str2num(char(x(2:end))),tripEvent(roadEventCol),'UniformOutput',0));
roadEventAttr = cellfun(@(x) x{1}, tripEvent(1,roadEventCol),'UniformOutput',0);

% dynamic attri retrieval
dynamicEventList = cell2mat(cellfun(@(x) str2num(char(x(2:end))),tripEvent(dynamicEventCol),'UniformOutput',0));
dynamicEventList = dynamicEventList(timeAttrList_correct(:,1)>=0,:);
dynamicEventAttr = cellfun(@(x) x{1}, tripEvent(1,dynamicEventCol),'UniformOutput',0);
% combine attri column
tripEventList = [timeAttrList roadEventList dynamicEventList];
videoLen = datestr(max(tripEventList(:,2)),'MM:SS.FFF');
tripEventAttr = [timeAttr roadEventAttr dynamicEventAttr];
tripEventAttr = cleanStr(tripEventAttr,' ','_');  
tripEventList = tripEventList(sum(tripEventList(:,3:end) == 1,2)~=0,:);
numEvent = length(tripEventList(:,1));

if addGoStraightEventFlag
    tripEventAttr = [tripEventAttr 'GoStraight'] ;
    tripEventList = [tripEventList zeros(numEvent,1)];
end


[WLEdataLen,WLEAttrNum] = size(WLE);
%initialize output
mapTripEvent = [WLE array2table(zeros(WLEdataLen,length(tripEventAttr(3:end))),...
    'VariableName',tripEventAttr(3:end))];
if addGoStraightEventFlag
    % assume all default dynamic direction  is going straight 
    mapTripEvent{:,end} = 1;
end



%output: WLE tripEventList mapTripEvent 
%% mapping the event time to frame number to whole video event

% extract event list during the mapping
eventList = {};

% extract go-straight list
noEventList = {};

%GT get the event period and map to frame number 
eventTime = num2cell(tripEventList(:,timeCol));
tripEventList(: ,[1 2]) = cell2mat(cellfun(@(x) ...
    round(getFrameNumfromVideo(datestr(x,'MM:SS.FFF'),fps).*(WLE_Freq/fps)), ...
    eventTime,'UniformOutput',0));

%mapping trip event to WLE data
i = 1;
for eventNum = 1:numEvent
    thisEventTime =  tripEventList(eventNum,timeCol(1)):tripEventList(eventNum,timeCol(2));
   
    % output sync
    thisEventLen = length(thisEventTime);
    thisEventAttr =  repmat(tripEventList(eventNum,3:end),thisEventLen,1);
   
    % output event list
    sampleTime = thisEventTime(1):thisEventTime(1)+sampleLength*WLE_Freq-1;
    sampleEventLen = length(sampleTime);
    thisSampleEvent = repmat(tripEventList(eventNum,3:end),sampleEventLen,1);
    
    
    
    if thisEventTime(end) <=WLEdataLen && sampleTime(end)  <=WLEdataLen
        mapTripEvent{thisEventTime,WLEAttrNum+1:end} = thisEventAttr;
        eventList{i} =  mapTripEvent(sampleTime,:);
        eventList{i}{:,WLEAttrNum+1:end} = thisSampleEvent;
        i = i+1;        
    end
end

noEventList = extractNoEventList(mapTripEvent,WLE_Freq,sampleLength);

%downsample for output if needed
mapTripEvent =array2table(mapTripEvent{1:round(1/outDataRate):end,:},...
    'VariableName',mapTripEvent.Properties.VariableNames);

%output: mapTripEvent
%% output result
% write output as csv 
if OutputCSVFile
    mkdir(outputfolder);
writetable(mapTripEvent,...
    [outputfolder '_' datestr(now,'dd-mm-yyyy_HH-MM-SS') '.csv'] ,...
    'Delimiter',',','WriteVariableNames',1);
end
% write mat file
if OutputMatFile
    mkdir(outputfolder);
    save([outputfolder '_' datestr(now,'dd-mm-yyyy_HH-MM-SS') '.mat'],...
        'mapTripEvent');    
end

if OutputEventFile
    save([outputfolder '_EventList_' datestr(now,'dd-mm-yyyy_HH-MM-SS') '.mat'],...
        'eventList','noEventList');
end

fprintf(['finished mapping @ ' datestr(now) '!\n']);
end

function frameNum = getFrameNumfromVideo(time,frameRate,option)
% frameNum = getFrameNumfromVideo(frameRate,time)
% time is a string: ex. 02:05.73
% frame rate typical fps = 29.97~30;
% option selection for unround output frameNum
%%
if nargin ==2 
    option =[];
end
if size(time,1)>1
    error('input dimension not support');
end

if nargin == 1
    frameRate = 30;
end
thisMin = str2double(time(1:2));
thisSec = str2double(time(4:5));
try
    try
        this1ms =  str2double(time(7:9));
        totalSec =  thisMin*60+ thisSec + 0.001*this1ms;
    catch
        this10ms =  str2double(time(7:8));
        totalSec =  thisMin*60+ thisSec + 0.01*this10ms;
    end
catch
    this100ms =  str2double(time(:,7));
    totalSec =  thisMin*60+ thisSec + 0.1*this100ms;
end
if ~isempty(option)
    frameNum = totalSec.*frameRate;
else
frameNum = round(totalSec.*frameRate);
end
end

function cellStr = cleanStr(cellStr,from_char,to_char)

for i = 1:length(cellStr)
    if nargin == 2
        cellStr{i}(strfind(cellStr{i},from_char))=[];
    else 
        cellStr{i}(strfind(cellStr{i},from_char))=to_char;
    end
end
end

function noEventList = extractNoEventList(mapTripEvent,WLE_Freq,sampleLength)
% to extract go_straight event list 
% go straight is for all events other than turns, lane changes
    GoStraight_idx = strfind(mapTripEvent.Properties.VariableNames,'GoStraight');
    GoStraight_idx = cell2mat(cellfun(@(x) ~isempty(x),GoStraight_idx,'UniformOutput',0));
    
    noEvent_idx  = mapTripEvent{:,GoStraight_idx}==1;
    
    tripLen = length(mapTripEvent{:,1});    
    event_Len = sampleLength*WLE_Freq;
    
    % random select 30 of no-event 
    noEvent_num = 30;
    noEventList = {};
    noEvent_counter = 1;
    
    while noEvent_counter<noEvent_num+1
        pickupEvent = randperm(tripLen-event_Len+1,1);        
        this_noEvent_idx = pickupEvent:pickupEvent+event_Len-1;
        this_noEvent = mapTripEvent(this_noEvent_idx,:);
        
        if sum(this_noEvent{:,GoStraight_idx}) ==  event_Len
            % remove selected no-event from original list
            mapTripEvent{this_noEvent_idx,GoStraight_idx} = 0;  
            
            noEventList{noEvent_counter} = this_noEvent;
            noEvent_counter = noEvent_counter+1;
        end
    end
end



