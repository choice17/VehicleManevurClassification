%% ECE537 Project Main
% Project Title: On road dynamic scenario classification (OBD/physiological) approach
% 12/2/2017
% tcyu@umich.edu

%% Dataset description
% WLE data SongWang Trip1-6 sync data
% relabel video with modified TRI labeling GUI

WLE_Freq = 10;      % 10Hz
EventLength = 5;    % fixed 5 second for each event definition
NumTrip = 6;        % total 6 trips 

% Attributes name
% 1-'time', 2-'speed_mph', 3-'GPS_long_degs', 4-'GPS_lat_degs',
% 5-'GPS_heading_degs', 6-'long_accel_g', 7-'lat_accel_g',
% 8-'vector_accel_g', 
% 9-'vert_accel_g', 10-'hr', 11-'gsr'

% target Class
% 12-'Lane_Change_Left' 13-'Lane_Change_Right' 14-'Turn_Left'
% 15-'Turn_Right' 16-'GoSraight'

%% addpath
addpath ../include;
addpath dataManagement;
addpath normalization;
addpath utility;
addpath modelValidation;
addpath videoLabeling;
addpath featureExtraction;
%% import data
dataPath = '../data/Eventlist/';

%% dataset setup
% sync and mapping label and WLE data
% read script mapTripEvent.m for more details

%% load mapped event list
eventlist = loadEventList(dataPath);

%% generate input/output set
[raw_input_dataset,output_dataset] = genInputOutputSet(eventlist);

%% normalize input set always to column vector
norm_input_dataset = data_normalization(raw_input_dataset);
% signal selection
% featureSet = [2 3 4 6];
 featureSet = 1:10;

input_dataset=cellfun(@(x) x(:,featureSet),norm_input_dataset,'UniformOutput',0);

% statistic feature extraction ----------------- (skip if not using)
input_dataset=cellfun(@(x) featureExtraction(x),input_dataset,'UniformOutput',0);

input_dataset=cellfun(@(x) x(:)',input_dataset,'UniformOutput',0);
input_dataset = cell2mat(cellfun(@(x) x,input_dataset,'UniformOutput',0))';

% global mean and max  normalization after feature extraction;
% option to try global z-normalization
MEANX = mean(input_dataset');
MAXX = max(abs(input_dataset'))+1E-8;
input_dataset = (input_dataset'-MEANX)./MAXX;
input_dataset = mat2cell(input_dataset,ones(1,length(input_dataset(:,1))),120);
%input_dataset = mat2cell(input_dataset,ones(1,length(input_dataset(:,1))),50*length(featureSet));
%trainTestSet.input = cell2mat(cellfun(@(x) x(:)',input_dataset,'UniformOutput',0))';

% one-hot encoded target
trainTestSet.target = output_dataset';

% one digit target class 
dataSize =  length(trainTestSet.target(1,:));
classSize = length(trainTestSet.target(:,1));
y = sum(trainTestSet.target.*repmat((1:classSize)',1,dataSize));
% 10 fold
y_cvPartition = strathRandom(y,10);

% tar_idx = output_dataset(:,end)~=1;
% trainTestSet.target = output_dataset(tar_idx,1:4)';
% trainTestSet.input = trainTestSet.input(:,tar_idx);

%% feature analysis
% checkFeatureAnalysis featureAnalysis.m
% analysis_data = cell2mat(cellfun(@(x) x(:)',input_dataset,'UniformOutput',0))';
% importantFeature = featureAnalysis(analysis_data,y);

% with feature selection ---------
importantFeature = [65 42 67 15 76 40 12 22 19 45 69 81 31 71 43 64 91 38 ...
        34 26 3 75 4  47 33 11 59 115 2 16 9 53 1 5 6];
%importantFeature = 1:120;

trainTestSet.input= cell2mat(cellfun(@(x) x(importantFeature),input_dataset,'UniformOutput',0))';

% without feature selection ---------
%trainTestSet.input = cell2mat(cellfun(@(x) x(:)',input_dataset,'UniformOutput',0))';
%% configure train and testset and network architecture NN
net = patternnet([30],'trainlm');

% init value
%net = configure(net,X',trainTestSet.target);
net = configure(net,trainTestSet.input,trainTestSet.target);

% NN K-fold
[net,results]= nnKFoldVal(y_cvPartition,trainTestSet.input,trainTestSet.target,net);
%[net,results]= nnKFoldVal(y_cvPartition,X',trainTestSet.target,net);

disp(results{end})
%% %% configure SVM
dataSize =  length(trainTestSet.target(1,:));
trainTestSet.y = sum(trainTestSet.target.*repmat((1:classSize)',1,dataSize));
y_cvPartition = strathRandom(y,10);

svm_template = templateSVM('kernelFunction','gaussian','KernelScale',20,'BoxConstraint',1E3);
%svm_template = templateSVM('kernelFunction','linear','BoxConstraint',Inf);

% K-fold validation: 10 for SVM
[model,results]=svmKFoldVal(y_cvPartition,trainTestSet.input,trainTestSet.y,svm_template);
disp(results.k_accuracy);
% r = 1.1
% b = 6  temp optimal
%%

c = cvpartition(456,'KFold',10);
sigma = optimizableVariable('sigma',[1e-5,1e5],'Transform','log');
box = optimizableVariable('box',[1e-5,1e5],'Transform','log');
minfn = @(z)kfoldLoss(fitcsvm(trainTestSet.input',trainTestSet.y,'CVPartition',c,...
    'KernelFunction','rbf','BoxConstraint',z.box,...
    'KernelScale',z.sigma));
results = bayesopt(minfn,[sigma,box],'IsObjectiveDeterministic',true,...
    'AcquisitionFunctionName','expected-improvement-plus')

%%
z(1) = results.XAtMinObjective.sigma;
z(2) = results.XAtMinObjective.box;
SVMModel = fitcsvm(cdata,grp,'KernelFunction','rbf',...
    'KernelScale',z(1),'BoxConstraint',z(2));