% Extracts CTD data from the alrnav file.
%
% Calculate CTD data using the Gibbs Seawater Toolbox
%
% Calls f_calc_ctd, which relies on the Gibbs Seawater Toolbox
%
% Uses the alrnav##.mat file in the dataint directory
%
% 

% Set some thresholds for bad data
% Data below these thresholds will be removed
minWT = -10;
minWC = 0;


%% Process M41
mnumstr='41';
infile = [dataint,'alrnav',mnumstr,'.mat'];
load(infile,'alrnav');

% Plot the data
[alrctd] = f_calc_ctd(alrnav,minWT,minWC);

save([dataint,'alrctd',mnumstr,'.mat'],'alrctd')

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



