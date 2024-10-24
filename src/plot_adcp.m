clc
clear all 
close all

rootp = split(pwd,filesep);

ALRdatadir = fullfile(rootp{1:end-2},'ALR','ALR_data');%[dataraw,'alrdata/'];
datadir = fullfile(rootp{1:end-2},'alr_adcp','adcp_data');

% add location of toolbpoxes to matlab path
addpath(genpath(fullfile(rootp{1:end-2},'toolboxes')));

cmap = cmocean('balance');

mname = ["center_short","center_long", "east","along"];

goodt(1,:) = [datetime(2022, 01, 21, 06, 46, 42) datetime(2022, 01, 22, 00, 30, 05)];%TZ_013 dive 2
goodt(2,:) = [datetime(2022, 02, 02, 05, 12, 19) datetime(2022, 02, 04, 03, 12, 58)];%TZ_020 dive 2
goodt(3,:) = [datetime(2022, 02, 05, 07, 07, 58) datetime(2022, 02, 06, 02, 32, 58)];%TZ_022 dive 2
goodt(4,:) = [datetime(2022, 02, 06, 07, 29, 53) datetime(2022, 02, 06, 15, 11, 43)];%TZ_022 dive 3


load(fullfile(datadir,'adcp_M137_M138.mat'));

figure
sp(1) = subplot(2,1,1);
pcolor(adcp.time,adcp.depth, adcp.north_vel)

sp(2) = subplot(2,1,2);
pcolor(adcp.time,adcp.depth, adcp.east_vel)

for ii = 1:2

axes(sp(ii))
shading flat
axis ij
ylim([700 1100])
xlim([datenum(goodt(3,:))])
datetick('x','HH:MM dd.mm','keeplimits')
cb = colorbar;
colormap(cmap)
clim([-1 1])

if ii == 1
    cb.Label.String = 'North Velocity m/s';
else
cb.Label.String = 'East Velocity m/s';
end
ylabel('depth m')
xlabel('time date')
end


