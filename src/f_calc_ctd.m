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

ibad = find(alrnav.ctd_1_temperature<minWT | alrnav.ctd_2_temperature<minWT | ...
    alrnav.ctd_1_conductivity<minWC | alrnav.ctd_2_conductivity<minWC);
alrnav2 = alrnav;
alrnav2.ctd_1_temperature(ibad) = NaN;
alrnav2.ctd_2_temperature(ibad) = NaN;
alrnav2.ctd_1_conductivity(ibad) = NaN;
alrnav2.ctd_2_conductivity(ibad) = NaN;
SP1 = gsw_SP_from_C(alrnav2.ctd_1_conductivity,alrnav2.ctd_1_temperature, alrnav2.ctd_1_pressure);
SP2 = gsw_SP_from_C(alrnav2.ctd_2_conductivity,alrnav2.ctd_2_temperature, alrnav2.ctd_2_pressure);
SA1 = gsw_SA_from_SP(SP1,alrnav2.ctd_1_pressure,alrnav2.longitude, alrnav2.latitude);
SA2 = gsw_SA_from_SP(SP2,alrnav2.ctd_2_pressure,alrnav2.longitude, alrnav2.latitude);
rho1 = gsw_rho(SA1, gsw_CT_from_t(SA1,alrnav2.ctd_1_temperature,alrnav2.ctd_1_pressure),alrnav2.ctd_1_pressure);
rho2 = gsw_rho(SA2, gsw_CT_from_t(SA2,alrnav2.ctd_2_temperature,alrnav2.ctd_2_pressure),alrnav2.ctd_2_pressure);
alrnav2.WaterDensity1 = rho1;
alrnav2.WaterDensity2 = rho2;
inan = find(~isnan(alrnav.ctd_1_temperature));
disp(['- This removed ',num2str(length(ibad)),' points of ',num2str(length(inan)),' total'])

%% Calculate SA, CT
% Use the Gibbs Seawater toolbox
% Note that AUVDepth is in units of dbar
alrnav = alrnav2;
% SP = gsw_SP_from_C(alrnav.WaterConductivity,alrnav.WaterTemperature,alrnav.AUVDepth);
% SA = gsw_SA_from_SP(SP,alrnav.AUVDepth,alrnav.LatDegs,alrnav.LngDegs);
CT1 = gsw_CT_from_t(SA1,alrnav.ctd_1_temperature,alrnav.ctd_1_pressure);
CT2 = gsw_CT_from_t(SA2,alrnav.ctd_2_temperature,alrnav.ctd_2_pressure);
Z1 = gsw_z_from_p(alrnav.ctd_1_pressure,alrnav.latitude);
Z2 = gsw_z_from_p(alrnav.ctd_2_pressure,alrnav.latitude);
sound_speed1 = gsw_sound_speed(SA1,CT1,alrnav.ctd_1_pressure);
sound_speed2 = gsw_sound_speed(SA2,CT2,alrnav.ctd_2_pressure);

alrctd.time = alrnav.time;
alrctd.temp = alrnav.ctd_1_temperature;
alrctd.cond = alrnav.ctd_1_conductivity;
alrctd.temp2 = alrnav.ctd_2_temperature;
alrctd.cond2 = alrnav.ctd_2_conductivity;
alrctd.lat = alrnav.latitude;
alrctd.lon = alrnav.longitude;
alrctd.pres = alrnav.ctd_1_pressure;
alrctd.pres2 = alrnav.ctd_2_pressure;
alrctd.SA = SA1;
alrctd.CT = CT1;
alrctd.SA2 = SA2;
alrctd.CT2 = CT2;
alrctd.dpth = Z1;
alrctd.dpth2 = Z2;
alrctd.sound_speed = sound_speed1;
alrctd.sound_speed2 = sound_speed2;
