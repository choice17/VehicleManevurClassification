function tripInfo = readOBDdata(filename,attrNum,attrName,varargin)
% tripInfo = readOBDdata(filename,attrNum,attrName,varargin)
% input: filename: of OBDfile in csv format
%        attrNum: is the attri coloumn
%        attrName: basic core name 'lat','lng','speed','heading','time'
%        'dataFreq', default 100 Hz
%        'timeRange', [starttime endtime] <- in absolute time ref to Matlab
%        'samplingRate', default 1.0 <- range from 0 to 1

timeFormat = 'mm/dd/yyyy HH:MM:SS PM';
varlen = length(varargin);
OBD.dataFreq = 100;
timeRange = [];
samplingRate = 1;
OBD.attrName = attrName;
for i = 1:2:varlen
    switch varargin{i}
        case 'dataFreq'
            OBD.dataFreq = varargin{i+1};
        case 'timeRange'
            timeRange = varargin{i+1};
        case 'samplingRate'
            samplingRate = varargin{i+1};
    end
end

%% import necessary time
fid  = fopen(filename);
Startime = textscan(fid,'%s',1,'delimiter',',','HeaderLines',2);
OBD.data = textscan(fid,repmat('%s',1,38),'delimiter',',','HeaderLines',4);
fclose(fid);

%% correct and align time information
Startime = char(Startime{:});
timestr = strfind(Startime,':');
timestr = Startime(timestr(1)+2:end);
OBD.StartNum = correctOBDTime(timestr,timeFormat);
OBD.StartTime = datestr(OBD.StartNum);

%% select attrNum into data

OBD.data = OBD.data(attrNum);
timeLen = length(OBD.data{1});
timeAttrNum = cellfun(@(x) ~isempty(x),strfind(attrName,'time'));
OBD.data = cell2mat(cellfun(@(x) str2num(char(x)),OBD.data,'UniformOutput',0));
OBD.data(:,timeAttrNum) = (0:timeLen-1)'./(60*60*24*OBD.dataFreq) + OBD.StartNum;

if ~isempty(timeRange)
    OBD.StartNum = timeRange(1);
    OBD.StartTime = datestr(timeRange(1));
    
    [~,startIdx] = min(abs(OBD.data(:,timeAttrNum)-timeRange(1)));
    [~,endIdx] =  min(abs(OBD.data(:,timeAttrNum)-timeRange(2)));
    OBD.data = OBD.data(startIdx:endIdx,:);
end

if samplingRate~=1
   OBD = reSampleOBD(OBD,samplingRate);
end
   
   OBD.EndTime = datestr(OBD.data(end,timeAttrNum));
   OBD.data = array2table(OBD.data,'VariableName',attrName);
   tripInfo = OBD;




end

function OBDtimeNum = correctOBDTime(timestr,timeFormat)
  if nargin == 1
      timeFormat = 'mm/dd/yyyy HH:MM:SS PM';
  end
  
  timeNum = datenum(timestr,timeFormat);
  DayLightSaving2016.start = datenum('3/13/2016 02:00','mm/dd/yyyy HH:MM');
  DayLightSaving2016.end   = datenum('11/6/2016 02:00','mm/dd/yyyy HH:MM');
  DayLightSaving2017.start = datenum('3/12/2017 02:00','mm/dd/yyyy HH:MM');
  DayLightSaving2017.end   = datenum('11/5/2017 02:00','mm/dd/yyyy HH:MM');
  OBD_summer_diff = 4;
  OBD_winter_diff = 5;
  
  if (timeNum >= DayLightSaving2016.start && timeNum <= DayLightSaving2016.end) ...
      || (timeNum >= DayLightSaving2017.start && timeNum <= DayLightSaving2017.end)
    timeNum = timeNum-(OBD_summer_diff*60*60)/(60*60*24);
  else
    timeNum = timeNum-(OBD_winter_diff*60*60)/(60*60*24);
  end   
  
  OBDtimeNum = timeNum;
end

function out_OBD = reSampleOBD(in_OBD,samplingRate)
    medfiltWindow = 15;
    smoothfiltWindow = 101;
    smoothalg = 'moving';
    degfiltOption.smoothAlg =  'moving';
    degfiltOption.windowSize = 21;
    attrName = in_OBD.attrName;
    attrLen = length(attrName);
    %%
    OBD = in_OBD;
    for attrNum = 1:attrLen
        if strcmp(OBD.attrName{attrNum},'lat')
            OBD.data(:,attrNum) = medfilt1(OBD.data(:,attrNum),medfiltWindow);
            OBD.data(:,attrNum) = smooth(OBD.data(:,attrNum),smoothfiltWindow,smoothalg);
        elseif strcmp(OBD.attrName{attrNum},'lng')
            OBD.data(:,attrNum) = medfilt1(OBD.data(:,attrNum),medfiltWindow);
            OBD.data(:,attrNum) = smooth(OBD.data(:,attrNum),smoothfiltWindow,smoothalg);
        elseif strcmp(OBD.attrName{attrNum},'speed')
            OBD.data(:,attrNum) = OBD.data(:,attrNum)*4/9; % mph to mps * 1.6*1000/3600
            OBD.data(:,attrNum) = medfilt1(OBD.data(:,attrNum),medfiltWindow);
            OBD.data(:,attrNum) = smooth(OBD.data(:,attrNum),smoothfiltWindow,smoothalg);             
        elseif strcmp(OBD.attrName{attrNum},'heading')
            OBD.data(:,attrNum) = medfilt1(OBD.data(:,attrNum),medfiltWindow);
            OBD.data(:,attrNum) = degSmooth(OBD.data(:,attrNum),degfiltOption);            
        elseif strcmp(OBD.attrName{attrNum},'time')
            % do nothing
            OBD.data(:,attrNum) = OBD.data(:,attrNum);
        else
            OBD.data(:,attrNum) = medfilt1(OBD.data(:,attrNum),medfiltWindow);
            OBD.data(:,attrNum) = smooth(OBD.data(:,attrNum),smoothalg,smoothfiltWindow);
        end
    end
    %%
    OBD.data = OBD.data(1:round(1/samplingRate):end,:);
    OBD.dataFreq = OBD.dataFreq*samplingRate;
    
    out_OBD = OBD;
end
