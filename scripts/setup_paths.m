% MATLAB Startup Script for RELAX EEG Preprocessing Project
% Adds necessary toolboxes and checks for dependencies.

fprintf('Setting up MATLAB paths for RELAX project...\n');

% Define base project directory (assuming this script is in project/scripts)
projectBaseDir = fileparts(mfilename('fullpath'));
projectBaseDir = fileparts(projectBaseDir); % Go up one level to project root

% --- Add Core Toolboxes ---

% Add EEGLAB path (adjust folder name if necessary)
eeglabPath = fullfile(projectBaseDir, 'code', 'eeglab2025.0.0');
if exist(eeglabPath, 'dir')
    fprintf('Adding EEGLAB path: %s\n', eeglabPath);
    addpath(eeglabPath);
else
    warning('EEGLAB directory not found: %s', eeglabPath);
end

% Initialize EEGLAB to set its own paths (plugins etc.)
% Running nogui and close all prevents GUI popups in batch mode
fprintf('Initializing EEGLAB (nogui)...\n');
try
    eeglab nogui;
    close all; % Close any figures EEGLAB might open
catch ME
    warning('Error initializing EEGLAB: %s', ME.message);
end

% Add RELAX path
relaxPath = fullfile(projectBaseDir, 'code', 'relax');
if exist(relaxPath, 'dir')
    fprintf('Adding RELAX path: %s\n', relaxPath);
    addpath(genpath(relaxPath)); % Use genpath to include subfolders
else
    warning('RELAX directory not found: %s', relaxPath);
end

% Add Fieldtrip path
fieldtripPath = fullfile(projectBaseDir, 'code', 'fieldtrip');
if exist(fieldtripPath, 'dir')
    fprintf('Adding Fieldtrip path: %s\n', fieldtripPath);
    addpath(genpath(fieldtripPath)); % Use genpath
    fprintf('Running ft_defaults...\n');
    ft_defaults; % Suppress Fieldtrip startup messages
else
    warning('Fieldtrip directory not found: %s', fieldtripPath);
end

% --- Add Dependencies ---

% Add MWF Toolbox path
mwfPath = fullfile(projectBaseDir, 'code', 'dependencies', 'mwf-toolbox');
if exist(mwfPath, 'dir')
    fprintf('Adding MWF Toolbox path: %s\n', mwfPath);
    addpath(genpath(mwfPath));
else
    warning('MWF Toolbox directory not found: %s', mwfPath);
end

% Add FastICA path (assuming FastICA is used)
fasticaPath = fullfile(projectBaseDir, 'code', 'dependencies', 'fastica');
if exist(fasticaPath, 'dir')
    fprintf('Adding FastICA path: %s\n', fasticaPath);
    addpath(genpath(fasticaPath));
else
    warning('FastICA directory not found: %s. If using PICARD, this is expected.', fasticaPath);
end

% --- Add Project Scripts ---
scriptsPath = fullfile(projectBaseDir, 'scripts');
if exist(scriptsPath, 'dir')
    fprintf('Adding project scripts path: %s\n', scriptsPath);
    addpath(scriptsPath);
else
    warning('Project scripts directory not found: %s', scriptsPath);
end

% --- Check for Required MATLAB Toolboxes ---
requiredToolboxes = {'Signal Processing Toolbox', ...
                     'Statistics and Machine Learning Toolbox', ...
                     'Wavelet Toolbox'};
% Optional but recommended
optionalToolboxes = {'Image Processing Toolbox'}; 

installedToolboxes = ver; % Get list of installed toolboxes
installedToolboxNames = {installedToolboxes.Name};

fprintf('\nChecking for required MATLAB toolboxes:\n');
allRequiredFound = true;
for i = 1:length(requiredToolboxes)
    toolboxName = requiredToolboxes{i};
    if ~any(strcmp(toolboxName, installedToolboxNames))
        warning('Required MATLAB Toolbox NOT FOUND: %s', toolboxName);
        allRequiredFound = false;
    else
        fprintf('  Found: %s\n', toolboxName);
    end
end

fprintf('\nChecking for optional MATLAB toolboxes:\n');
for i = 1:length(optionalToolboxes)
    toolboxName = optionalToolboxes{i};
    if ~any(strcmp(toolboxName, installedToolboxNames))
        fprintf('  Optional toolbox NOT FOUND: %s\n', toolboxName);
    else
        fprintf('  Found: %s\n', toolboxName);
    end
end

if ~allRequiredFound
    error('One or more required MATLAB toolboxes were not found. Please install them.');
else
    fprintf('\nAll required MATLAB toolboxes found.\n');
end

fprintf('MATLAB path setup complete.\n\n');

% Clear temporary variables
clear projectBaseDir eeglabPath relaxPath fieldtripPath mwfPath fasticaPath scriptsPath requiredToolboxes optionalToolboxes installedToolboxes installedToolboxNames allRequiredFound i toolboxName ME; 