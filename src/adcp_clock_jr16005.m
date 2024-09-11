% 1. Fixes clock offsets from ADCP instrument setup, matching against ALRNAV
% The clocks on the ADCP don't seem to match the timing on the alrnav data
% (based on comparing their heading/pitch, since both the ALR and the ADCP
% have heading/pitch sensors)
%
% 2. Cleans uneven timestamps in ADCP files (due to fast sampling rate)
%
% 3. Corrects for rotation error in setup - this is a special case, which
% applied to M41 on DynOPO, otherwise omit this step
%
%
% Calls f_clock_offset (calls robust_interp1.m)
% Calls f_adcp_time 
% Calls f_rotate_adcp
%
%
% Written April 2017 - DynOPO JR16005 - EFW
% Updated Jan 2018 - EFW

% Plot diagnostics
plotflag=0; % Set to one to turn on plots

% File naming/storage
file_suffix = '_adcp_timestamps2.mat';

%% Process M41
mnumstr = '41';

% Load data
fname = ['alrnav',mnumstr,'.mat'];
load([dataint,fname],'alrnav');
clear alladcp*
load([dataint,'M',mnumstr,'_adcp.mat']);

% Fix clock offsets between ALRNAV and adcp data, Assumes ALR clock is correct, and 
% adjusts ADCP data to it
alladcp_dn = f_clock_offset(alrnav,alladcp_dn,plotflag);
alladcp_up = f_clock_offset(alrnav,alladcp_up,plotflag);
% Clean timing - fills in timeskips
[alladcp_dn,alladcp_up] = f_adcp_time(alladcp_dn,alladcp_up);
% Fix ADCP rotation - special case, if ADCP instrument was setup with wrong
% rotation
rot_upwards = 90; % the heading was incorrectly set on the upwards looking adcp
alladcp_up = f_rotate_adcp(alladcp_up,rot_upwards);

% Save with fixed timestamps
disp(['adcp_clock: Saving results to ',dataint,'M',mnumstr,file_suffix])
save([dataint,'M',mnumstr,file_suffix],'alladcp_dn','alladcp_up')


%% Process M42
mnumstr = '42';

% Load data
fname = ['alrnav',mnumstr,'.mat'];
load([dataint,fname],'alrnav');
clear alladcp*
load([dataint,'M',mnumstr,'_adcp.mat']);

% Fix clock offsets between ALRNAV and adcp data, Assumes ALR clock is correct, and 
alladcp_dn = f_clock_offset(alrnav,alladcp_dn,plotflag);
% Clean timing - fills in timeskips
alladcp_dn = f_adcp_time(alladcp_dn);

% Save with fixed timestamps
disp(['adcp_clock: Saving results to ',dataint,'M',mnumstr,file_suffix])
save([dataint,'M',mnumstr,file_suffix],'alladcp_dn')

%% Process M44
mnumstr = '44';

% Load data
fname = ['alrnav',mnumstr,'.mat'];
load([dataint,fname],'alrnav');
clear alladcp*
load([dataint,'M',mnumstr,'_adcp.mat']);

% Fix clock offsets between ALRNAV and adcp data, Assumes ALR clock is correct, and 
alladcp_dn = f_clock_offset(alrnav,alladcp_dn,plotflag);
alladcp_up = f_clock_offset(alrnav,alladcp_up,plotflag);
% Clean timing - fills in timeskips
[alladcp_dn,alladcp_up] = f_adcp_time(alladcp_dn,alladcp_up);

% Save with fixed timestamps
disp(['adcp_clock: Saving results to ',dataint,'M',mnumstr,file_suffix])
save([dataint,'M',mnumstr,file_suffix],'alladcp_dn','alladcp_up')
