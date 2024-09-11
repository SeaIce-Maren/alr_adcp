function [alrctd] = f_calc_ctd(alrnav,minWT,minWC);
% [alrctd,alrnav] = f_calc_ctd(alrnav);
%
% Expects to find the Gibbs Seawater toolbox on the path.
% GSW TEOS10 seawater routines - http://www.teos-10.org/software.htm

% Removing really bad T/S
%
if nargin<3
    minWC = -10; % Minimum WaterConductivity, in alrnav data
    if nargin<2
        minWT = 0; % Minimum WaterTemperature, in alrnav data
    end
end
disp(['alrctd: Removing CTD data where WaterTemperature < ',num2str(minWT),' and WaterConductivity < ',num2str(minWC)])

ibad = find(alrnav.WaterTemperature<minWT|alrnav.WaterConductivity<minWC);
alrnav2 = alrnav;
alrnav2.WaterTemperature(ibad) = NaN;
alrnav2.WaterConductivity(ibad) = NaN;
alrnav2.Salinity(ibad) = NaN;
alrnav2.WaterDensity(ibad) = NaN;
inan = find(~isnan(alrnav.WaterTemperature));
disp(['- This removed ',num2str(length(ibad)),' points of ',num2str(length(inan)),' total'])

%% Calculate SA, CT
% Use the Gibbs Seawater toolbox
% Note that AUVDepth is in units of dbar
alrnav = alrnav2;
SP = gsw_SP_from_C(alrnav.WaterConductivity,alrnav.WaterTemperature,alrnav.AUVDepth);
SA = gsw_SA_from_SP(SP,alrnav.AUVDepth,alrnav.LatDegs,alrnav.LngDegs);
CT = gsw_CT_from_t(SA,alrnav.WaterTemperature,alrnav.AUVDepth);
Z = gsw_z_from_p(alrnav.AUVDepth,alrnav.LatDegs);
sound_speed = gsw_sound_speed(SA,CT,alrnav.AUVDepth);

alrctd.time = alrnav.time;
alrctd.temp = alrnav.WaterTemperature;
alrctd.cond = alrnav.WaterConductivity;
alrctd.lat = alrnav.LatDegs;
alrctd.lon = alrnav.LngDegs;
alrctd.pres = alrnav.AUVDepth;
alrctd.SA = SA;
alrctd.CT = CT;
alrctd.dpth = Z;
alrctd.sound_speed = sound_speed;
