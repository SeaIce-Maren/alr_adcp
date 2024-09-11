% Cycles through the files provided by Steve:
% 'ALR-RawNavData.mat' and removes or corrects unphysical data
%
% This is a very broad-brush approach - e.g., removes watertemperatures below
% -10, latitude above -30 (based on DynOPO location), and fixes pressure
% skips/time skips where the time stamp on data switches from 0 to 2
% seconds, but data are distinct)
%
% Uses F_CLEAN_ALRNAV.m:
%     Calls F_REGRID_TIME.m - calls robust_interp1.m
%     Calls STC_CUT_INDEX.m
%
% Created April 2017 - DynOPO JR16005 - efw
% Updated Dec 2017 - EFW

% dataraw - Root location of source data (within this, in the alrdata/M##/ subdir)
disp(['clean_alrnav: Expects ALR data to be within ',dataraw,'alrdata/M##/'])

% Boolean
plotflag=0; %to generate figures showing the changes

%% Dynopo M41 % ==============================================
mnumstr = '41';
indir = [dataraw,'M',mnumstr,'/'];
fname = 'ALR-RawNavData.mat';
alrnav = load([indir,fname]);

% Clean pressure skips, timing reversals, 0 lat/lon and unphysical T&S
[alrnav] = f_clean_alrnav(alrnav,plotflag);

% Save results
outfile = [dataint,'alrnav',mnumstr,'.mat'];
disp(['Saving ',outfile])   
save(outfile,'alrnav');

%% Dynopo M42 % ==============================================
mnumstr = '42';
indir = [dataraw,'M',mnumstr,'/'];
fname = 'ALR-RawNavData.mat';
alrnav = load([indir,fname]);

% Clean pressure skips, timing reversals, 0 lat/lon and unphysical T&S
[alrnav] = f_clean_alrnav(alrnav,plotflag);

% Save results
outfile = [dataint,'alrnav',mnumstr,'.mat'];
disp(['Saving ',outfile])
save(outfile,'alrnav');

%% Dynopo M44 % ==============================================
mnumstr = '44';
indir = [dataraw,'M',mnumstr,'/'];
fname = 'ALR-RawNavData.mat';
alrnav = load([indir,fname]);

% Clean pressure skips, timing reversals, 0 lat/lon and unphysical T&S
[alrnav] = f_clean_alrnav(alrnav,plotflag);

% Save results
outfile = [dataint,'alrnav',mnumstr,'.mat'];
disp(['Saving ',outfile])
save(outfile,'alrnav');
