function [this_net,results]= nnKFoldVal(y_cvParition,trainTestSet_input,trainTestSet_target,net)
% K-fold validation for svm
% Input:    y_cvParition - strath sampling index
%           trainTestSet_input
%           trainTestSet_y
%           this_net-init nn architecture
% output:   k-fold model, results

this_net = net;
K_Fold = length(y_cvParition);
k_accuracy = zeros(K_Fold+1,2);

% where K_fold+1 is the final model that take all data
for k_index = 1:K_Fold
    this_net = net;
    %retrieve the k-fold index
    [trainSetIndex,testSetIndex] = KfoldIndexOut(y_cvParition,k_index);
    
    if K_Fold ~= 1
        this_net.divideFcn = 'divideind';
        this_net.divideParam.trainInd = trainSetIndex;
        this_net.divideParam.valInd  = testSetIndex;
        this_net.divideParam.testInd = [];
        this_net.performParam.regularization = 1;
    else 
        this_net.divideFcn = 'dividerand';
        this_net.divideParam.trainratio = 0.8;
        this_net.divideParam.valratio  = 0.1;
        this_net.divideParam.testratio = 0.1;
        this_net.performParam.regularization = 1;
    end
    %% configure training parameter

    this_net.trainParam.showWindow = 1;
    this_net.trainParam.epochs=100;
    this_net.trainParam.max_fail = 7;
    [this_net,net_results] = train(this_net,trainTestSet_input,trainTestSet_target);
    
    train_pred = this_net(trainTestSet_input(:,trainSetIndex));
    train_pred = double(train_pred == max(train_pred));
    fig_train.gt = trainTestSet_target(:,trainSetIndex);
    fig_train.predy = train_pred;
    %fig_train = figure;
    %set(fig_train,'Visible','off');
    %plotconfusion(trainTestSet_target(:,trainSetIndex),train_pred);
    
    test_pred = this_net(trainTestSet_input(:,testSetIndex));
    test_pred = double(test_pred == max(test_pred));
    fig_test.gt = trainTestSet_target(:,testSetIndex);
    fig_test.predy = test_pred;
%     fig_test = figure('fig_test');
%     set(fig_test,'Visible','off');
%     fig_test = plotconfusion(trainTestSet_target(:,testSetIndex),test_pred);
    
    
    k_accuracy(k_index,:) = [sum(sum(fig_train.predy &  fig_train.gt))/length(fig_train.predy) ...
        sum(sum(fig_test.predy &  fig_test.gt))/length(fig_test.predy)];
        
    fig.trainSet = fig_train;
    fig.testSet = fig_test;
    results{k_index}.fig = fig;
    disp([num2str(k_index) ' /' num2str(K_Fold) '...']);
   % pause();
end

k_accuracy(K_Fold+1,:) = mean(k_accuracy(1:K_Fold,:));
results{K_Fold+1} = k_accuracy;
end