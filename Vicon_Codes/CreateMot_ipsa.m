function CreateMot_ipsa(labname)
addpath('C:\Users\Public\Documents\Vicon\Nexus2.x\Configurations\Pipelines\Vicon_Codes\Functions')
%% Define Input
%--------------

vicon = ViconNexus();
[path, name] = vicon.GetTrialName();
main_root   = path; %directory to the place where the C3D files you want to process are stored
path_out    = path; %directory where you want to store the OSIM-files

FC_filter   = 15; % treshold for the low-pass filter for the force plate data.
%% Proces Files
%--------------

    RotationMatrix = SelectRotationMatrix(labname);
    
    %input
    %-----
%     Path_In = fullfile(path,[name '.c3d']); %C3D directory
    Path_In = 'C:\Users\u0138016\OneDrive - KU Leuven\SimCP_2\Subjects\CP15\T0\Data\Processed\C3D\CP15_T0_107.c3d';
    
    %output
    %------
    Path_GRF    = fullfile(path_out, [name '.mot']); %output grf directory
    
    if ~exist(fullfile(path_out))
        mkdir(fullfile(path_out));
    end
    
    %% Load data
    %-----------
    [Markers,MLabels,VideoFrameRate,AnalogSignals,ALabels, AUnits, AnalogFrameRate,Event,ParameterGroup,CameraInfo]...
        = readC3D(Path_In);

    Mark.Labels = MLabels; Mark.Data = Markers;

    Frame = [ParameterGroup(1).Parameter(1).data(1,1)/VideoFrameRate ParameterGroup(1).Parameter(2).data(1,1)/VideoFrameRate];

    %% update the trc file 
        [TRCdata,labels] = importTRCdata(fullfile(path,[name '.trc']));

        writeMarkersToTRC(fullfile(path,[name '.trc']),TRCdata(:,3:end),labels(3:end),VideoFrameRate,[Frame(1,1)*VideoFrameRate:Frame(1,2)*VideoFrameRate]',[Frame(1,1):1/VideoFrameRate:(Frame(1,1) + (size(TRCdata,1)-1)/VideoFrameRate)]','mm');

     %% export EMG and FC data from csv
%      path_csv = fullfile(path,[name '.csv']);
     path_csv = "C:\Users\u0138016\OneDrive - KU Leuven\SimCP_2\Subjects\CP15\T0\Data\Processed\C3D\CP15_T0_107.csv";
     T_temp = readtable(path_csv);
     T = readtable(path_csv,'VariableNamingRule','preserve','NumHeaderLines',3);
     T(1,:) = []; % delete the row that contained the units

     idx_fc   = find(strcmp(T_temp.Properties.VariableDescriptions,'Imported Generic Analog #2 - Electric Potential'));
     idx_emg  = find(strcmp(T_temp.Properties.VariableDescriptions,'EMG - Voltage'));
     idxs_var = find(contains(T_temp.Properties.VariableDescriptions,'Var'));

     EMG_data = T(:,idx_emg:end);
     FC_data = T(:,idx_fc:idx_emg-1);

     path= 'C:\Users\u0138016\OneDrive - KU Leuven\SimCP_2\Subjects\CP15\T0\Data\Processed\C3D';
     name = 'CP15_T0_107';
     Process_EMG(EMG_data,AnalogFrameRate,path,name)

%      Process_FC()

     %% export EMG

       


     %% export FC



end 
