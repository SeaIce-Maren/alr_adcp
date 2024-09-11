% Combines upwards and downwards looking ADCPs into a single Matlab
% structure, and adds the depth (rather than relative to AUV position)
%
% Calls f_make_adcp (stc_smooth, robust_interp1)

% File naming conventions
filein_suffix = '_adcp_clean4.mat';


%% Process M41
mnumstr='41';
load([dataint,'alrnav',mnumstr,'.mat'],'alrnav');
load([dataint,'alrctd',mnumstr,'.mat'],'alrctd');
load([dataint,'M',mnumstr,filein_suffix]);

[adcp] = f_make_adcp(alladcp_dn,alladcp_up,alrnav,alrctd);

% Saving the results
disp(['make_adcp: Saving to ',dataproc,'adcp',mnumstr,'.mat'])
save([dataproc,'adcp',mnumstr,'.mat'],'adcp');

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

