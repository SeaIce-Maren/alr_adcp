function [adcp1] = f_clean_adcp(adcp1);
%  [adcp1] = f_clean_adcp(adcp1);
%
% Clean the ADCP files from a single instrument (upwards or downwards
% instrument) before combining into one file per mission
%
% Written May 2017 - DynOPO JR16005 - EFW
% Updated Jan 2018


% For DynOPO, the ADCPs were set up in ship coordinates.
% RDI manual explains how to interpret the perc_good, intens fields:
%
% Error Velocity: A key quality control parameter that derives from the 
% four beam geometry of an ADCP. Each pair of opposing beams provides 
% one measurement of the vertical velocity and one component of the 
% horizontal velocity, so there are actually two independent measurements 
% of vertical velocity that can be compared. If the flow field is homogeneous, 
% the differ- ence between these vertical velocities will average to zero. 
% To put the error velocity on a more intuitive footing, it is scaled to be 
% comparable to the variance in the horizontal velocity. In a nutshell, the 
% error velocity can be treated as an indication of the standard deviation 
% of the horizontal velocity measurements.



% 2. Clean out the bad stuff using perc_good
% From the RDI Workhorse manual: "In the other coordinate frames (ADCP, 
% Ship and Earth Coordinates), the four Percent Good values represent 
% (in order): 1) The percentage of good three beam solutions (one beam 
% rejected); 2) The percentage of good transformations (error velocity 
% threshold not exceeded); 3) The percentage of measurements where more 
% than one beam was bad; and 4) The percentage of measurements with four 
% beam solutions.
p3 = squeeze(adcp1.perc_good(:,3,:));
p4 = squeeze(adcp1.perc_good(:,4,:));
% Beam intensity on channels 1 & 2 must be less than than 128 - 
% too high, and these are bottom returns.
% Not doing it for the third beam of intens since that's wiping out some
% near vehicle velocities
tmp = squeeze(adcp1.intens(:,1,:))';
tmp2 = squeeze(adcp1.intens(:,2,:))';
tmp3 = squeeze(adcp1.intens(:,3,:))';
ibad1 = find(tmp>128);
ibad2 = find(tmp2>128);
ibad_intens = union(ibad1,ibad2);

% channel 3 was greater than 80
ibad3 = find(p3>80);
% where the percent good field for channel 4 was less than 20
ibad4 = find(p4<20);
ibad_pc = union(ibad3,ibad4);
% Combine all
%ibad = union(ibad_intens,ibad_pc);
ibad = ibad_pc;%test this to see if the pc correnction or the intensity correction is over zealous

% Apply the threshhold
nvel = adcp1.north_vel;
evel = adcp1.east_vel;
% Hang onto the data in case it's needed for diagnostics later
adcp1.north_vel_orig = adcp1.north_vel;
adcp1.east_vel_orig = adcp1.east_vel;

% NaN the bad stuff
nvel(ibad) = NaN;
evel(ibad) = NaN;

% Blank last 3 bins (9-12 for 12-bin setup);
nvel(end-3:end,:) = NaN;
evel(end-3:end,:) = NaN;

% Blank the first bin nearest the vehicle
nvel(1,:) = NaN;
evel(1,:) = NaN;

% Save the good stuff
adcp1.north_vel = nvel;
adcp1.east_vel = evel;




