function   input_dataset_norm = data_normalization(input_dataset)
% normlization on the data

input_dataset_norm = cellfun(@(x) cellData_normalization(x),input_dataset, ...
    'UniformOutput',0);

end


