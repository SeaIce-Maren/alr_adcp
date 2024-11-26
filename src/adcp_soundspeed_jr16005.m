% Apply a soundspeed correction
%
% 3. Applying a sound speed correction based on the ALR CTD data. Onboard
% ADCP processing used a temperature sensor, pressure of zero and constant
% salinity of 35. Reprocessing applies the sound speed derived using the
% vehicle depth (AUVDepth, converted from meters to decibars) and the
% uncalibrated Seabird CTD data. Final processing should update this for
% calibrated data, though the differences will be minor.
%
% Calls f_correct_soundspeed (robust_interp1 and expects Gibbs Seawater
% toolbox on the path)


rootp = split(pwd,filesep);

ALRdatadir = fullfile(rootp{1:end-2},'ALR','ALR_data');%[dataraw,'alrdata/'];
datadir = fullfile(rootp{1:end-2},'alr_adcp','adcp_data');

% add location of toolbpoxes to matlab path
addpath(genpath(fullfile(rootp{1:end-2},'toolboxes')));

% Filenaming conventions
filein_suffix = '_adcp_timestamps2.mat';
fileout_suffix = '_adcp_soundspeed3.mat';

mission = {'M131_M132','M135_M136','M137_M138'};

%% Process M41
for mm = 1:length(mission)
mnumstr = mission{mm};



% Load data files
load(fullfile(datadir,['alrctd_',mnumstr,'.mat']),'alrctd');
load(fullfile(datadir,[mnumstr,filein_suffix]));

% Apply a sound speed correction 
[alladcp_dn,alladcp_up] = f_correct_soundspeed(alladcp_dn,alladcp_up,alrctd);

% Save result
disp(['adcp_soundspeed: Saving results to ',datadir,mnumstr,fileout_suffix])
save(fullfile(datadir,[mnumstr,fileout_suffix]),'alladcp_dn','alladcp_up');
clearvars -except mission mm fileout_suffix datadir ALRdatadir rootp filein_suffix
end
return
%% Process M42
mnumstr='42';
% Load data files
load([dataint,'alrctd',mnumstr,'.mat'],'alrctd');
load([dataint,'M',mnumstr,filein_suffix]);

% Apply a sound speed correction 
alladcp_up=[];
[alladcp_dn] = f_correct_soundspeed(alladcp_dn,alladcp_up,alrctd);

% Save result
disp(['adcp_soundspeed: Saving results to ',dataint,'M',mnumstr,fileout_suffix])
save([dataint,'M',mnumstr,fileout_suffix],'alladcp_dn','alladcp_up');

%% Process M44
mnumstr = '44';
% Load data files
load([dataint,'alrctd',mnumstr,'.mat'],'alrctd');
load([dataint,'M',mnumstr,filein_suffix]);

% Apply a sound speed correction 
[alladcp_dn,alladcp_up] = f_correct_soundspeed(alladcp_dn,alladcp_up,alrctd);

% Save result
disp(['adcp_soundspeed: Saving results to ',dataint,'M',mnumstr,fileout_suffix])
save([dataint,'M',mnumstr,fileout_suffix],'alladcp_dn','alladcp_up');
