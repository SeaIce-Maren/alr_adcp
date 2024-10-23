function [adcpdata,dt_add_to_adcp] = f_clock_offset(alrnav,adcpdata,plotflag);
% [dt_add_to_adcp,recstr] = f_clock_offset(alrnav,adcpdata,plotflag);
%
% Determine whether there are clock offsets between alrnav and ADCP
% Use alrnav if there are differences
%
% Calls robust_interp1.m
%
% Created April 2017 - DynOPO JR16005 - efw

if nargin<3
    plotflag=0;
end
%% Try to find a variable to compare
adcp_meantime = nanmean(adcpdata.time);
alr_meantime = nanmean(alrnav.time);

% Get a coarse offset
dt_mean = round(alr_meantime - adcp_meantime);

if plotflag
    figure(2);clf
    plot(adcpdata.time+dt_mean,adcpdata.roll.^2+adcpdata.pitch.^2)
    hold on
    plot(alrnav.time,alrnav.pitch.^2+alrnav.roll.^2)
    axis tight
    datetick('x','keeplimits')
end

%% Get increasing time only
dt = diff(alrnav.time);
ibad = find(dt==0);
alrtime2 = alrnav.time;
alrtime2(ibad) = NaN;
alrpitch2 = alrnav.pitch;
alrpitch2(ibad) = NaN;

usedt = .03;
dtvec = dt_mean + [-3:usedt:3];
allR = zeros(size(dtvec))*NaN;
for tdo=1:length(dtvec)
    dt1 = dtvec(tdo);
    
    alrpitch = robust_interp1(alrtime2,alrpitch2,adcpdata.time+dt1,'linear');
    numval=sum(~isnan(alrpitch));
    [M,B,Rsqr] = linearfit(alrpitch,adcpdata.pitch);
    allR(tdo) = sign(M)*sqrt(Rsqr)*sqrt(numval);
end

%% Find the timing
if exist('papersize','file')
    plottools=1;
else
    plottools=0;
end
best_dt = dtvec(find(allR==max(allR),1,'first'));

if plotflag
    figure(1);clf
    subplot(311)
    plot(dtvec,allR)
    xlabel('Days offset')
    ylabel('Correlation in pitch')
    grid on
    set(gca,'tickdir','out')
    % Plot what happened
    subplot(312)
    h1 = plot(adcpdata.time+best_dt,adcpdata.pitch,'linewidth',2);
    hold on
    plot(alrnav.time,alrnav.pitch)
    h = plot(adcpdata.time+best_dt,adcpdata.pitch);set(h,'color',get(h1,'color'));
    h = legend('ADCP pitch','Vehicle pitch','location','northwest');
    
    % Annotate
    title('ALR pitch')
    axis tight
    datetick('x','HH:MM','keeplimits')
    ylabel('Pitch angle [deg]')
    set(gca,'tickdir','out')
    set(h,'box','off');
    grid on; box off
    set(gca,'ylim',[-45 45])
    
    % Roll
    subplot(313)
    h1 = plot(adcpdata.time+best_dt,adcpdata.roll,'linewidth',2);
    hold on
    plot(alrnav.time,alrnav.roll)
    h = plot(adcpdata.time+best_dt,adcpdata.roll);set(h,'color',get(h1,'color'));
    h = legend('ADCP roll','Vehicle roll','location','northwest');
    
    % Annotate
    title('ALR roll')
    axis tight
    datetick('x','HH:MM','keeplimits')
    ylabel('Roll angle [deg]')
    set(gca,'tickdir','out')
    grid on;box off
    set(h,'box','off');
    set(gca,'ylim',[-45 45])
    
    
    if plottools
        fontsize('default')
        papersize('landscape')
        set(gcf,'paperpositionmode','auto')
        %    print('-dpng',[figdir,'alr_adcp_rollpitch.png'])
    end
end

dt_add_to_adcp = best_dt;
if abs(dt_add_to_adcp)<=usedt
    dt_add_to_adcp=0;
end

if dt_add_to_adcp~=0
    recstr=['Consider adding ',num2str(dt_add_to_adcp),' to adcpdata.time'];
else
    recstr=['Clocks aligned between alrnav/adcp.'];
end
disp([recstr,' - ACTIONED'])
adcpdata.time = adcpdata.time + dt_add_to_adcp;

tlim = [min(alrnav.time) max(alrnav.time)];
itime = find(adcpdata.time>=tlim(1)&adcpdata.time<=tlim(2));
tlim(1) = adcpdata.time(itime(1));
tlim(2) = adcpdata.time(itime(2));
disp(['f_clock_offset: Reducing ADCP file to ',datestr(tlim(1)),' - ',datestr(tlim(2))])
adcpdata = stc_cut_index(adcpdata,itime);

function [M,B,Rsqr]=linearfit(x,y);
%LINEARFIT calculates a linear regression and returns slope, intercept and
%r^2, the square of the correlation coefficient
%
%   [M,B,Rsqr]=LINEARFIT(X,Y) calculates a least-squares linear fit to the data
%   Y(X).  Returns the slope M, y-intercept B and r^2 value.  X and Y must
%   be the same length.
%
%
%   M = sum{ (x-xbar)(y-ybar) } / sum{ (x-xbar).^2 }
%   B = ybar - M*xbar;
%

if (nargin<2)
    y = x;
    x = 1:length(y);
elseif length(x)~=length(y)
    error('linearfit: expects vectors of the same length');
end
nrange = find(~isnan(x));
x=x(nrange);
y=y(nrange);
nrange=find(~isnan(y));
x=x(nrange);
y=y(nrange);
x=x(:);
y=y(:);

xbar = mean(x);
ybar = mean(y);
xanom = x-xbar;
yanom = y-ybar;

sxy = sum(xanom.*yanom);
sxx = sum(xanom.^2);

M = sxy/sxx;
B = ybar - M*xbar;

inan=find(~isnan(x+y));
ybar2=mean(y(inan));
newY = M*x+B;

SSerr = nansum((y(inan)-newY(inan)).^2);
SStot = nansum((y(inan)-ybar2).^2);
Rsqr = 1-SSerr/SStot;

%y=mx+b
%x=1/m y -b/m
% Calculates the correlation coefficient as in Random Data, p. 126 (1971
% version)
meanx=nanmean(x);
meany=nanmean(y);
N=length(x);
sxy = nansum(x.*y)-N*meanx*meany;
sx = nansum(x.^2)-N*meanx^2;
sy = nansum(y.^2)-N*meany^2;

rxy = sxy/sqrt(sx*sy);


function structout = stc_cut_index(structin,irange);
% structin = stc_cut_index(structin,irange)
%
% Inputs structin structure and irange indices corresponding to the subset of
% structin vector data to retain.  This is used in CLEAN_ADCP.m to remove all
% data where lat/lon or time information are missing.
%
% Note: Could have bad behavior if there is a lot of missing position data
% In which case, skip this in clean_adcp.m or adapt it to interpolate
% positions/times using alternate information
%
% Retain data only when the indices are included.
% works primarily on vector data
%
% Created April 2017 - DynOPO JR16005 - EFW
fnames = fieldnames(structin);
structout = struct;
if isfield(structin,'Days_Matlab')
    mp = length(structin.Days_Matlab);
elseif isfield(structin,'mtime');
    mp = length(structin.mtime);
elseif isfield(structin,'time');
    mp = length(structin.time);
end

% Cycle through all fieldnames.
for fdo = 1:length(fnames)
    data1 = getfield(structin,fnames{fdo});
    [AA,BB,CC] = size(data1);
    if AA==mp
        data3 = data1(irange,:,:);
    elseif BB==mp
        data3 = data1(:,irange,:);
    elseif CC==mp
        data3 = data1(:,:,irange);
    else
        data3 = data1;
    end
    structout = setfield(structout,fnames{fdo},data3);
    
end
