% clean_adcp_jr16005
%
% 2. Removing bad data.  Beam intensity on channels 1
% and 2 was used, where a minimum threshold of 128 intensity for returns
% was required, otherwise velocity data were discarded. Additionally,
% where the percent good field for channel 4 was less than 20, and for
% channel 3 was greater than 80, the data were flagged as bad.
%
% Blanking bins near the vehicle and at distance - NOTE THIS MAY DEPEND
% ON HOW THE ADCP IS SETUP.  We had 12 bins.  Could also have 24 bins, and
% these choices may need to be updated
% The bin nearest the vehicle in both upwards and downwards looking ADCP
% datasets needed to be blanked. Near the bottom in the downwards looking
% ADCP, there were clearly bad bins (large amplitude, large variance). To
% remove these, several choices were made: bins 9-12 were blanked (distance 74-98 m).
%
%
%
% Calls f_clean_adcp 
%

% Filenaming conventions
filein_suffix = '_adcp_soundspeed3.mat';
fileout_suffix = '_adcp_clean4.mat';

%% Clean M41
mnumstr='41';
% Load data files
load([dataint,'M',mnumstr,filein_suffix]);

% Clear out bad bins
alladcp_dn = f_clean_adcp(alladcp_dn);
alladcp_up = f_clean_adcp(alladcp_up);

% Save the results
disp(['clean_adcp: Saving to ',dataint,'M',mnumstr,fileout_suffix])
save([dataint,'M',mnumstr,fileout_suffix],'alladcp_dn','alladcp_up')

%% Clean M42
mnumstr='42';
% Load data files
load([dataint,'M',mnumstr,filein_suffix]);

% Clear out bad bins
alladcp_dn = f_clean_adcp(alladcp_dn);

% Save the results
disp(['clean_adcp: Saving to ',dataint,'M',mnumstr,fileout_suffix])
save([dataint,'M',mnumstr,fileout_suffix],'alladcp_dn')

%% Clean M44
mnumstr='44';
% Load data files
load([dataint,'M',mnumstr,filein_suffix]);

% Clear out bad bins
alladcp_dn = f_clean_adcp(alladcp_dn);
alladcp_up = f_clean_adcp(alladcp_up);

% Save the results
disp(['clean_adcp: Saving to ',dataint,'M',mnumstr,fileout_suffix])
save([dataint,'M',mnumstr,fileout_suffix],'alladcp_dn','alladcp_up')