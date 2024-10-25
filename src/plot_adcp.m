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

load(fullfile(ALRdatadir,'input_plot_diss_fft10_east.mat'),'axE','axEps','axChi');

%% plot results
fgood = figure('units','centimeters','position',[1 1 fw fh],'PaperUnits','centimeters','PaperSize',[fw fh],'PaperPosition',[0 0 fw fh]);
if exist('adcp','var') %down and upward adcp combined
    sp(1) = subplot(5,1,[1 2]);
    pcolor(adcp.time,adcp.depth, adcp.north_vel)
    hold on
    scatter(sci.time, dpthup, ms, sci.sea_current_up_north,'filled','o')
    scatter(sci.time, dpthdn, ms, sci.sea_current_down_north,'filled','o')

    sp(2) = subplot(5,1,[4 5]);
    pcolor(adcp.time,adcp.depth, adcp.east_vel)
    hold on
    scatter(sci.time, dpthup, ms, sci.sea_current_up_east,'filled','o')
    scatter(sci.time, dpthdn, ms, sci.sea_current_down_east,'filled','o')

    sp(3) = subplot(5,1,[3]);
    line(datenum(axE.x),axE.y)


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
for ii = 1:length(sp)

    axes(sp(ii))
    shading flat
    
    grid on
    
    xlim([datenum(goodt(pp,:))])
    datetick('x','HH:MM dd.mm','keeplimits')
    cb = colorbar;
    colormap(cmap)
    clim([-0.3 0.3])
    set(gca,'fontsize',fs)

    ylabel('depth m')
    xlabel('time date')

    if ii == 1
        cb.Label.String = 'North Velocity m/s';
        ylim([700 1100])
        axis ij
    elseif ii == 2
        cb.Label.String = 'East Velocity m/s';
        ylim([700 1100])
        axis ij
    elseif ii == 3
        ylabel('Epsilon W/kg');
        set(gca,'YScale', 'log')
        cb.Visible = 'off';
    end
    
    
end

print(fgood,fullfile(figpath,[mname{pp},'_adcp_data_clean.pdf']),'-dpdf')

%% measured velocity minus depth averaged velocity
fdiv = figure('units','centimeters','position',[1 1 fw fh],'PaperUnits','centimeters','PaperSize',[fw fh],'PaperPosition',[0 0 fw fh]);
if exist('adcp','var') %down and upward adcp combined
    sp(1) = subplot(5,1,[1 2]);
    pcolor(adcp.time,adcp.depth, adcp.north_vel - median(adcp.north_vel,1,'omitnan'))
    hold on

    sp(2) = subplot(5,1,[4 5]);
    pcolor(adcp.time,adcp.depth, adcp.east_vel - median(adcp.east_vel,1,'omitnan'))
    hold on

    sp(3) = subplot(5,1,[3]);
    line(datenum(axE.x),axE.y)
end
for ii = 1:length(sp)

    axes(sp(ii))
    shading flat
    
    grid on
    
    xlim([datenum(goodt(pp,:))])
    datetick('x','HH:MM dd.mm','keeplimits')
    cb = colorbar;
    colormap(cmap)
    clim([-0.1 0.1])
    set(gca,'fontsize',fs)

    if ii == 1
        cb.Label.String = 'North Velocity - median north velocity  m/s';
        axis ij
        ylim([700 1100])
    elseif ii == 2
        cb.Label.String = 'East Velocity - median east velocity m/s';
        axis ij
        ylim([700 1100])
    elseif ii == 3
        ylabel('Epsilon W/kg');
        set(gca,'YScale', 'log')
        cb.Visible = 'off';
    end
    ylabel('depth m')
    xlabel('time date')
end

print(fdiv,fullfile(figpath,[mname{pp},'_diff_adcp_data_clean.pdf']),'-dpdf')

%% calculate shear

ns = median(abs(adcp.north_vel - median(adcp.north_vel,1,'omitnan')),1,'omitnan');
es = median(abs(adcp.east_vel - median(adcp.east_vel,1,'omitnan')),1,'omitnan');
%cut to east transect only
nse = ns(adcp.time >= datenum(goodt(pp,1)) & adcp.time <= datenum(goodt(pp,2)));
ese = es(adcp.time >= datenum(goodt(pp,1)) & adcp.time <= datenum(goodt(pp,2)));
t = adcp.time(adcp.time >= datenum(goodt(pp,1)) & adcp.time <= datenum(goodt(pp,2)));

fsh = figure('units','centimeters','position',[1 1 fw fh],'PaperUnits','centimeters','PaperSize',[fw fh],'PaperPosition',[0 0 fw fh]);
sp(1) = subplot(3,1,1);
line(adcp.time, ns)

sp(2) = subplot(3,1,2);
line(adcp.time, es)

sp(3) = subplot(3,1,3);
line(datenum(axE.x), axE.y)

for ii = 1:length(sp)

    axes(sp(ii))
    
    grid on
    
    xlim([datenum(goodt(pp,:))])
    datetick('x','HH:MM dd.mm','keeplimits')
    set(gca,'fontsize',fs)

    if ii == 1
        ylabel('North Velocity shear m/s');
        
        %ylim([700 1100])
    elseif ii == 2
        ylabel('East Velocity shear');
       
        %ylim([700 1100])
    elseif ii == 3
        ylabel('Epsilon W/kg');
        set(gca,'YScale', 'log')
            end
        xlabel('time date')

end

print(fsh,fullfile(figpath,[mname{pp},'_shear_adcp_data_clean.pdf']),'-dpdf')

figure
subplot(1,2,1)
line(nse(1:2:end),log10(axE.y(1,:)),'linestyle','none','marker','.')
xlabel('north shear m/s')
ylabel('log_{10} Epsilon 1 W/kg')
grid on

subplot(1,2,2)
line(ese(1:2:end),log10(axE.y(1,:)),'linestyle','none','marker','.')
xlabel('east shear m/s')
ylabel('log_{10} Epsilon 1 W/kg')
grid on


% %% lineplot of MARS velocity and my velocity
% % un = sci.sea_current_up_north(2:end);
% % un = reshape(un(1:floor(length(un)/10)*10),10,[]);
% % un = median(un,1,'omitnan');
% un = sci.bottom_track_x(2:end);
% un = reshape(un(1:floor(length(un)/10)*10),10,[]);
% un = median(un,1,'omitnan');
%
% figure('units','centimeters','position',[1 1 fw fh],'PaperUnits','centimeters','PaperSize',[fw fh],'PaperPosition',[0 0 fw fh])
% sp(1) = subplot(4,1,1);
% % line(adcp.time,adcp.north_vel(16,:),'color','k')
% % line(sci.time, sci.sea_current_up_north,'color','b')
% line(adcp.time,abs(adcp.north_vel_bt),'color','k')
% %line(sci.time, sci.sea_current_up_north,'color','b')
% line(sci.time(7:10:end-7), un,'color','b')
% ylabel('North velocity up bin 4 m/s')
% legend('ADCP','MARS')
% title(mname{pp})
%
% sp(2) = subplot(4,1,2);
% line(adcp.time,adcp.east_vel(16,:),'color','k')
% line(sci.time, sci.sea_current_up_east,'color','b')
% ylabel('East velocity up bin 4 m/s')
%
% sp(3) = subplot(4,1,3);
% line(adcp.time,adcp.north_vel(9,:),'color','k')
% line(sci.time, sci.sea_current_up_north,'color','b')
% ylabel('North velocity down bin 4 m/s')
%
%
% sp(4) = subplot(4,1,4);
% line(adcp.time,adcp.east_vel(9,:),'color','k')
% line(sci.time, sci.sea_current_up_east,'color','b')
% ylabel('East velocity down bin 4 m/s')
%
% for ii = 1:4
% axes(sp(ii))
% xlim(datenum(goodt(pp,:)))
% datetick('x','HH:MM dd.mm','keeplimits')
% xlabel('time date')
% end
return
%% plot wihtout removing bad bins
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


