function [adcp1] = f_rotate_adcp(adcp1,rotdeg);
% [adcp1] = f_rotate_adcp(adcp1,rotdeg);
%
% This is a function to correct for the rotation setting in the ADCP setup
% file being incorrect.  For DynOPO JR16005, ALR Mission 41, the adcp
% setting was 90 degrees out of alignment, meaning that the north velocity
% (whcih should correspond to the direction the vehicle is heading) was
% actually in the beam/perpendicular direction).  
%
%
% This could be used to arbitrarily set an angle of alignment on the ADCP,
% but at present only works for the angle of rotdeg=90

if rotdeg==90
    east_vel = adcp1.north_vel;
    north_vel = adcp1.east_vel;
    adcp1.north_vel=north_vel;
    adcp1.east_vel = east_vel;
    
    % Note, we'd normally need to also rotate the bottom track velocities,
    % but for the case noted above (M41), the rotation error was in the
    % upwards looking adcp, so the bt velo are not used.
elseif rotdeg==0
    % Do nothing
else
    error('Has not been written for arbitrary rotation')
end