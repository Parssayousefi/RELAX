% RELAX Preprocessing Configuration File
% 
% This script defines the parameters for the RELAX EEG preprocessing pipeline
% for the Chakra Meditation dataset.

function config = config_relax()

    % Initialize the configuration structure
    config = struct();

    % --- Core Settings (Corrected Field Names) ---
    config.raw_data_folder = '../data/raw/'; % Path relative to the scripts folder where BDF files are
    config.caploc = '/home/s3648540/data_pi-michielvanelkm/Parsa/Chakra/EEG/code/eeglab2025.0.0/functions/supportfiles/channel_location_files/BioSemi64.loc'; % Updated path, RELAX uses 'caploc'
    config.FilesToProcess = [1 2 4]; % RELAX uses 'FilesToProcess' (Note: run_relax_job overrides this with config.filename for single file processing)
    config.ElectrodesToDelete = {'EXG1', 'EXG2', 'EXG3', 'EXG4', 'EXG5', 'EXG6', 'EXG7', 'EXG8'}; % RELAX uses 'ElectrodesToDelete'
    config.LineNoiseFrequency = 50; % RELAX uses 'LineNoiseFrequency'
    config.DownSample = 'yes'; % RELAX uses 'DownSample'
    config.DownSample_to_X_Hz = 512; % RELAX uses 'DownSample_to_X_Hz'
    config.computecleanedmetrics = 1; % RELAX uses 'computecleanedmetrics'. Assuming 'Compute on raw and cleaned' means 1 (0=No, 1=Yes for Raw+Cleaned or just Cleaned? Check wrapper logic if specific needed)
    config.computerawmetrics = 1;    % Added based on computecleanedmetrics; RELAX_Wrapper uses this too.

    % --- Filtering (Corrected Field Names) ---
    config.HighPassFilter = 1; % Split from bandpass_filter; RELAX uses 'HighPassFilter'
    config.LowPassFilter = 100; % Split from bandpass_filter; RELAX uses 'LowPassFilter'
    config.FilterType = 'Butterworth'; % RELAX uses 'FilterType'. Set to 'Butterworth' to match previous 'acausal_butterworth'.
    config.causal_or_acausal_filter = 'acausal'; % Added based on FilterType setting.
    config.NotchFilterType = 'Butterworth'; % RELAX uses 'NotchFilterType' 
    config.LowPassFilterBeforeMWF = 'no'; % Added - RELAX v2 default/recommendation

    % --- Electrode Rejection (Corrected Field Names) ---
    config.MaxProportionOfElectrodesThatCanBeDeleted = 0.1; % RELAX uses 'MaxProportionOfElectrodesThatCanBeDeleted'
    % Note: extreme_noise_prop_thresh and muscle_noise_prop_thresh seem used internally by RELAX_excluding_channels_and_epoching
    config.extreme_noise_prop_thresh = 0.25; % Keep for internal functions
    config.muscle_noise_prop_thresh = 0.5; % Keep for internal functions

    % --- Extreme Outlier Detection Thresholds (Corrected Field Names) ---
    % Note: These seem used internally by RELAX_excluding_extreme_values
    config.improbable_volt_dist_sd = 5; 
    config.single_chan_kurtosis = 5; 
    config.all_chan_kurtosis = 5; 
    config.abs_volt_shift = 1000; 
    config.mad_volt_shift = 20; 
    config.mad_blink_volt_shift = 10; 
    config.log_freq_log_power_drift_thresh = -4; 

    % --- MWF Cleaning Options (Corrected/Mapped Field Names) --- 
    % Map use_mwf_to_clean to Do_MWF flags. Assuming sequential MWF for Muscle, Blinks, HEOG implies all 3 rounds.
    config.Do_MWF_Once = 1;   % For Muscle
    config.Do_MWF_Twice = 1;  % For Blinks
    config.Do_MWF_Thrice = 1; % For HEOG/Drift
    % Map mwf_delay_period/spacing to artifact-specific fields
    config.MWFDelayPeriod_for_muscle_artifacts = 10; 
    config.MWF_delay_spacing_for_muscle_artifacts = 2; % Example default mentioned in docs
    config.MWFDelayPeriod_for_eye_movements = 10; % Using same as muscle for now, adjustable
    config.MWF_delay_spacing_for_eye_movements = 16; % Using blink example default
    % Note: Other MWF thresholds seem used internally by RELAX_perform_MWF_cleaning
    config.max_prop_muscle_mwf = 0.3; 
    config.single_electrode_drift_thresh_mwf = 10;
    config.max_prop_drift_mwf = 0.3; 
    config.heog_thresh_mwf = 10; 
    % Define which round cleans blinks (default seems to be second? Check RELAX_Wrapper logic if needed)
    config.MWFRoundToCleanBlinks = 2; % Default assumption based on wrapper structure
    
    % --- ICA Cleaning Options (Corrected/Mapped Field Names) ---
    % Map clean_artifacts_with_ica based on 'targeted_wICA'
    config.Perform_targeted_wICA = 1;
    config.Perform_wICA_on_ICLabel = 0;
    config.Perform_ICA_subtract = 0;
    config.ICA_method = 'picard'; % RELAX uses 'ICA_method' (capitalization)
    config.Clean_other_comps = 'yes'; % RELAX uses 'Clean_other_comps'
    config.Report_all_ICA_info = 0; % Added, default to 0 for speed
    config.ICLabel_thresholds = struct(); % Added, use default ICLabel thresholds explicitly
    
    % --- Blink/HEOG Detection (Corrected Field Names) ---
    config.ProbabilityDataHasNoBlinks = 1; % RELAX uses 'ProbabilityDataHasNoBlinks' (0=yes, 1=likely, 2=no)
    % Note: blink_electrodes, heog_electrodes_left/right seem used internally
    config.blink_electrodes = {'FP1', 'FPZ', 'FP2', 'AF3', 'AF4', 'F3', 'F1', 'FZ', 'F2', 'F4'}; 
    config.lowpass_filter_before_blink_detect_6Hz = 'no'; 
    config.heog_electrodes_left = {'F7', 'FT7', 'F5', 'T7', 'FC5', 'C5', 'TP7', 'AF3'}; 
    config.heog_electrodes_right = {'F8', 'FT8', 'F6', 'T8', 'FC6', 'C6', 'TP8', 'AF4'}; 
    % Note: muscle_threshold seems used internally by RELAX_muscle
    config.muscle_threshold = -0.31; 
    
    % --- Output/Saving (Corrected/Mapped Field Names) ---
    config.InterpolateRejectedElectrodesAfterCleaning = 'yes'; % RELAX uses 'InterpolateRejectedElectrodesAfterCleaning' (Set back to 'yes' based on original task list, override report for now)
    % Map save_intermediate_steps to specific save flags
    config.saveextremesrejected = 0; % Default no
    config.saveround1 = 0;           % Default no
    config.saveround2 = 0;           % Default no
    config.saveround3 = 0;           % Default no
    config.KeepAllInfo = 0;          % Added, default to 0 to save memory/disk

end 