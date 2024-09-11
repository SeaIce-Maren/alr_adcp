% A series of scripts to load and clean raw ALR data.
%
% End result - 
% Cleaned (not calibrated) ALR ctd data, dataint/alrctd##.mat
% Cleaned ALRNav data, dataint/alrnav##.mat
% Cleaned ADCP data, dataproc/adcp##.mat
%
% Filenames with jr16005 are cruise-specific and should be edited
%
% Functions typically start with an f* or, if they work on structures, stc*
%
% Multiple dependencies as noted below ("Calls ...")
% + requires ADCP processing software from Rich Pawlowicz:
% https://www.eoas.ubc.ca/~rich/#RDADCP
% + requires Gibbs TEOS10 seawater toolbox 
% http://www.teos-10.org/software.htm
%
% Updated Jan 2018 - EFW

%% Directory structure expected for input data:
% Raw datasets
dataraw = '../../data/raw/alrdata/';
% ALR data from Steve as:
% dataraw/M##/ALR-RawNavData.mat
% ADCP data from Steve as *.log files in
% dataraw/M##/adcp/Adcp300Dn_000/ - update in load_adcp
% MicroRider data from Rob as *.P files & SETUP.CFG in
% dataraw/M##/microrider/

% Set paths for output data locations 
% Interim datasets - multiple intermediate steps saved here:
dataint = '../../data/interim/';
% Processed datasets - cleaned/calibrated datasets saved here:
dataproc = '../../data/processed/';

%% Load and clean ALRNAV data
% Calls f_clean_alrnav.m (robust_interp1.m)
% 
% clean_alrnav_jr16005 - Creates alrnav##.mat
clean_alrnav_jr16005; 

%% Extract CTD data, calculate soundspeed and requires Gibbs Seawater
% Calls f_calc_ctd, which relies on the Gibbs Seawater Toolbox
%
% Toolbox % GSW TEOS10 seawater routines - http://www.teos-10.org/software.htm
addpath(genpath(['/Users/eddifying/Dropbox/research/tools-matlab/gsw_matlab_v3_01/']))

% make_alrctd_jr16005 - Uses alrnav##.mat - Creates alrctd##.mat
make_alrctd_jr16005;

%% Load ADCP data
% Calls f_load_adcp, which relies on Rich Pawlowicz' ADCP software
%
% Takes a few minutes to run (maybe 2-5 min per 24 hr mission)
% Requires R. Pawlowicz's ADCP software - https://www.eoas.ubc.ca/~rich/#RDADCP
addpath(genpath(['/Users/eddifying/Dropbox/research/tools-matlab/RDADCP_mar10v0/']))

% load_adcp_jr16005 - Creates M##_adcp.mat
if 0 % Once they're loaded, don't keep loading every time the data are being processed
    load_adcp_jr16005;
end

%% ADCP clock offsets - matched to ALRNAV time
% Calls f_clock_offset (calls robust_interp1.m)
% Calls f_adcp_time 
% Calls f_rotate_adcp
%
% adcp_clock_jr16005 - Uses alrnav##.mat, M##_adcp.mat - Creates M##_adcp_timestamps2.mat
adcp_clock_jr16005;

% Apply soundspeed correction 
% Calls f_correct_soundspeed (robust_interp1.m and expects Gibbs Seawater
% toolbox on the path)
% Toolbox % GSW TEOS10 seawater routines - http://www.teos-10.org/software.htm
%
% adcp_soundspeed - Creates M##_adcp_soundspeed3.mat
adcp_soundspeed_jr16005;

% Create 1 minute averages of the soundspeed corrected velocity parallel to ALR body, uses
% bins 2:4 from the downward looking ADCP.
% Calls robust_interp1, stc_smooth, f_smooth_wind
%
% adcp_for_micro - Creates alr_speed_M##v5.mat
adcp_for_micro_jr16005;

% Clean data - Flags out bad stuff
% Calls f_clean_adcp
%
% clean_adcp - Creates M##_adcp_clean4.mat
clean_adcp_jr16005;

%% Combine ADCP into single file, with ALR depth
% Calls f_make_adcp (stc_smooth, robust_interp1)
%
% make_adcp - Creates dataproc/adcp##.mat
make_adcp_jr16005;
