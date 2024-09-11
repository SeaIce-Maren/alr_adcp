function [alr_speed] = f_adcp_microrider(adcp1,alrnav);
% [alr_speed] = f_adcp_microrider(adcp1,alrnav);
%
%
% Calls robust_interp1, f_smooth_wind, stc_smooth, 
%
% Requires the Gibbs Seawater toolbox on the path

% Set up parameters for f_smooth_wind
Nsmo = 60/86400; % bin average - 1 minute
p1 = 0; % boxcar

%% Average velocity in a few bins near the vehicle
sp_velave_raw = nanmean(adcp1.east_vel(2:4,:));
fa_velave_raw = nanmean(adcp1.north_vel(2:4,:));

wz_velave_raw = nanmean(adcp1.vert_vel(2:4,:));
dpth = gsw_z_from_p(alrnav.AUVDepth,alrnav.LatDegs);
dpdt = diff(dpth)./diff(alrnav.time);
dpdt = dpdt/86400; % Convert to dbar/sec

%% Calculate w parallel
dtalr = nanmean(diff(alrnav.time));
dtadcp = nanmean(diff(adcp1.time));
NN = floor(dtadcp/dtalr);
alrsmo = stc_smooth(alrnav,NN);
pitch_10s = robust_interp1(alrsmo.time,alrsmo.PitchDeg,adcp1.time,'nearest');
[paravel_raw,perpvel_raw] = fw2alr_velo(fa_velave_raw,wz_velave_raw,pitch_10s);

%% Unwrap heading - Heading diagnostics
HeadingRad = alrnav.HeadingDeg*pi/180;
hdg2 = unwrap(HeadingRad);
med1 = nanmedian(hdg2);
med1_2pi = round(med1/2/pi)*2*pi;
hdg2 = hdg2-med1_2pi;
alrnav2=alrnav;
hdg2deg = 180/pi*hdg2;
alrnav2.HeadingDeg = hdg2deg;
alrsmo = stc_smooth(alrnav2,NN);
heading_10 = alrsmo.HeadingDeg;
pitch_10 = alrsmo.PitchDeg;
pitch_1min = f_smooth_wind(alrsmo.time,pitch_10,Nsmo,p1);
heading_1min = f_smooth_wind(alrsmo.time,heading_10,Nsmo,p1);

%% Make 1 min averages
paravel_1min = f_smooth_wind(adcp1.time,paravel_raw,Nsmo,p1);
perpvel_1min = f_smooth_wind(adcp1.time,perpvel_raw,Nsmo,p1);
foreaft_1min = f_smooth_wind(adcp1.time,fa_velave_raw,Nsmo,p1);
vertvel_1min = f_smooth_wind(adcp1.time,wz_velave_raw,Nsmo,p1);

%% Save for Kurt - Store 1 min averages
alr_speed.time = alrnav.time;
alr_speed.speed = robust_interp1(adcp1.time,paravel_1min,alrnav.time,'linear');
alr_speed.perp = robust_interp1(adcp1.time,perpvel_1min,alrnav.time,'linear');
% Don't need to interpolate these
alr_speed.heading = heading_1min;
alr_speed.pitch = pitch_1min;
%alr_speed.headingvar = headingvar_1min;
%alr_speed.pitchvar = pitchvar_1min;
alr_speed.fore = robust_interp1(adcp1.time,foreaft_1min,alrnav.time,'linear');
alr_speed.vert = robust_interp1(adcp1.time,vertvel_1min,alrnav.time,'linear');
alr_speed.version = 'v5';
alr_speed.notes = {'speed: mean of 2nd-4th bin of downward-looking ADCP (foreaft and vert vel)',...
    'projecting using pitch onto the parallel and perp vector rel to ALR body',...
    'Then filtered w/1 min boxcar & linearly interpolated onto alrnav time',...
    'Added some heading/pitch diagnostics'};
alr_speed.changed = {'Projection onto parallel direction',...
    'Added quite a few new fields.  Units are Matlab time, m/s and degrees',...
    'No more QC, as per Kurt''s request'};
alr_speed.needs_changing = '';

function [walr,perp1] = fw2alr_velo(fore_aft,vert_vel,pitch1);
% [walr] = fw2alr_velo(fore_aft,vert_vel,pitch1);
%
% Convert fore_aft/vert_vel motion to w parallel to ALR, pitched at pitch1
% degrees
%
pitch1 = pitch1(:)';

[XX,YY]=size(fore_aft);
yy = length(pitch1);

if yy~=YY
    vert_vel = vert_vel';
    fore_aft = fore_aft';
end
[XX,YY]=size(fore_aft);
yy = length(pitch1);
if XX>1
    pitch1 = repmat(pitch1,[XX 1]);
end
if yy~=YY
    error('forew2alr_velo: wrong size inputs')
end


% Calculate the angle and the radius
[th,r] = cart2pol(fore_aft,vert_vel);

% Apply the heading rotation
[walr,perp1] = pol2cart(th-pitch1/180*pi,r);