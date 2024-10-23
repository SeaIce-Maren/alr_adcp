% Extracts CTD data from the alrnav file.
%
% Calculate CTD data using the Gibbs Seawater Toolbox
%
% Calls f_calc_ctd, which relies on the Gibbs Seawater Toolbox
%
% Uses the alrnav##.mat file in the dataint directory
%
% 

rootp = split(pwd,filesep);

ALRdatadir = fullfile(rootp{1:end-2},'ALR','ALR_data');%[dataraw,'alrdata/'];
datadir = fullfile(rootp{1:end-2},'alr_adcp','adcp_data');

% add location of toolbpoxes to matlab path
addpath(genpath(fullfile(rootp{1:end-2},'toolboxes')));

% Set some thresholds for bad data
% Data below these thresholds will be removed
minWT = -10;
minWC = 0;





%% Process M137_M138
mnumstr='M137_M138';
infile = fullfile(datadir,['alrnav_',mnumstr,'.mat']);
load(infile,'alrnav');

% Plot the data
[alrctd] = f_calc_ctd(alrnav,minWT,minWC);

save(fullfile(datadir,['alrctd_',mnumstr,'.mat']),'alrctd')
return
%% Process M42
mnumstr='42';
infile = [dataint,'alrnav',mnumstr,'.mat'];
load(infile,'alrnav');

% Plot the data
[alrctd] = f_calc_ctd(alrnav,minWT,minWC);

save([dataint,'alrctd',mnumstr,'.mat'],'alrctd')

%% Process M44
mnumstr='44';
infile = [dataint,'alrnav',mnumstr,'.mat'];
load(infile,'alrnav');

% Plot the data
[alrctd] = f_calc_ctd(alrnav,minWT,minWC);

save([dataint,'alrctd',mnumstr,'.mat'],'alrctd')



