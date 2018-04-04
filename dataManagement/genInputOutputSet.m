function [input_dataset,output_dataset] = genInputOutputSet(eventList)
% Objective: generate input output set
% input: extract event list (event/no-event), cell list 
% output: input/output dataset, 

% attri idx
% 1-'time', 2-'speed_mph', 3-'GPS_long_degs', 4-'GPS_lat_degs',
% 5-'GPS_heading_degs', 6-'long_accel_g', 7-'lat_accel_g',
% 8-'vector_accel_g', 9-'vert_accel_g', 10-'hr', 11-'gsr'
attri_idx = 2:11;

% output idx
% 12-'Lane_Change_Left' 13-'Lane_Change_Right' 14-'Turn_Left'
% 15-'Turn_Right' 16-'GoSraight'
output_idx = 12:16;

% hold all the event into the list
eventList_sum = {};

% flag to check if 
hasNextTrip = 1;
trip_num = 1;
while hasNextTrip
    try
        eventList_sum = [eventList_sum eventList.(['trip' num2str(trip_num)]).eventList];
        eventList_sum = [eventList_sum eventList.(['trip' num2str(trip_num)]).noEventList];        
    catch
        hasNextTrip = 0;
    end
    trip_num = trip_num+1;
end


input_dataset =cellfun(@(x) x{:,attri_idx},eventList_sum','UniformOutput',0);
output_dataset = cell2mat(cellfun(@(x) x{1,output_idx}',eventList_sum,'UniformOutput',0))';

end
    