function [alrclean] = clean_alrnav(alrnav,plotflag);
% [alrclean] = clean_alrnav(alrnav,plotflag);
% Uses the alrnav structure and takes care of a few issues:
%    - CTD data: Removes data where temperature < -50, Conductivity<-50
%    - Position: Removes lat/lon of zeros
%
% Cleans up the ALRNAV file as provided by Steve McPhail on the DynOPO
% cruise JR16005.
%
% Calls f_regrid_time.m - calls robust_interp1
% Removed: Calls sw routines (CSIRO version, not TEOS10 - could be updated)
%
% Created April 2017 - EFW
% Updated Dec 2017 - EFW

% Might want to set these
maxLat = -30; % Maximum latitude (anything higher will be NaNed)
maxLon = -30; % Maximum longitude (anything higher will be NaNed)
assumed_alr_sampleinterval_in_seconds = 1; % Steve McPhail had this at 1sec on DynOPO

alrnav.time = alrnav.Days_Matlab;
alrnav = rmfield(alrnav,'Days_Matlab');

%% Remove zero positions
disp('Removing zero lat/lon values')
alrnav2 = alrnav;
alrnav2.LngDegs(find(alrnav.LngDegs>maxLon)) = NaN;
alrnav2.LatDegs(find(alrnav.LatDegs>maxLat)) = NaN;

if plotflag
    figure(2);clf
    subplot(211)
    plot(alrnav.LngDegs,'o')
    hold on
    plot(alrnav2.LngDegs,'linewidth',2)
    title(['Cleaning Longitude'])
    ylabel('LngDegs')
    axis tight
    subplot(212)
    plot(alrnav.LatDegs,'o')
    hold on
    plot(alrnav2.LatDegs,'linewidth',2)
    axis tight
    title(['Cleaning Latitude'])
    ylabel('LatDegs')
end

%% Clean up pressure skips - should probably average
disp('Cleaning up pressure skips, due to some pressure reversals...')
dp = diff(alrnav2.AUVDepth);
izero = find(dp==0);
inon = find(dp~=0);

% Interpolate over the zeros?
AUVDepth = alrnav2.AUVDepth;
AUVDepth(izero) = NaN;
% Replace, and these will be interpolated over next
alrnav2.AUVDepth=AUVDepth;

if plotflag
    figure(3);clf
    subplot(211)
    plot(alrnav.AUVDepth,'o')
    hold on
    plot(alrnav2.AUVDepth,'linewidth',2)
    axis tight
    ylabel('AUVDepth')
    title(['Pressure'])
    subplot(212)
    plot(diff(alrnav.AUVDepth),'o')
    hold on
    plot(diff(alrnav2.AUVDepth),'linewidth',2)
    axis tight
    ylabel('diff(AUVDepth)')
    title(['Pressure difference'])
end

%% Clean up timing skips
sec2day = 1/86400;
dt = diff(alrnav2.time);
toobig = 1.5*assumed_alr_sampleinterval_in_seconds;
toosmall = .5*assumed_alr_sampleinterval_in_seconds;
i2 = find(dt>toobig*sec2day);
i0 = find(dt<toosmall*sec2day);
time_corrected = alrnav2.time;

disp('Cleaning up timing reversals...')

% Clean up time skips in the alrnav data file
for tdo=1:length(i2)
    i20 = i2(tdo);
    if sum(i20+1==i0)
        dt0 = mean(dt(i20:i20+1));
        time_corrected(i20:i20+1) = time_corrected(i20-1)+dt0*[1:2];
    elseif sum(i20+2==i0)
        dt0 = mean(dt(i20:i20+2));
        time_corrected(i20:i20+2) = time_corrected(i20-1)+dt0*[1:3];
    elseif sum(i20+3==i0)
        dt0 = mean(dt(i20:i20+3));
        time_corrected(i20:i20+3) = time_corrected(i20-1)+dt0*[1:4];
    end
end
dt = diff(time_corrected);
i2 = find(dt>toobig*sec2day);
i0 = find(dt<toosmall*sec2day);
for tdo=1:length(i0)
    i00 = i0(tdo);
    if sum(i00+1==i2)
        dt0 = mean(dt(i00:i00+1));
        time_corrected(i00:i00+1) = time_corrected(i00-1)+dt0*[1:2];
    elseif sum(i00+2==i2)
        dt0 = mean(dt(i00:i00+2));
        time_corrected(i00:i00+2) = time_corrected(i00-1)+dt0*[1:3];
    elseif sum(i00+3==i2)
        dt0 = mean(dt(i00:i00+3));
        time_corrected(i00:i00+3) = time_corrected(i00-1)+dt0*[1:4];
    end
end

%% Would really like to remove the parts where the primary data (time and
% place) are NaN
inan = find(isnan(alrnav2.LngDegs+alrnav2.LatDegs+alrnav2.time));
igood = setdiff(1:length(alrnav2.LngDegs),inan);
alrnav2 = stc_cut_index(alrnav2,igood);


%% Remove data before the dive and after the surface
% Find the first data below 5 m, then the last time it was deeper than 2 m,
% before it got deeper than 5 m (to identify the start of the dive)
alrnav = alrnav2;
ifirst = find(alrnav.AUVDepth>5,1,'first');
istart = find(alrnav.AUVDepth(1:ifirst)<2,1,'last');

LL = length(alrnav.AUVDepth);

ilast = find(alrnav.AUVDepth>5,1,'last');
iend1 = find(alrnav.AUVDepth(ilast:end)<2,1,'first');
index = ilast:LL;
iend = index(iend1);

ibad = union([1:istart-1],[iend+1:LL]);
igood = istart:iend;

if plotflag
    figure(1);clf
    subplot(211)
    plot(alrnav.AUVDepth,'linewidth',2)
    axis tight;
    title('AUVDepth [dbar]')
    subplot(212)
    plot(alrnav.AUVDepth,'linewidth',2)
    axis tight;
    ylabel('AUVDepth [dbar]')
    
    subplot(211)
    set(gca,'xlim',[1 ifirst])
    ylim=get(gca,'ylim');
    hold on
    plot(istart*[1 1],ylim,'r');
    
    % Find the last data below 5 m
    subplot(212)
    hold on
    set(gca,'xlim',[ilast LL])
    ylim=get(gca,'ylim');
    plot(iend*[1 1],ylim,'r')
end
% Reduce to where the ALR was underwater
alrnav2 = stc_cut_index(alrnav,igood);

% Further remove datawhere the PropRPM is zero?
inonzero=find(alrnav2.PropRPM~=0);
alrnav2 = stc_cut_index(alrnav2,inonzero);


%% Any of the rest, just ditch them? or interpolate across them
% f_regrid_time interpolates across
disp(['Interpolate over timing skips that weren''t easily corrected...'])
dtmedian = nanmedian(diff(time_corrected));
tgrid = [alrnav2.time(1):dtmedian:alrnav2.time(end)]';
[utime,I] = unique(alrnav2.time);
alrnav2 = f_regrid_time(alrnav2,tgrid);

if plotflag
    figure(4);clf
    plot(diff(alrnav.time),'o')
    hold on
    plot(diff(alrnav2.time),'linewidth',2)
    ylabel(['diff(time)'])
end


% Output variable rename
alrclean = alrnav2;


function alrnav2 = f_regrid_time(alrnav,tgrid);
% alrnav = f_regrid_time(alrnav,tgrid);
%
% Inputs alrnav structure and the time grid (tgrid) to interpolate onto
% 
% Linearly interpolates onto a new time grid
%
% Created April 2017 for ALR data on JR16005/DynOPO - EFW
fnames = fieldnames(alrnav);
time = alrnav.time; fname='time';

% Find the time vectors
[utime,I] = unique(time);
mp=length(time);
alrnav2 = struct([]);
alrnav2 = setfield(alrnav2,{1},fname,tgrid);
T2=length(tgrid);

% Interpolate anything of the right size..
for fdo=1:length(fnames)
    data1 = getfield(alrnav,fnames{fdo});
    clear data2
    [TT,XX,ZZ] = size(data1);
    if length(data1)~=mp
        alrnav2 = setfield(alrnav2,fnames{fdo},data1);
    elseif ZZ==1 % 2 dim matrix
        imatch = find([TT XX]==mp);
        if imatch==1
            for xdo=1:XX
                data2(:,xdo) = robust_interp1(utime,data1(I,xdo),tgrid,'linear');
            end
            alrnav2 = setfield(alrnav2,fnames{fdo},data2);
        elseif imatch==2
            for tdo=1:TT
                data2(tdo,:) = robust_interp1(utime,data1(tdo,I),tgrid,'linear');
            end
            alrnav2 = setfield(alrnav2,fnames{fdo},data2);
        end
    else % 3 dim matrix
        imatch = find([TT XX ZZ]==mp);
        if imatch==3
            dataXXTT = reshape(data1,[TT*XX ZZ]);
            for qdo=1:TT*XX
                data2XXTT(qdo,:) = robust_interp1(utime,dataXXTT(qdo,I),tgrid,'linear');
            end
            data2 = reshape(data2XXTT,[TT XX T2]);
            alrnav2 = setfield(alrnav2,fnames{fdo},data2);
        end
    end
end

alrnav2 = setfield(alrnav2,{1},fname,tgrid);

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