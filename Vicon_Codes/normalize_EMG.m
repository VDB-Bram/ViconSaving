% find max EMG signals over specified trials and normalize EMG
clear all
close all
addpath(genpath('C:\GBW_MyPrograms\MuscleRedundancySolver_private\IO_Functions'))
addpath(genpath('C:\Users\u0138016\OneDrive - KU Leuven\GitHub\ViconSaving\Vicon_Codes\Functions'))

%% find max EMG signals
% trials to take into account
trials = [9:14,17:18,20:23,25,27,28,30];
subject = 'CP16';

datapath = fullfile('C:\Users\u0138016\OneDrive - KU Leuven\SimCP_2\Subjects',subject,'T0\Data\Processed\');

% loop through trials
% emg_max_trial = zeros(length(trials),16);
emg_max_trial = table();

for t = 1:length(trials)
    emg_file = fullfile(datapath,'EMG',[subject, '_T0_', sprintf('%02d', trials(t)), '_EMG_filt.mot']);
    emg = ReadMotFile(emg_file);

    muscleNames = matlab.lang.makeValidName(emg.names(2:end));
    
    % find and store max value per EMG channel
    emg_max_current = array2table(max(emg.data(:,2:end),[],1),'VariableNames', muscleNames);
    emg_max_current = addvars(emg_max_current, string(sprintf('%02d', trials(t))), 'Before', 1, 'NewVariableNames', 'Trial');
    emg_max_trial = [emg_max_trial; emg_max_current];

end

% calculate max emg value per muscle over all included trials
max_emg = array2table(max(table2array(emg_max_trial(:,2:end)), [], 1), 'VariableNames', emg_max_trial.Properties.VariableNames(2:end));

% plot data 

% save max emg values for later reference
emg_max_trial_file = fullfile(datapath,'EMG','1_max_emg_per_trial - for normalization.mat');
emg_max_file = fullfile(datapath,'EMG','1_max_emg_over_trials - for normalization.mat');
save(emg_max_trial_file,"emg_max_trial");
save(emg_max_file,"max_emg");

%% normalize EMG to maximal EMG values found

figure; tiledlayout(4,4)

for t = 1:length(trials)

    emg_file = fullfile(datapath,'EMG',[subject, '_T0_', sprintf('%02d', trials(t)), '_EMG_filt.mot']);
    emg = ReadMotFile(emg_file);
    
    muscleNames = matlab.lang.makeValidName(emg.names(2:end));
    emg_current = array2table(emg.data(:,2:end),'VariableNames', muscleNames);

    % Get common muscle names
    muscles = intersect(emg_current.Properties.VariableNames, max_emg.Properties.VariableNames);
    
    % Copy original table
    emg_norm = emg_current;
    
    % Normalize each muscle column
    for i = 1:numel(muscles)
        m = muscles{i};
        emg_norm.(m) = emg_current.(m) ./ max_emg.(m);

         nexttile(i)
         plot(emg_norm.(m)); hold on
    end

    emg_norm = addvars(emg_norm, emg.data(:,1), 'Before', 1, 'NewVariableNames', 'Time');


    emg_norm_file = fullfile(datapath,'EMG',[subject, '_T0_', sprintf('%02d', trials(t)), '_EMG_filt_norm.mot']);
    generateMotFile(table2array(emg_norm),emg_norm.Properties.VariableNames,emg_norm_file);

end

%% plot normalized EMG