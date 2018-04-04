function projectData = importOBDData()
% projectData = importOBDData()
% objective: import data from ../data into workspace

%% list datalogger csv file
OBDfileName={'T118_DataLogger.Csv',
             'T122_DataLogger.Csv',
             'T123_DataLogger.Csv',
             'T261_DataLogger.Csv'};
numTrip = length(OBDfileName);
OBDData = cell(numTrip,1);
attrName = {'lat','lng','speed','time'};
attrNum = 5;
samplingRate = 0.1;
for i = 1:numTrip
    OBDData(i) = readOBDdata(['../data/' char(OBDfileName(i))], ...
                attrNum,attrName,'samplingRate',samplingRate);
end

