% function CreateMot_gait(labname)
% addpath('C:\Users\Public\Documents\Vicon\Nexus2.x\Configurations\Pipelines\Vicon_Codes\Functions')
addpath('C:\Users\u0138016\OneDrive - KU Leuven\GitHub\ViconSaving\Vicon_Codes\Functions')

%% Define Input
%--------------

% vicon = ViconNexus();
% [path, name] = vicon.GetTrialName();
labname = 'CMAL_1';
path = 'C:\Users\u0138016\OneDrive - KU Leuven\SimCP_2\Subjects\CP15\T0\Data\Processed\C3D';
name = 'CP15_T0_118';
main_root   = path; %directory to the place where the C3D files you want to process are stored
% path_out    = path; %directory where you want to store the OSIM-files
path_out    = 'C:\Users\u0138016\OneDrive - KU Leuven\SimCP_2\Subjects\CP15\T0\Data\Processed\TRC'; %directory where you want to store the OSIM-files



%Provide names of 2 markers on the foot to automatically couple side to
%grf. IMPORTANT: does not work when you are standing with both feet on the
%force plate (at any point in the movement).
Footmarker.R = 'RHEE';
Footmarker.L = 'LHEE';

treshold    = 10; % treshold to define valid FP contact.
FP_filter   = 10; % treshold for the low-pass filter for the force plate data.
%% Proces Files

RotationMatrix = SelectRotationMatrix(labname);
% RotationMatrix.ForcePlate = rotx(pi)*rotz(pi);
RotationMatrix.neg_direction = 0; 

%input
%-----
Path_In = fullfile(path,[name '.c3d']); %C3D directory
% Path_In = "C:\Users\u0138016\OneDrive - KU Leuven\SimCP_2\Subjects\CP15\T0\Data\Processed\C3D\CP15_T0_06.c3d";

% %output
% %------
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

        writeMarkersToTRC(fullfile(path,[name '.trc']),TRCdata(:,3:end),labels(3:end),VideoFrameRate,[Frame(1,1)*VideoFrameRate:Frame(1,2)*VideoFrameRate]',[Frame(1,1):1/VideoFrameRate:(Frame(1,1) + (size(TRCdata,1)-1)/VideoFrameRate)]','mm')

     %% export EMG from csv
%      path_csv = fullfile(path,[name '.csv']);
% %      path_csv = "C:\Users\u0138016\OneDrive - KU Leuven\SimCP_2\Subjects\CP15\T0\Data\Processed\C3D\CP15_T0_06.csv";
%      T_temp = readtable(path_csv);
%      T = readtable(path_csv,'VariableNamingRule','preserve','NumHeaderLines',3);
%      T(1,:) = []; % delete the row that contained the units

%      % CP4
%      idx_emg  = find(strcmp(T_temp.Properties.VariableDescriptions,'Imported Analog EMG #2 - Voltage'));
%      if isempty(idx_emg)
%          idx_emg  = find(strcmp(T_temp.Properties.VariableDescriptions,'EMG - Voltage'));
%      end
% 
%      EMG_data = T(:,idx_emg:end);
%      Process_EMG(EMG_data,AnalogFrameRate,path,name);

%      % CP16
%      idx_emg  = find(strcmp(T_temp.Properties.VariableDescriptions,'Imported Analog EMG #2 - Voltage'));
%      if isempty(idx_emg)
%          idx_emg  = find(strcmp(T_temp.Properties.VariableDescriptions,'EMG - Voltage'));
%      end
% 
%      EMG_data = T(:,idx_emg:end);
%      Process_EMG(EMG_data,AnalogFrameRate,path,name);

%      % CP18
%      idx_emg  = find(strcmp(T_temp.Properties.VariableDescriptions,'Imported Analog EMG #1 - Voltage'));
%      if isempty(idx_emg)
%          idx_emg  = find(strcmp(T_temp.Properties.VariableDescriptions,'EMG - Voltage'));
%      end
% 
%      EMG_data = T(:,idx_emg:18);
%      Process_EMG(EMG_data,AnalogFrameRate,path,name);

     %% Export GRF

%      idx_FP1_force   = find(strcmp(T_temp.Properties.VariableDescriptions,'Imported AMTI OR6 Series Force Plate #1 - Force'));
%      idx_FP2_force   = find(strcmp(T_temp.Properties.VariableDescriptions,'Imported AMTI OR6 Series Force Plate #2 - Force'));
%      FP_idxs = [idx_FP1_force:(idx_FP1_force+8),  idx_FP2_force:(idx_FP2_force+8)];
%      FP_data = T(:,FP_idxs);

%      Process_GRF(AnalogSignals,treshold,FP_filter,AnalogFrameRate,VideoFrameRate,Path_GRF,Mark,ParameterGroup,RotationMatrix,Footmarker,Frame);

% end 
