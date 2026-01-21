% function CreateMot_gait(labname)
% addpath('C:\Users\Public\Documents\Vicon\Nexus2.x\Configurations\Pipelines\Vicon_Codes\Functions')
addpath('C:\Users\u0138016\OneDrive - KU Leuven\GitHub\ViconSaving\Vicon_Codes\Functions')
close all

%% Define Input
%--------------
bool.process_trc = 0;
bool.process_EMG = 0;
bool.process_GRF = 1;

% vicon = ViconNexus();
% [path, name] = vicon.GetTrialName();
labname = 'CMAL_1';
path = 'J:\GBW-0301_HumanMovementBiomechanics\SimCP2\Subjects\CP4\T0\Data\Processed\C3D';
% path = 'C:\Users\u0138016\OneDrive - KU Leuven\SimCP_2\Subjects\CP15\T0\Data\Processed\C3D';
name_begin = 'CP4_T0_';
trials = 5;
main_root   = path; %directory to the place where the C3D files you want to process are stored
path_out    = fullfile('C:\Users\u0138016\OneDrive - KU Leuven\SimCP_2\Subjects\CP4\T0\Data\Processed\'); %directory where you want to store the OSIM-files

%Provide names of 2 markers on the foot to automatically couple side to
%grf. IMPORTANT: does not work when you are standing with both feet on the
%force plate (at any point in the movement).
Footmarker.R = 'RHEE';
Footmarker.L = 'LHEE';

treshold    = 10; % treshold to define valid FP contact.
FP_filter   = 10; % treshold for the low-pass filter for the force plate data.
%% Proces Files
for i = trials
    
    trial_num = sprintf('%02d',i);
    name = [name_begin,trial_num];

    outPath_GRF = fullfile(path_out,'GRF', [name '_GRF.mot']); %output grf directory
    outPath_trc = fullfile(path_out,'trc', [name '.trc']); 

    RotationMatrix = SelectRotationMatrix(labname);
    % RotationMatrix.ForcePlate = rotx(pi)*rotz(pi);
    RotationMatrix.neg_direction = 0; 
    
    %input
    %-----
    Path_In = fullfile(path,[name '.c3d']); %C3D directory
    % Path_In = "C:\Users\u0138016\OneDrive - KU Leuven\SimCP_2\Subjects\CP15\T0\Data\Processed\C3D\CP15_T0_06.c3d";
    
    %output
    %------
    % Path_GRF    = fullfile(path_out, [name '_GRF.mot']); %output grf directory
    
    if ~exist(fullfile(path_out))
        mkdir(fullfile(path_out));
    end
        
        %% Load data
        %-----------
        [Markers,MLabels,VideoFrameRate,AnalogSignals,ALabels, AUnits, AnalogFrameRate,Event,ParameterGroup,CameraInfo]...
            = readC3D(Path_In);
    
        Mark.Labels = MLabels; 
        Mark.Data = Markers;
    
        Frame = [ParameterGroup(1).Parameter(1).data(1,1)/VideoFrameRate ParameterGroup(1).Parameter(2).data(1,1)/VideoFrameRate];
        %% update the trc file 
         
            [TRCdata,labels] = importTRCdata(fullfile(path,[name '.trc']));
    %         [TRCdata,labels] = importTRCdata("C:\Users\u0138016\OneDrive - KU Leuven\SimCP_2\Subjects\CP15\T0\Data\Processed\C3D\CP15_T0_17.trc");
    
            % if trial is in the negative direction, rotate with 180 deg around y
            change = diff(TRCdata(:,3));
            idxs = ~isnan(change); % only take the values that are not nan
            data = change(idxs);
    
            if ~strcmp(labname,'treadmill_MALL') && mean(data) < 0 % if on treadmill you do not want to rotate            
                % Rotate data
                markers_rot = rot3DVectors(roty(pi), TRCdata(:,3:end));
                TRCdata(:,3:end) = markers_rot;
                RotationMatrix.neg_direction = 1;
            end

        if bool.process_trc
            writeMarkersToTRC(outPath_trc,TRCdata(:,3:end),labels(3:end),VideoFrameRate,[Frame(1,1)*VideoFrameRate:round(Frame(1,2)*VideoFrameRate)]',[Frame(1,1):1/VideoFrameRate:(Frame(1,1) + (size(TRCdata,1)-1)/VideoFrameRate)]','mm')
        end
         %% export EMG from csv
         if bool.process_EMG
             path_csv = fullfile(path,[name '.csv']);
    %          path_csv = "C:\Users\u0138016\OneDrive - KU Leuven\SimCP_2\Subjects\CP15\T0\Data\Processed\C3D\CP15_T0_06.csv";
             T_temp = readtable(path_csv);
             T = readtable(path_csv,'VariableNamingRule','preserve','NumHeaderLines',3);
             T(1,:) = []; % delete the row that contained the units
    
    %         opts = detectImportOptions(path_csv, ...
    %             'NumHeaderLines', 3, ...
    %             'VariableNamingRule', 'preserve');
    %         
    %         % Treat quote-only entries as missing
    %         opts = setvaropts(opts, opts.VariableNames, 'TreatAsMissing', {'""','"'});
    %         
    %         % Also, for text variables, mark empty fields as missing
    %         opts = setvaropts(opts, opts.VariableNames, 'EmptyFieldRule', 'auto');
    %         
    %         T = readtable(path_csv, opts);
    %         
    %         % Drop columns that are completely missing
    %         T(:, all(ismissing(T))) = [];
    
    
             % CP4, CP21, CP22 (from trial 6 onwards)
             idx_emg  = find(strcmp(T_temp.Properties.VariableDescriptions,'Imported Analog EMG #2 - Voltage'));
             if isempty(idx_emg)
                 idx_emg  = find(strcmp(T_temp.Properties.VariableDescriptions,'EMG - Voltage'));
             end
        
             EMG_data = T(:,idx_emg:end);
             Process_EMG(EMG_data,AnalogFrameRate,path_out,name);
        
    %          % CP16
    %          idx_emg  = find(strcmp(T_temp.Properties.VariableDescriptions,'Imported Analog EMG #2 - Voltage'));
    %          if isempty(idx_emg)
    %              idx_emg  = find(strcmp(T_temp.Properties.VariableDescriptions,'EMG - Voltage'));
    %          end
    %     
    %          EMG_data = T(:,idx_emg:end);
    %          Process_EMG(EMG_data,AnalogFrameRate,path_out,name);
        
    %          % CP18, CP22 (trial 1->4)
    %          idx_emg  = find(strcmp(T_temp.Properties.VariableDescriptions,'Imported Analog EMG #1 - Voltage'));
    %          if isempty(idx_emg)
    %              idx_emg  = find(strcmp(T_temp.Properties.VariableDescriptions,'EMG - Voltage'));
    %          end
    % %     
    %          EMG_data = T(:,idx_emg:18);
    %          Process_EMG(EMG_data,AnalogFrameRate,path_out,name);
         end
    
         %% Export GRF
         if bool.process_GRF
    %      idx_FP1_force   = find(strcmp(T_temp.Properties.VariableDescriptions,'Imported AMTI OR6 Series Force Plate #1 - Force'));
    %      idx_FP2_force   = find(strcmp(T_temp.Properties.VariableDescriptions,'Imported AMTI OR6 Series Force Plate #2 - Force'));
    %      FP_idxs = [idx_FP1_force:(idx_FP1_force+8),  idx_FP2_force:(idx_FP2_force+8)];
    %      FP_data = T(:,FP_idxs);
    
            Process_GRF(AnalogSignals,treshold,FP_filter,AnalogFrameRate,VideoFrameRate,outPath_GRF,Mark,ParameterGroup,RotationMatrix,Footmarker,Frame);
        end
end 
