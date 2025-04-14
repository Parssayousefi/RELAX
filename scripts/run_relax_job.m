function run_relax_job(input_set_file, output_dir, config_file, log_file)
%RUN_RELAX_JOB Runs the RELAX preprocessing pipeline for a single dataset.
%   This function is designed to be called by an HPC job script.
%   It loads a configuration file, loads an EEG dataset, sets the output path
%   in the config, and runs the RELAX_Wrapper.
%
%   Args:
%       input_set_file (char): Full path to the input EEGLAB .set file.
%       output_dir (char): Path to the directory where RELAX should save outputs.
%       config_file (char): Full path to the RELAX configuration .m file.
%       log_file (char): Path to a log file (currently unused in basic version).

fprintf('\n--- Starting RELAX Job ---\n');
fprintf('Timestamp: %s\n', datestr(now));
fprintf('Input SET file: %s\n', input_set_file);
fprintf('Output Directory: %s\n', output_dir);
fprintf('Config File: %s\n', config_file);
fprintf('Log File: %s\n', log_file);

% --- Input Checks ---
if ~exist(input_set_file, 'file')
    error('Input SET file not found: %s', input_set_file);
end
if ~exist(config_file, 'file')
    error('Configuration file not found: %s', config_file);
end

% --- Setup Paths (Ensure EEGLAB, RELAX etc. are available) ---
% Assumes paths are set correctly before this script is called
% (e.g., via setup_paths.m in the submission script or user environment)
fprintf('Checking for RELAX_Wrapper function...\n');
if ~exist('RELAX_Wrapper', 'file')
    error('RELAX_Wrapper function not found. Ensure RELAX and dependencies are in the MATLAB path.');
end
fprintf('RELAX_Wrapper found.\n');

% --- Load Configuration ---
fprintf('Loading configuration from: %s\n', config_file);
try
    % Run the config script to get the config struct
    [config_path, config_name, ~] = fileparts(config_file);
    original_dir = pwd;
    cd(config_path);
    config = feval(config_name); 
    cd(original_dir);
    fprintf('Configuration loaded successfully.\n');
catch ME
    error('Failed to load configuration file %s: %s', config_file, ME.message);
end

% --- Set Output Directory in Config --- 
% RELAX often uses config.output_folder to determine save locations
% We set it here based on the job script argument
config.output_folder = output_dir;
fprintf('Set config.output_folder to: %s\n', config.output_folder);
if ~exist(config.output_folder, 'dir')
    fprintf('Creating output directory: %s\n', config.output_folder);
    mkdir(config.output_folder);
end

% --- Add Specific Input File to Config (Using expected field name) ---
config.filename = input_set_file; % RELAX_Wrapper expects this field name
fprintf('Set config.filename to: %s\n', config.filename);

% --- Add myPath field (Needed by RELAX_Wrapper internal logic) ---
[script_path, ~, ~] = fileparts(config_file); % Get scripts dir path
[project_path, ~, ~] = fileparts(script_path); % Go up to project root
config.myPath = project_path;
fprintf('Set config.myPath to: %s\n', config.myPath);

% --- Add empty 'files' field (Workaround for RELAX_Wrapper expecting it) ---
config.files = {}; 
fprintf('Added empty config.files field.\n');

% --- Load Input Dataset --- (REMOVED - RELAX_Wrapper should handle this)
% fprintf('Loading input dataset: %s\n', input_set_file);
% try
%     EEG = pop_loadset('filename', input_set_file);
%     fprintf('Dataset loaded successfully.\n');
% catch ME
%     error('Failed to load dataset %s: %s', input_set_file, ME.message);
% end

% --- Run RELAX Preprocessing ---
fprintf('Starting RELAX_Wrapper...\n');
try
    % RELAX_Wrapper typically saves the processed data based on config settings
    % Pass only the config structure; it should load the data specified by
    % config.specific_input_file_for_wrapper or derive it from other config fields.
    
    RELAX_Wrapper(config);
    fprintf('RELAX_Wrapper completed successfully.\n');
catch ME
    fprintf(2, 'ERROR during RELAX_Wrapper execution!\n'); % Print to stderr
    fprintf(2, 'Error Identifier: %s\n', ME.identifier);
    fprintf(2, 'Error Message: %s\n', ME.message);
    % Print stack trace
    for k=1:length(ME.stack)
        fprintf(2, 'File: %s, Name: %s, Line: %d\n', ME.stack(k).file, ME.stack(k).name, ME.stack(k).line);
    end
    % Rethrow the error to ensure the job fails correctly
    rethrow(ME);
end

fprintf('--- RELAX Job Finished ---\n');
fprintf('Timestamp: %s\n', datestr(now));

% Optional: Add exit command if running purely in batch mode without SLURM
% might automatically exit depending on how matlab -batch is called.
% exit;

end 