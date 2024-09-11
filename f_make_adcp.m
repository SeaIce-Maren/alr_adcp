function [adcp] = f_make_adcp(alladcp_dn,alladcp_up,alrnav,alrctd);
% [adcp] = f_make_adcp(alladcp_dn,alladcp_up,alrnav);
%
% [adcp] = f_make_adcp(alladcp_dn,alrnav);
%
% Combines downward (and upward, if it exists)-looking ADCP data into a
% single Matlab structure, referenced in real earth coordinates, rather
% than relative to the ALR
%
% At the moment, assumes ADCPs are set up with the same bin sizes
%
% Calls fgrid_height_above, stc_smooth, robust_interp1, auv2earth
%
if nargin<4
    alrctd = alrnav;
    alrnav = alladcp_up;
    alladcp_up = [];
end

%% Check timing and truncate
% Boxcar filter to ADCP time, and then subsample to ADCP time
TT = length(alladcp_dn.time);
Zdn = length(alladcp_dn.config.ranges);
if length(alladcp_up)
    Zup = length(alladcp_up.config.ranges);
    if Zdn~=Zup
        error('f_make_adcp: Code is currently written for the same ranges upwards and downwards')
    end
end
adcp1 = alladcp_dn;
dtadcp = nanmedian(diff(alladcp_dn.time));
dtalr = nanmedian(diff(alrnav.time));

% How many samples to average and subsample
NN = round(dtadcp/dtalr);
alrnav2 = stc_smooth(alrnav,NN);

% Should bin/smooth - alrnav2 is 27797 x 1
heading_adcptime = robust_interp1(alrnav2.time,alrnav2.HeadingDeg,adcp1.time,'linear');
depth_adcptime = robust_interp1(alrctd.time,-alrctd.dpth,adcp1.time,'linear');

% Depths are positive downwards
depthmat = repmat(depth_adcptime(:)',[Zdn 1]);
rangesmat = repmat(alladcp_dn.config.ranges,[1 TT]);

% Position
lat_adcptime = robust_interp1(alrnav2.time,alrnav2.LatDegs,adcp1.time,'linear');
lon_adcptime = robust_interp1(alrnav2.time,alrnav2.LngDegs,adcp1.time,'linear');

if length(alladcp_up);
    % Ranges are positive, and depths are positive, so for deeper depths,
    % add positive ranges
    ranges_comb = [flipud(rangesmat); -rangesmat];
else
    ranges_comb = flipud(rangesmat);
end

%% Combine upwards and downards into one depth coordinate
depth_dn = depthmat + rangesmat;
if length(alladcp_up)
    depth_up = depthmat + rangesmat;
end

%% Rotate raw ADCP data from ?forward, starboard, up? to ENU coordinates.
if length(alladcp_up)
    depths_comb = [flipud(depth_dn); depth_up];
else
    depths_comb = flipud(depth_dn);
end
depthvec = nanmean(depths_comb,2);
ZZ=length(depthvec);

if length(alladcp_up)
    starboard_port = [flipud(alladcp_dn.east_vel); alladcp_up.east_vel];
    fore_aft = [flipud(alladcp_dn.north_vel); alladcp_up.north_vel];
    vert_vel = [flipud(alladcp_dn.vert_vel); alladcp_up.vert_vel];
else
    starboard_port = [flipud(alladcp_dn.east_vel)];
    fore_aft = [flipud(alladcp_dn.north_vel)];
    vert_vel = [flipud(alladcp_dn.vert_vel)];
end

% Bottom track velocities
btvel_fa = alladcp_dn.bt_vel(2,:)/1000; % forward aft;
btvel_sp = alladcp_dn.bt_vel(1,:)/1000; % starboard port;

% Clean spikes
ibad = find(abs(btvel_fa)>5); % Larger than 5 m/s
btvel_fa(ibad) = NaN;
btvel_sp(ibad) = NaN;

% Water track velocities: bins 3:5
ibins = find(nanmean(ranges_comb,2)>7&nanmean(ranges_comb,2)<22);
wtvel_fa = nanmean(fore_aft(ibins,:),1);
wtvel_sp = nanmean(starboard_port(ibins,:),1);
btvel_fa(ibad) = wtvel_fa(ibad);
btvel_sp(ibad) = wtvel_sp(ibad);

% Repeat to match the size
btvel_famat = repmat(btvel_fa,[ZZ 1]);
btvel_spmat = repmat(btvel_sp,[ZZ 1]);

% Where bottom track is not available, make an estimate of water track
% velocities!


% subtract bottom track from watertrack
watervel_fa = fore_aft - btvel_famat;
watervel_sp = starboard_port - btvel_spmat;


% Rotate to earth coordinates
% Save these - they are the good ones
[watervel_E,watervel_N] = auv2earth(watervel_sp,watervel_fa,heading_adcptime);


%% Get the height above bottom
cranges = nanmean(ranges_comb,2);
drange = nanmean(diff(alladcp_dn.config.ranges));
if length(alladcp_up)
    drangeup = nanmean(diff(alladcp_up.config.ranges));
    drange = min([drange drangeup]);
end

ibad = find(nanmean(adcp1.bt_range,1)<10);
adcp1.bt_range(:,ibad)=NaN;
height_grid = [0:drange:200]; 
[Evel_height] = fgrid_height_above(adcp1.bt_range,cranges,watervel_E,height_grid);
[Nvel_height] = fgrid_height_above(adcp1.bt_range,cranges,watervel_N,height_grid);

%% Create final - really want to put this back onto the time
% grid with alrnav2?

adcp.time = adcp1.time;
adcp.ranges = nanmean(ranges_comb,2);
adcp.depth = depths_comb;
adcp.lat = robust_interp1(alrnav2.time,alrnav2.LatDegs,adcp.time,'linear');
adcp.lon = robust_interp1(alrnav2.time,alrnav2.LngDegs,adcp.time,'linear');
adcp.east_vel = watervel_E;
adcp.north_vel = watervel_N;
adcp.bt_range = adcp1.bt_range;
adcp.height_grid = height_grid;
adcp.east_velH = Evel_height;
adcp.north_velH = Nvel_height;

disp(['length(adcp.time)=',num2str(length(adcp.time)),', and length(alrnav2.time)=',num2str(length(alrnav2.time))])

function [U,V] = auv2earth(starboard_port,fore_aft,heading1);
% [U,V] = auvcoord2earthcoord(starboard_port,fore_aft,heading1);
%
% Convert starboard_port/fore_aft motion to east-west/north-south
%
heading1 = heading1(:)';
[XX,YY]=size(starboard_port);
yy = length(heading1);

if yy~=YY
    starboard_port = starboard_port';
    fore_aft = fore_aft';
end
[XX,YY]=size(starboard_port);
yy = length(heading1);
if XX>1
    heading1 = repmat(heading1,[XX 1]);
end
if yy~=YY
    error('auv2earth: wrong size inputs')
end


% Calculate the angle and the radius
[th,r] = cart2pol(fore_aft,starboard_port);

% Apply the heading rotation
[V,U] = pol2cart(th+heading1/180*pi,r);

function [velogrid,height_grid] = fgrid_height_above(bt_range,cranges,velo,height_grid);
% Grid some data to height above bottom
%
% Expects the bt_range as a vector [4 beams x TT]
% the cranges as a vector (e.g., 1 x 12 for 12 bins of ADCP data
% and velocity in 12 x TT
%
% Should I be taking the bottom depth in, or the altitude in?
%
% produces velogrid of velocities in terms of height above bottom
%
% Written April 2017 - DynOPO - EFW

if nargin<4
    height_grid = [0:4:100];
end
CC = length(cranges);
%% Get the height above bottom
HH = length(height_grid);
[BB TT] = size(bt_range);
[CC tt] = size(velo);

cc = length(cranges);
if tt~=TT
    error('TT: Should be the same');
elseif CC~=cc
    error('CC: Should be the same');
end
time_index = 1:TT;

bottom_range = nanmean(bt_range,1); % This is a simple average - might be better to clean?
botrangemat = repmat(bottom_range,[CC,1]);

% height
height_above = botrangemat - repmat(cranges,[1 length(bottom_range)]);
ibad = find(height_above<0);
height_above(ibad) = NaN;
% Get the nan's out of there - if set to 1000, then won't be seen by the 
% height_grid criterion
height_above(find(isnan(height_above))) = 1000;

% Grid these
[timemat2,height_grid_mat] = meshgrid(time_index,height_grid);

% Initialise the output
velogrid = vzeros(HH,TT,'NaN');

% Grid into height above bottom
dh=nanmean(diff(height_grid));
for hdo=1:length(height_grid);
    hlim = height_grid(hdo)+dh/2*[-1 1];
    [ii,jj] = find(height_above>=hlim(1)&height_above<hlim(2));
    uj = unique(jj);
    for jdo=1:length(uj)
        ij=find(jj==uj(jdo));
        tmp = nanmean(velo(ii(ij),jj(ij)));
        velogrid(hdo,uj(jdo))=tmp(1);
    end
end