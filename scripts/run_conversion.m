% Script to run BDF to SET conversion for the Chakra project

fprintf('\n### Starting BDF to SET Conversion Runner ###\n');

% --- Configuration ---
% Assumes this script is run from the 'scripts' directory or that 'scripts'
% and necessary toolboxes (EEGLAB) are in the MATLAB path (e.g., via setup_paths.m)

% Define paths relative to the project root
projectBaseDir = fileparts(mfilename('fullpath'));
projectBaseDir = fileparts(projectBaseDir); % Go up one level to project root

rawDataDir = fullfile(projectBaseDir, 'data', 'raw');
outputSetDir = fullfile(projectBaseDir, 'data', 'raw_set');
scriptsDir = fullfile(projectBaseDir, 'scripts');

% *** IMPORTANT: Update this path when the correct file is found ***
% This is the placeholder from config_relax.m, passed to the conversion function
channelLocationFilePath = '/home/s3648540/data_pi-michielvanelkm/Parsa/Chakra/EEG/code/eeglab2025.0.0/functions/supportfiles/channel_location_files/BioSemi64.loc'; 

% List of BDF files to convert (relative to rawDataDir)
% Excludes Scan3 based on experiment setup
bdfFilesToConvert = {'SRS_vs_YRS.bdf', 'YRS_vs_Ajna.bdf', 'YRS_vs_Anahata.bdf', 'YRS_vs_Manipura.bdf'};

% --- Setup Paths (Explicitly run setup_paths.m) ---
fprintf('Explicitly running setup_paths.m...\n');
setup_script_path = fullfile(scriptsDir, 'setup_paths.m');
if exist(setup_script_path, 'file')
    try
        run(setup_script_path);
    catch ME_setup
        error('Error running setup_paths.m: %s', ME_setup.message);
    end
else
    error('setup_paths.m not found at: %s', setup_script_path);
end

% --- Verify Function Availability After Setup ---
if ~exist('convert_bdf_to_set', 'file')
    error('convert_bdf_to_set.m not found in path after running setup_paths.m');
end
if ~exist('pop_biosig', 'file')
    error('EEGLAB function pop_biosig not found after running setup_paths.m. Check setup_paths.m.');
end


% --- Run Conversion Loop ---
fprintf('\nProcessing %d BDF files...\n', length(bdfFilesToConvert));

for i = 1:length(bdfFilesToConvert)
    bdfFilename = bdfFilesToConvert{i};
    inputFilePath = fullfile(rawDataDir, bdfFilename);
    
    [~, baseName, ~] = fileparts(bdfFilename);
    outputFilePath = fullfile(outputSetDir, [baseName, '.set']);
    
    fprintf('\n------------------------------------\n');
    fprintf('Processing file %d: %s\n', i, bdfFilename);
    
    if ~exist(inputFilePath, 'file')
        warning('Input file not found: %s. Skipping.', inputFilePath);
        continue; % Skip to the next file
    end
    
    try
        convert_bdf_to_set(inputFilePath, outputFilePath, channelLocationFilePath);
    catch ME
        warning('Error converting %s: %s. Skipping.', bdfFilename, ME.message);
        % Optional: Log the error more formally
    end
end

fprintf('\n------------------------------------\n');
fprintf('### BDF to SET Conversion Runner Finished ###\n');

% Clear variables
clear projectBaseDir rawDataDir outputSetDir scriptsDir channelLocationFilePath bdfFilesToConvert i bdfFilename inputFilePath baseName outputFilePath ME setup_script_path ME_setup; 