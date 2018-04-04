folder = 'C:\Users\tcyu\Desktop\workspace\537\Project\data\bak\TRI\T118\';
biohar = 'T118_synced_Bioharness.csv';
dataLogger = 'T118_synced_DataLogger.csv';
shimmer = 'T118_synced_Shimmer.csv';

%18/07/2017 15:01:12.420
filepath = [folder biohar];
[bio_resample,bio_re_sec] = resample_synced_bio(filepath);

time_format = 'dd/mm/yyyy HH:MM:SS.FFF';

[bio,bio_time] = xlsread([folder biohar]);
bio_time = bio_time(2:end,:);
bio_sec = datenum(bio_time(:,1),time_format).*(86400);
bio_sec = bio_sec-bio_sec(1);

bio_freq = 10;
p = 1;
q = 1;
[~,bio_re_sec] = resample(bio(:,1),bio_sec,bio_freq,p,q,'spline');
bio_resample = zeros(length(bio_re_sec),size(bio,2));

for i = 1:size(bio,2)
    bio_resample(:,i) = resample(bio(:,i),bio_sec,bio_freq,p,q,'spline');
end
%% test 
for i = 1:34
    fig1 = plot(bio_sec,bio(:,i),'-x'); hold on;
    plot(bio_re_sec,bio_resample(:,i),'-o'); hold off;
    title(['col num2str(' num2str(i) ') of bioharness']);
    legend({['# sample of raw data:' num2str(length(bio_sec))],['# sample of raw data:' num2str(length(bio_re_sec))]});
    pause();    
end


