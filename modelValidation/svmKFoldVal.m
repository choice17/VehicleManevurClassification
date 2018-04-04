function [outputModel,results]=svmKFoldVal(y_cvParition,trainTestSet_input,trainTestSet_y,svm_template)
% K-fold validation for svm
% Input:    y_cvParition - strath sampling index
%           trainTestSet_input
%           trainTestSet_y
%           svm_template
% output:   k-fold model, results

if nargin ==3
    svm_template = templateSVM('kernelFunction','gaussian','KernelScale','auto');
end

K_Fold = length(y_cvParition);
k_accuracy = zeros(K_Fold+1,2);

% where K_fold+1 is the final model that take all data
for k_index = 1:K_Fold+1  
    
    %retrieve the k-fold index
    [trainSetIndex,testSetIndex] = KfoldIndexOut(y_cvParition,k_index);
    
    %length of the index for reference
    thisTestSet_len = length(testSetIndex);
    thisTrainSet_len = length(trainSetIndex);
    
    %retrieve k-fold training data
    thisTrainSet_input = trainTestSet_input(:,trainSetIndex);
    thisTrainSet_target = trainTestSet_y(trainSetIndex);
    
    %retrieve k-fold testing data
    thisTestSet_input = trainTestSet_input(:,testSetIndex);
    thisTestSet_target = trainTestSet_y(testSetIndex);


    %svm_template = templateSVM('kernelFunction','linear');
    
    [svmModel,~] = fitcecoc(thisTrainSet_input',thisTrainSet_target, ...
        'Learners',svm_template,'Coding','onevsall','Verbose',2);
    
    %prediction on trainset
    trainSet_pred = predict(svmModel,thisTrainSet_input');    
    trainSet_acc = sum(trainSet_pred==thisTrainSet_target')/thisTrainSet_len;
    
    %prediction on testset
    testSet_pred = predict(svmModel,thisTestSet_input');    
    testSet_acc = sum(testSet_pred==thisTestSet_target')/thisTestSet_len;
    
    %store the result
    if k_index ~= K_Fold+1
        k_accuracy(k_index,:) = [trainSet_acc testSet_acc];
    else
         k_accuracy(k_index,:) = [trainSet_acc mean(k_accuracy(1:K_Fold,2))];
    end
    trainPrediction = [trainSetIndex; (trainSet_pred'==thisTrainSet_target)];
    testPrediction = [testSetIndex; testSet_pred'==thisTestSet_target];
    
    prediction_result.trainSet =trainPrediction;
    prediction_result.testSet =testPrediction;
    
    results.k_accuracy = k_accuracy;
    results.prediction_result = prediction_result;
    if k_index == K_Fold+1
        outputModel = svmModel;
    end
end
    