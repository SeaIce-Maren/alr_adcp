function [adcpdata] = f_load_adcp(datadir);
% [adcpdata] = f_load_adcp(indir);
% Function to concatenate the ADCP data together in time from ALR
%
% adcpdata is the output structure
% datadir is the directory where datafiles (*.000) are located
%
% Note: Does not adjust timestamps, but these may be wrong if the
% instrument clock was incorrectly initialised 
%
% Calls rdradcp.m from the R. Pawlowicz ADCP toolbox, downloaded
% from https://www.eoas.ubc.ca/~rich/#RDADCP
%
% 7 April 2017 - Started during DynOPO EFW
% Jan 2018 - Updated to a function EFW

%% Now parse the whole directory(s)
% Get a directory listing of the files (including data files *.log)
dirlist = dir(datadir);

% counter for the number of measurements; increments between files
zdo = 0;
% Counter for the number of files
qdo = 0;

% Find each valid filename and load it
DD = length(dirlist);
%if sdo==2
%    DD = DD-1;
%end
for ddo=1:DD
    name1 = dirlist(ddo).name;
    %if length(name1)>3&strcmp(name1(end-2:end),'log')
        qdo=qdo+1;
        fname = datadir;%fullfile(,name1);
        
        % Use the R. Pawl. function (rdradcp) to load the ADCP data
        %adcp = rdradcp(example_filename);
        % this creates the structure adcp
        adcp1 = rdradcp(fname);
        % NOTE this function performs some ensemble averaging, set by
        % num_av=5; More average cleans up noisy data, but decreases the 
        % time resolution

        % Identify all the fieldnames
        fnames = fieldnames(adcp1);
        
        % Cycle through each fieldname and concatenate data
        mp = length(adcp1.mtime); % Number of measurements
        alladcp.name = adcp1.name;
        
        %% Cycle through each fieldname and store it
        for fdo=1:length(fnames)
            data1 = getfield(adcp1,fnames{fdo});
            [RR TT ZZ]=size(data1);
            if ZZ==1
                % If the data have TT as the second dimension
                if TT==mp
                    irange = zdo+[1:mp];
                    alladcp = setfield(alladcp,fnames{fdo},{1:RR,irange},data1);
                elseif TT==1
                    % Fields like name (a string) or config (a
                    % structure)
                    alladcp = setfield(alladcp,fnames{fdo},data1);
                end
            else % for the 3-d fields like corr
                if ZZ<mp
                    data1(:,:,mp)=NaN;
                end
                alladcp = setfield(alladcp,fnames{fdo},{1:RR,1:TT,irange},data1);
            end
            
        end
        % Increment measurement counter
        zdo = zdo+mp;
   % end
end
% Get some bad timestamps out
ibad = find(alladcp.mtime<datenum(2000,0,0));
alladcp.mtime(ibad) = NaN;
if isfield(alladcp,'name')
    alladcp=rmfield(alladcp,'name');
end
alladcp.time = alladcp.mtime;
alladcp = rmfield(alladcp,'mtime');
adcpdata = alladcp;


