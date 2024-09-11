% Creates 1 minute averages of water velocity parallel to ALR for the
% MicroRider processing
%
% Calls robust_interp1, stc_smooth, f_smooth_wind
% 
% Requires Gibbs seawater toolbox
%

% Create a v5 for Kurt, no data QC
% Filenaming conventions
filein_suffix = '_adcp_soundspeed3.mat';
fileout_prefix= 'alr_speed_M';

%% Process M42
mnumstr='42';
% Load data files
load([dataint,'M',mnumstr,filein_suffix],'alladcp_dn')
load([dataint,'alrnav',mnumstr,'.mat'])

alr_speed = f_adcp_microrider(alladcp_dn,alrnav);

% Save the results
disp(['adcp_for_micro: Saving to ',dataint,fileout_prefix,mnumstr,'v5.mat'])
save([dataint,fileout_prefix,mnumstr,'v5.mat'],'alr_speed');

%% Process M44
mnumstr='44';
% Load data files
load([dataint,'M',mnumstr,filein_suffix],'alladcp_dn')
load([dataint,'alrnav',mnumstr,'.mat'])

alr_speed = f_adcp_microrider(alladcp_dn,alrnav);

% Save the results
disp(['adcp_for_micro: Saving to ',dataint,fileout_prefix,mnumstr,'v5.mat'])
save([dataint,fileout_prefix,mnumstr,'v5.mat'],'alr_speed');

