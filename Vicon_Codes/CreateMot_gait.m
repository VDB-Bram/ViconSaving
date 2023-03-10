function CreateMot_gait(labname,IPlates,Stairs)
addpath('C:\Users\Public\Documents\Vicon\Nexus2.x\Configurations\Pipelines\Vicon_Codes\Functions')
%% Define Input
%--------------

vicon = ViconNexus();
[path, name] = vicon.GetTrialName();
main_root   = path; %directory to the place where the C3D files you want to process are stored
path_out    = path; %directory where you want to store the OSIM-files

%Provide names of 2 markers on the foot to automatically couple side to
%grf. IMPORTANT: does not work when you are standing with both feet on the
%force plate (at any point in the movement).
Footmarker.R = 'RHEE';
Footmarker.L = 'LHEE';

treshold    = 20; % treshold to define valid FP contact.
FP_filter   = 15; % treshold for the low-pass filter for the force plate data.
%% Proces Files
%--------------

    RotationMatrix = SelectRotationMatrix(labname);
    
    %input
    %-----
    Path_In = fullfile(path,[name '.c3d']); %C3D directory
    
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
%         [TRCdata,labels] = importTRCdata("C:\Users\u0138016\OneDrive - KU Leuven\SimCP_2\Subjects\CP15\T0\Data\Processed\C3D\CP15_T0_17.trc");
 

        % if trial is in the negative direction, rotate with 180 deg around y
        change = diff(TRCdata(:,3));
        idxs = ~isnan(change); % only take the values that are not nan
        data = change(idxs);
        if ~strcmp(labname,'treadmill_MALL') && mean(data) < 0 % if on treadmill you do not to rotate
            neg_direction = 1;
            
            % Rotate data
            markers_rot = rot3DVectors(roty(pi), TRCdata(:,3:end));
            TRCdata(:,3:end) = markers_rot;
        else
            neg_direction = 0;
        end

        writeMarkersToTRC(fullfile(path,[name '.trc']),TRCdata(:,3:end),labels(3:end),VideoFrameRate,[Frame(1,1)*VideoFrameRate:Frame(1,2)*VideoFrameRate]',[Frame(1,1):1/VideoFrameRate:(Frame(1,1) + (size(TRCdata,1)-1)/VideoFrameRate)]','mm')

   
        %% PROCESS GRF for OpenSimProcessing
        %-----------------------------------
        if strcmp(labname,'treadmill_MALL')
            if strcmp(labname,'treadmill_MALL') && strcmp(IPlates,'1')
                [~]= Process_GRF_TM(AnalogSignals,treshold,AnalogFrameRate,VideoFrameRate,Path_GRF,Mark,Markers,ParameterGroup,RotationMatrix,FP_filter,Footmarker,Frame);
            else
                [~]= Process_GRF_TM2(AnalogSignals,treshold,AnalogFrameRate,VideoFrameRate,Path_GRF,Mark,Markers,ParameterGroup,RotationMatrix,FP_filter,Footmarker,Frame);
            end
        else
            if strcmpi(Stairs,'1')
            [err]= Process_GRF_stairs(AnalogSignals,treshold,FP_filter,AnalogFrameRate,VideoFrameRate,Path_GRF,Mark,ParameterGroup,RotationMatrix,Footmarker,Frame);   
            else 
            [err]= Process_GRF(AnalogSignals,treshold,FP_filter,AnalogFrameRate,VideoFrameRate,Path_GRF,Mark,ParameterGroup,RotationMatrix,Footmarker,Frame);
            end
        end
end 
