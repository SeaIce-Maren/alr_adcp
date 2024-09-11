function structout = f_regrid_time_nearest(structin,tgrid);
% structin = f_regrid_time_nearest(structin,tgrid);
%

% Skip
resnames = {'name'};
% Linearly interpolates onto a new time grid
fnames = fieldnames(structin);
if isfield(structin,'Days_Matlab')
    % for alrnav
    time = structin.Days_Matlab;
    fname = 'Days_Matlab';
elseif isfield(structin,'mtime')
    % for adcp data
    time = structin.mtime;
    fname = 'mtime';
elseif isfield(structin,'time');
    time = structin.time;
    fname='time';
end

% Find the time vectors
[utime,I] = unique(time);
ifinite = find(isfinite(utime));
utime = utime(ifinite);
I = I(ifinite);
mp=length(time);
structout = struct([]);
structout = setfield(structout,{1},fname,tgrid);
T2 = length(tgrid);

% Interpolate anything of the right size onto the new time vector
% this is anything that originally had a length dimension that was the same
% as the old time vector
for fdo=1:length(fnames)
    data1 = getfield(structin,fnames{fdo});
    clear data2
    [TT,XX,ZZ] = size(data1);
    if length(data1)~=mp
        structout = setfield(structout,fnames{fdo},data1);
    elseif ZZ==1 % 2 dim matrix
        imatch = find([TT XX]==mp);
        if imatch==1
            for xdo=1:XX
                data2(:,xdo) = interp1(utime,data1(I,xdo),tgrid,'nearest');
            end
            structout = setfield(structout,fnames{fdo},data2);
        elseif imatch==2
            for tdo=1:TT
                data2(tdo,:) = interp1(utime,data1(tdo,I),tgrid,'nearest');
            end
            structout = setfield(structout,fnames{fdo},data2);
        end
    else % 3 dim matrix
        imatch = find([TT XX ZZ]==mp);
        if imatch==3
            dataXXTT = reshape(data1,[TT*XX ZZ]);
            for qdo=1:TT*XX
                data2XXTT(qdo,:) = interp1(utime,dataXXTT(qdo,I),tgrid,'nearest');
            end
            data2 = reshape(data2XXTT,[TT XX T2]);
            structout = setfield(structout,fnames{fdo},data2);
        end
    end
end

structout = setfield(structout,{1},fname,tgrid);
