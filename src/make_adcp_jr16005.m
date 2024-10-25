% Combines upwards and downwards looking ADCPs into a single Matlab
% structure, and adds the depth (rather than relative to AUV position)
%
% Calls f_make_adcp (stc_smooth, robust_interp1)

rootp = split(pwd,filesep);

ALRdatadir = fullfile(rootp{1:end-2},'ALR','ALR_data');%[dataraw,'alrdata/'];
datadir = fullfile(rootp{1:end-2},'alr_adcp','adcp_data');

% add location of toolbpoxes to matlab path
addpath(genpath(fullfile(rootp{1:end-2},'toolboxes')));

% File naming conventions
filein_suffix = '_adcp_clean4.mat';


%% Process M41
mnumstr='M137_M138';
load(fullfile(datadir,['alrnav_',mnumstr,'.mat']),'alrnav');
load(fullfile(datadir,['alrctd_',mnumstr,'.mat']),'alrctd');
load(fullfile(datadir,[mnumstr,filein_suffix]));

%% only do this from north-south transects into the cavity! %%
% this means that e.g. M137_M138 needs to be processed twice, once for the
% "east" transect and once for the "along" transect. Also note that this
% will cause diffculties at the turn around point of the ALR, but since we
% will not be using that data anyway this should not impact results. 

% the reson for this fudge is that on the way into the cavity the ALR
% heading switches between -180 and +180 deg and this seems to cause major
% issues with the bottom track velocity (jumping from +0.6 m/s to -0.6 m/s)
% this then causes issues with the processed ADCP data

alrnav.heading = abs(alrnav.heading);

%% end of fudge, proceed a normal

[adcp] = f_make_adcp(alladcp_dn,alladcp_up,alrnav,alrctd);

% Saving the results
disp(['make_adcp: Saving to ',datadir,'adcp_',mnumstr,'.mat'])
save(fullfile(datadir,['adcp_',mnumstr,'.mat']),'adcp');
return

%% Process M42
mnumstr='42';
load([dataint,'alrnav',mnumstr,'.mat'],'alrnav');
load([dataint,'alrctd',mnumstr,'.mat'],'alrctd');
load([dataint,'M',mnumstr,filein_suffix]);

alladcp_up = [];
[adcp] = f_make_adcp(alladcp_dn,alladcp_up,alrnav,alrctd);

% Saving the results
disp(['make_adcp: Saving to ',dataproc,'adcp',mnumstr,'.mat'])
save([dataproc,'adcp',mnumstr,'.mat'],'adcp');

%% Process M44
mnumstr='44';
load([dataint,'alrnav',mnumstr,'.mat'],'alrnav');
load([dataint,'alrctd',mnumstr,'.mat'],'alrctd');
load([dataint,'M',mnumstr,filein_suffix]);

[adcp] = f_make_adcp(alladcp_dn,alladcp_up,alrnav,alrctd);

% Saving the results
disp(['make_adcp: Saving to ',dataproc,'adcp',mnumstr,'.mat'])
save([dataproc,'adcp',mnumstr,'.mat'],'adcp');

