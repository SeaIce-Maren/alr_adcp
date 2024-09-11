function structout = stc_smooth(structin,NN);
% structout = stc_smooth(structin,NN);
%
% Simple function to apply a moving window/running average filter to the
% structin data, and then subselect by every NN values.
%
% EFW - DynOPO 2017 (eleanorfrajka@gmail.com)

% Create the boxcar window and normalise
mywin = rectwin(NN);
mywin= mywin/nansum(mywin);

% Convolve a boxcar and subsample
fnames = fieldnames(structin);
time = structin.time;
% this was before the time vector had been fixed in structin
[utime,I] = unique(time);
mp = length(time);

% Subsample ranges
irange = floor(NN/2):NN:mp;
% Set the first output, time, which needs no subsampling (but wouldn't be
% harmed by it, as long as the time vector were evenly spaced and
% monotonic -- actually, the time vector is smoothed and subsampled below,
% since `Days_Matlab' is one of the fieldnames in fnames
structout.time = structin.time(irange);

% Smooth
for fdo=1:length(fnames)
    data1 = getfield(structin,fnames{fdo});
    [TT,XX ] = size(data1);
    if length(data1)~=mp
        structout = setfield(structout,fnames{fdo},data1);
    elseif TT==mp
        data2 = conv(data1,mywin,'valid');
        % Different subsample range as above, since the `valid' option
        % on convolution results in the 1st datapoint being the middle
        % of the first smoothed window
        irange = 1:NN:length(data2);
        
        data3 = data2(irange);
        structout = setfield(structout,fnames{fdo},data3(:));
    end
end