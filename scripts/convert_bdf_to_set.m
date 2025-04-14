function convert_bdf_to_set(input_bdf_file, output_set_filepath, channel_location_file)
%CONVERT_BDF_TO_SET Converts a BDF file to EEGLAB SET format, adding channel locations.
%   Loads a BioSemi BDF file using pop_biosig, adds channel locations using
%   pop_chanedit, and saves the result as a .set file.
%
%   Args:
%       input_bdf_file (char): Full path to the input BDF file.
%       output_set_filepath (char): Full path for the output SET file (e.g., '../data/raw_set/Scan1.set').
%       channel_location_file (char): Full path to the channel location file (.sfp, .elc, etc.).

fprintf('\n--- Starting BDF to SET Conversion ---\n');
fprintf('Input BDF: %s\n', input_bdf_file);
fprintf('Output SET: %s\n', output_set_filepath);
fprintf('Channel Loc File: %s\n', channel_location_file);

% --- Input Checks ---
if ~exist(input_bdf_file, 'file')
    error('Input BDF file not found: %s', input_bdf_file);
end

if isempty(channel_location_file)
   warning('Channel location file path is empty. Proceeding without adding locations.');
   use_chanlocs = false;
elseif ~exist(channel_location_file, 'file')
    warning('Channel location file not found: %s. Proceeding without adding locations.', channel_location_file);
    use_chanlocs = false;
else
    use_chanlocs = true;
end

% --- Create Output Directory ---
[output_dir, output_filename, output_ext] = fileparts(output_set_filepath);
if ~exist(output_dir, 'dir')
    fprintf('Creating output directory: %s\n', output_dir);
    mkdir(output_dir);
end

% Ensure output file has .set extension
output_filename_set = [output_filename, '.set'];
output_full_path_set = fullfile(output_dir, output_filename_set);

% --- Load BDF Data ---
fprintf('Loading BDF file using pop_biosig...\n');
try
    % Note: 'ref' and 'refoptions' might be needed depending on BioSemi setup
    % Example: EEG = pop_biosig(input_bdf_file, 'ref', [65 66], 'refoptions', {'keepref' 'off'}); % If using earlobes EXG4/5 as ref during import
    EEG = pop_biosig(input_bdf_file);
    fprintf('BDF file loaded successfully.\n');
catch ME
    error('Failed to load BDF file %s: %s', input_bdf_file, ME.message);
end

% Store original filename
EEG.filename_original = input_bdf_file;

% --- Add Channel Locations ---
if use_chanlocs
    fprintf('Loading channel locations from: %s\n', channel_location_file);
    try
        % Use 'autodetect' for file type, common for .sfp or .elc
        % Consider specifying 'filetype', 'sfp' or 'filetype', 'polhemus' if needed
        EEG = pop_chanedit(EEG, 'load', {channel_location_file, 'filetype', 'autodetect'});
        fprintf('Channel locations loaded successfully.\n');
    catch ME
        warning('Failed to load channel locations from %s: %s. SET file will be saved without explicit locations.', channel_location_file, ME.message);
    end
else
     fprintf('Skipping channel location loading as file was not found or specified.\n');
end

% --- Save SET File ---
fprintf('Saving SET file to: %s\n', output_full_path_set);
try
    EEG = pop_saveset(EEG, 'filename', output_filename_set, 'filepath', output_dir);
    fprintf('SET file saved successfully.\n');
catch ME
    error('Failed to save SET file %s: %s', output_full_path_set, ME.message);
end

fprintf('--- Conversion Complete ---\n');

end 