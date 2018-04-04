function featureGen = featureExtraction(cell_data)
%Objective: generate statistical feature of time series data
%input: data in a cell, [length of event, number of signal]= size(cell_data)
%output: features for time series data, [features,num of sig] = featureGen

    numSelectedSig = size(cell_data,2);
    lenFeatureWindow = size(cell_data,1);
    numFeature = 12;
    featureGen = zeros(numFeature,numSelectedSig);  
   
    selectedSig =    cell_data - mean(cell_data); % remove the mean value, hong
    
    % 1. zero crossing
    featureGen(1, :) = sum(abs(diff(selectedSig >=0)))/(lenFeatureWindow - 1); 
    % 2. max
    featureGen(2, :) = max(selectedSig);
    % 3. min
    featureGen(3, :) = min(selectedSig);
    % 4. t+delta_t
    featureGen(4, :) = selectedSig(end, :) - selectedSig(end - (lenFeatureWindow/10) + 1, :);
    % 5. std
    featureGen(5, :) = std(selectedSig);
    % 6. iqr interquatile range
    featureGen(6, :) = iqr(selectedSig); 
    % 7. median
    featureGen(7, :) = median(selectedSig);
    % 8. energy
    featureGen(8, :) = sum(abs(selectedSig).^2);
    % 9. skewness
    featureGen(9, :) = skewness(selectedSig);
    % 10. kurtosis
    featureGen(10, :) = kurtosis(selectedSig);
    % 11. std of first deviation 
    featureGen(11, :) = std(diff(selectedSig)); 
    % 12. rms of first deviation
    featureGen(12, :) = sqrt( sum ( (abs (diff (selectedSig) ) ).^2 )./(lenFeatureWindow - 1) );  
        
    