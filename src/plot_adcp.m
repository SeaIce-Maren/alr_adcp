clc
clear all
close all

rootp = split(pwd,filesep);

ALRdatadir = fullfile(rootp{1:end-2},'ALR','ALR_data');%[dataraw,'alrdata/'];
datadir = fullfile(rootp{1:end-2},'alr_adcp','adcp_data');
figpath = fullfile(rootp{1:end-2},'ALR','ALR_plots');

% add location of toolbpoxes to matlab path
addpath(genpath(fullfile(rootp{1:end-2},'toolboxes')));

cmap = cmocean('balance');

mname = ["center_short","center_long", "east","along"];
pp = 3; %which transect are we plotting

%figure size
fw = 28;
fh = 18;

fs = 12;
ms = 6;%markersize

goodt(1,:) = [datetime(2022, 01, 21, 06, 46, 42) datetime(2022, 01, 22, 00, 30, 05)];%TZ_013 dive 2
goodt(2,:) = [datetime(2022, 02, 02, 05, 12, 19) datetime(2022, 02, 04, 03, 12, 58)];%TZ_020 dive 2
goodt(3,:) = [datetime(2022, 02, 05, 07, 07, 58) datetime(2022, 02, 06, 02, 32, 58)];%TZ_022 dive 2
goodt(4,:) = [datetime(2022, 02, 06, 07, 29, 53) datetime(2022, 02, 06, 15, 11, 43)];%TZ_022 dive 3


load(fullfile(datadir,'adcp_M137_M138.mat'));
sci = readtable(fullfile(datadir,'M137_M138_science.csv'));
sci.time = datenum(datetime(sci.epoch_time,'ConvertFrom','epochtime'));
dpthup = sci.depth-4*8; %depth of fourth bin upwards
dpthdn = sci.depth+4*8;%depth of fourth bin downwards
%load(fullfile(datadir,'M137_M138_adcp.mat'));

fgood = figure('units','centimeters','position',[1 1 fw fh],'PaperUnits','centimeters','PaperSize',[fw fh],'PaperPosition',[0 0 fw fh]);
if exist('adcp','var') %down and upward adcp combined
    sp(1) = subplot(2,1,1);
    pcolor(adcp.time,adcp.depth, adcp.north_vel)
    hold on
    scatter(sci.time, dpthup, ms, sci.sea_current_up_north,'filled','o')
    scatter(sci.time, dpthdn, ms, sci.sea_current_down_north,'filled','o')

    sp(2) = subplot(2,1,2);
    pcolor(adcp.time,adcp.depth, adcp.east_vel)
    hold on
    scatter(sci.time, dpthup, ms, sci.sea_current_up_east,'filled','o')
    scatter(sci.time, dpthdn, ms, sci.sea_current_down_east,'filled','o')

else %if I am working with the down and upwatrd looking adcp separately
    if size(alladcp_up.depth,1)<12 % make placeholder depth structure if depth contains only zeroes
        dpth_up = repmat(alladcp_up.depth,12,1)+900 - [[1:12].*8]';
        dpth_dn = repmat(alladcp_dn.depth,12,1)+900 + [[1:12].*8]';
        alladcp_up.depth = dpth_up;
        alladcp_dn.depth = dpth_dn;
    end
    sp(1) = subplot(2,1,1);
    pcolor(alladcp_up.time,alladcp_up.depth,alladcp_up.north_vel)
    hold on
    pcolor(alladcp_dn.time,alladcp_dn.depth,alladcp_dn.north_vel)

    scatter(sci.time, dpthup, ms, sci.sea_current_up_north,'filled','o')
    scatter(sci.time, dpthdn, ms, sci.sea_current_down_north,'filled','o')


    sp(2) = subplot(2,1,2);
    pcolor(alladcp_up.time,alladcp_up.depth, alladcp_up.east_vel)
    hold on
    pcolor(alladcp_dn.time,alladcp_dn.depth, alladcp_dn.east_vel)

    scatter(sci.time, dpthup, ms, sci.sea_current_up_east,'filled','o')
    scatter(sci.time, dpthdn, ms, sci.sea_current_down_east,'filled','o')
end
for ii = 1:2

    axes(sp(ii))
    shading flat
    axis ij
    grid on
    ylim([700 1100])
    xlim([datenum(goodt(pp,:))])
    datetick('x','HH:MM dd.mm','keeplimits')
    cb = colorbar;
    colormap(cmap)
    clim([-0.3 0.3])
    set(gca,'fontsize',fs)

    if ii == 1
        cb.Label.String = 'North Velocity m/s';
    else
        cb.Label.String = 'East Velocity m/s';
    end
    ylabel('depth m')
    xlabel('time date')
end

print(fgood,fullfile(figpath,[mname{pp},'_adcp_data_clean.pdf']),'-dpdf')

% plot wihtout removing bad bins
figure('units','centimeters','position',[1 1 fw fh],'PaperUnits','centimeters','PaperSize',[fw fh],'PaperPosition',[0 0 fw fh])
if exist('adcp','var') %down and upward adcp combined
    sp(1) = subplot(2,1,1);
    pcolor(adcp.time,adcp.depth, adcp.north_vel_orig)
    title(mname{pp})

    sp(2) = subplot(2,1,2);
    pcolor(adcp.time,adcp.depth, adcp.east_vel_orig)
else %if I am working with the down and upwatrd looking adcp separately
    if size(alladcp_up.depth,1)<12 % make placeholder depth structure if depth contains only zeroes
        dpth_up = repmat(alladcp_up.depth,12,1)+900 - [[1:12].*8]';
        dpth_dn = repmat(alladcp_dn.depth,12,1)+900 + [[1:12].*8]';
        alladcp_up.depth = dpth_up;
        alladcp_dn.depth = dpth_dn;
    end
    sp(1) = subplot(2,1,1);
    pcolor(alladcp_up.time,alladcp_up.depth,alladcp_up.north_vel_orig)
    hold on
    pcolor(alladcp_dn.time,alladcp_dn.depth,alladcp_dn.north_vel_orig)
    title(mname{pp})

    sp(2) = subplot(2,1,2);
    pcolor(alladcp_up.time,alladcp_up.depth, alladcp_up.east_vel_orig)
    hold on
    pcolor(alladcp_dn.time,alladcp_dn.depth, alladcp_dn.east_vel_orig)
end
for ii = 1:2

    axes(sp(ii))
    shading flat
    axis ij
    grid on
    ylim([700 1100])
    xlim([datenum(goodt(pp,:))])
    datetick('x','HH:MM dd.mm','keeplimits')
    cb = colorbar;
    colormap(cmap)
    clim([-0.3 0.3])
    set(gca,'fontsize',fs)

    if ii == 1
        cb.Label.String = 'Original North Velocity m/s';
    else
        cb.Label.String = 'Original East Velocity m/s';
    end
    ylabel('depth m')
    xlabel('time date')
end


