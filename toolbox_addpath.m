function toolbox_addpath()

    % Add system related functions paths
    cur = fileparts(mfilename('fullpath'));

    if isempty(cur)
        cur = pwd;
    end 

    addpath(genpath(fullfile(cur, 'matlab')));

    % Add useful custom functions path
    addpath(fullfile(cur, 'matlab', 'utils'));

    % Add examples folder
    addpath(fullfile(cur, 'examples'));

end 
