function [alladcp_dn2,alladcp_up2] = f_correct_soundspeed(alladcp_dn2,alladcp_up2,alrctd);
% [alladcp_dn2,alladcp_up2] = f_correct_soundspeed(alladcp_dn2,alladcp_up2,alrnav2);
%
% Correct the soundspeed for the ADCP calculation
%
% Calls robust_interp1 and xpects to find the Gibbs Seawater toolbox on the path
% 
% Updated Jan 2018 - EFW

% Calculate the correction
sound_speed = robust_interp1(alrctd.time,alrctd.sound_speed,alladcp_dn2.time,'linear');
orig_sound_speed1 = gsw_sound_speed(alrctd.SA,alrctd.CT,0);
orig_sound_speed = robust_interp1(alrctd.time,orig_sound_speed1,alladcp_dn2.time,'linear');
% (Should orig sound speed be from the adcp temperature/salinity/pressure?)


% Scale factor for the correction
scale_factor0 = sound_speed./orig_sound_speed;

% Apply the correction
adcp1 = alladcp_dn2;
cnum = length(adcp1.config.ranges);
scale_factor_mat = repmat(scale_factor0,[cnum 1]);
scale_factor_mat4 = repmat(scale_factor0,[4 1]);

adcp1.east_vel = scale_factor_mat.*adcp1.east_vel;
adcp1.north_vel = scale_factor_mat.*adcp1.north_vel;
adcp1.vert_vel = scale_factor_mat.*adcp1.vert_vel;

% This only needs to be applied to the downwards looking
adcp1.bt_vel = scale_factor_mat4.*adcp1.bt_vel;
adcp1.bt_range = scale_factor_mat4.*adcp1.bt_range;

alladcp_dn2 = adcp1;

if length(alladcp_up2)
    adcp1 = alladcp_up2;
    cnum = length(adcp1.config.ranges);
    scale_factor_mat = repmat(scale_factor0,[cnum 1]);
    scale_factor_mat4 = repmat(scale_factor0,[4 1]);
    
    adcp1.east_vel = scale_factor_mat.*adcp1.east_vel;
    adcp1.north_vel = scale_factor_mat.*adcp1.north_vel;
    adcp1.vert_vel = scale_factor_mat.*adcp1.vert_vel;
    
    % This only needs to be applied to the downwards looking
    adcp1.bt_vel = scale_factor_mat4.*adcp1.bt_vel;
    adcp1.bt_range = scale_factor_mat4.*adcp1.bt_range;
    
    alladcp_up2 = adcp1;
end
