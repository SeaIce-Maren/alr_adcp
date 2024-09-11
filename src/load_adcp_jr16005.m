% Script LOAD_ADCP_JR16005.m loads ALR adcp data from multiple *.log files, and
% concatenates them into a single Matlab structure, saving the output per
% mission
%
% Assumes ALR adcp data files (named *.log) are located in a single
% directory per instrument (upwards or downwards looking) per mission
%
% Calls f_load_adcp.m
%
% Code is built around R. Pawlowicz's ADCP software
%     https://www.eoas.ubc.ca/~rich/#RDADCP
% and requires that package to be on the Matlab path
%
%

% Set directory to input directory - root input directory
datadir = [dataraw,'alrdata/'];

%% DynOPO mission M41;
mnumstr = '41';

% Data directories
adcpdir = [datadir,'M',mnumstr,'/adcp/'];
datadir_dn = [adcpdir,'Adcp300Dn_000/'];
datadir_up = [adcpdir,'Adcp600Dn_000/'];

% Did a kludgy fix in f_load_adcp since the last file here
% Adcp600Dn_040417_231608.log seems to have some problem records
% (only 4775 ensembles, rather than the reported 4783).

% Load ADCP files
disp(['load_adcp: Loading ADCP files in ',datadir_dn])
alladcp_dn = f_load_adcp(datadir_dn);
disp(['load_adcp: Loading ADCP files in ',datadir_up])
alladcp_up = f_load_adcp(datadir_up);

% Save results
outfile = ['M',mnumstr,'_adcp.mat'];
disp(['load_adcp: Saving results to ',[dataint,outfile]])
save([dataint,outfile],'alladcp_dn','alladcp_up');

%% DynOPO mission M42;
mnumstr = '42';

% Data directory
adcpdir = [datadir,'M',mnumstr,'/adcp/'];
datadir_dn = [adcpdir,'Adcp300Dn_000/'];

% Load ADCP files
disp(['load_adcp: Loading ADCP files in ',datadir_dn])
alladcp_dn = f_load_adcp(datadir_dn);
alladcp_up = [];

% Save results
outfile = ['M',mnumstr,'_adcp.mat'];
disp(['load_adcp: Saving results to ',[dataint,outfile]])
save([dataint,outfile],'alladcp_dn','alladcp_up');

%% DynOPO mission M44;
mnumstr = '44';

% Data directories
adcpdir = [datadir,'M',mnumstr,'/adcp/'];
datadir_dn = [adcpdir,'Adcp300Dn_000/'];
datadir_up = [adcpdir,'Adcp600Dn_000/'];

% Load ADCP files
disp(['load_adcp: Loading ADCP files in ',datadir_dn])
alladcp_dn = f_load_adcp(datadir_dn);
disp(['load_adcp: Loading ADCP files in ',datadir_up])
alladcp_up = f_load_adcp(datadir_up);

% Save results
outfile = ['M',mnumstr,'_adcp.mat'];
disp(['load_adcp: Saving results to ',[dataint,outfile]])
save([dataint,outfile],'alladcp_dn','alladcp_up');

