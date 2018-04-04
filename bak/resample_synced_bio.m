function [bio_resample,bio_re_sec] = resample_synced_bio(filepath,display_flag)

%default desired freq setup
bio_freq = 10;
p = 1;
q = 1;
%expected input time example str 18/07/2017 15:01:12.420
time_format = 'dd/mm/yyyy HH:MM:SS.FFF';
if nargin == 1
    display_flag =0;
end


[bio,bio_time] = xlsread([folder biohar]);
bio_time = bio_time(2:end,:);
bio_sec = datenum(bio_time(:,1),time_format).*(86400);
bio_sec = bio_sec-bio_sec(1);

n = 10*q+1; 
%cutoffRatio = 0.25;
%lpFilt = p * fir1(n, cutoffRatio * 1/q);
[~,bio_re_sec] = resample(bio(:,1),bio_sec,bio_freq,p,q);
bio_resample = zeros(length(bio_re_sec),size(bio,2));

for i = 1:size(bio,2)
    % resample
    bio_resample(:,i) = resample(bio(:,i),bio_sec,bio_freq,p,q);
    % lpf non-linear
    bio_resample(:,i) = smooth(bio_resample(:,i),n,'lowess');
end
%% test 
if display_flag
    for i = 1:34
        fig1 = plot(bio_sec,bio(:,i),'-x'); hold on;
        plot(bio_re_sec,bio_resample(:,i),'-o'); hold off;
        title(['col num2str(' num2str(i) ') of bioharness']);
        legend({['# sample of raw data:' num2str(length(bio_sec))],['# sample of raw data:' num2str(length(bio_re_sec))]});
        pause();    
    end
    close(fig1);
end


