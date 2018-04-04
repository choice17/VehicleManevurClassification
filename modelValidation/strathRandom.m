function y_cvPartition = strathRandom(y,num_fold)

% strath random parition
if size(y,1)==1 || size(y,2) == 1
    yLen = length(y);
    numClass = length(unique(y));
    uniqueClassLen = zeros(1,numClass);
    
    for i = 1:numClass
        uniqueClassLen(i) = sum(y==i);
    end
    
    y_randomIdx = randperm(yLen);
    idxRatio_inOneFold = 1/num_fold;
    
    % initialization
    y_cvPartition = cell(1,num_fold);
    
    
    % strathfield sampling
    for i = 1:num_fold
          for j = 1:numClass           

            classFoldIdx = round(uniqueClassLen(j)*idxRatio_inOneFold);
            if i~=num_fold
                thisPartitionIdx = (1+classFoldIdx*(i-1)):classFoldIdx*i;
            else
              % last fold take the rest
              thisPartitionIdx = (1+classFoldIdx*(i-1)):uniqueClassLen(j);
            end
            temp_class_partitionIdx = y_randomIdx(y(y_randomIdx)==j);
            temp_class_partitionIdx = temp_class_partitionIdx(thisPartitionIdx);

            y_cvPartition{i} =  [y_cvPartition{i} temp_class_partitionIdx];
          end        
        
    end
end
            
            
            