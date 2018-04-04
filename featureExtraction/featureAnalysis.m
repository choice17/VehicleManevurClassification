function importantFeature = featureAnalysis(trainTestSet_input,y)
% get top 30 imp features number 
% decision tree feature importance analysis

% decision tree model
treeMdl = fitctree(trainTestSet_input',y');
view(treeMdl,'mode','graph')

% importance feature
imp = predictorImportance(treeMdl);

% get 35 top imp features to plot
[featureImportance,featureIdx] = sort(imp,'descend');
numImpFeature =35;
importantFeature = featureIdx(1:numImpFeature);
plotIdx = 1:numImpFeature;

% plotting
bar(featureImportance(plotIdx));
title('Predictor Importance Estimates');
ylabel('Estimates');
xlabel('Predictors');
axis([1 numImpFeature 0 3e-3])
h = gca;
set(h,'XTick',[1:numImpFeature]);
grid on;
h.XTickLabel = cellfun(@(x) num2str(x), ...
    mat2cell(featureIdx(plotIdx),1,ones(1,length(plotIdx))), ...
    'UniformOutput',0);
h.XTickLabelRotation = 90;
h.TickLabelInterpreter = 'none';

