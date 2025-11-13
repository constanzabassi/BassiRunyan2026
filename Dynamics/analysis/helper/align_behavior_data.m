function [aligned_imaging,imaging_array,align_info,frames] = align_behavior_data (imaging,align_info,alignment_frames,left_padding,right_padding,alignment,varargin)
empty_trials = find(cellfun(@isempty,{imaging.good_trial}));
good_trials =  setdiff(1:length(imaging),empty_trials); %only trials with all imaging data considered!
imaging_array = [imaging(good_trials).movement_in_imaging_time]; %convert to array for easier indexing
aligned_imaging =[]; %this is needed so there is an output if there are zero trials in the condition (happens w reward)

%save good trials
align_info.good_trials = good_trials;
if nargin > 6
    cell_ids = varargin{1,1};
else
    cell_ids = 1:size(imaging(good_trials(1)).dff,1);
end

if strcmp(alignment.type,'stimulus' )
% 1) align data based on stimulus onset (include preceding maze- couple frames)
    frames = find_alignment_frames (alignment_frames,[1:3],left_padding,right_padding);
    for vr_trials = 1:length(good_trials)
        t = vr_trials;
        frames_to_include = frames(t,:);%align_info.stimulus_onsets(vr_trials)-align_info.stimulus_onset+1:align_info.stimulus_onsets(vr_trials)+align_info.min_length-align_info.stimulus_onset+1; %currently stim onset is frame 1
        if strcmp(alignment.data_type,'dff')
            aligned_imaging(vr_trials,:,:) = imaging(good_trials(vr_trials)).dff(cell_ids,frames_to_include);
        elseif strcmp(alignment.data_type,'z_dff')
            aligned_imaging(vr_trials,:,:) = imaging(good_trials(vr_trials)).z_dff(cell_ids,frames_to_include);
        else
            aligned_imaging(vr_trials,:,:) = imaging(good_trials(vr_trials)).deconv(cell_ids,frames_to_include);
        end
       
    end
elseif strcmp(alignment.type,'turn')
    
% 2) align data based on maze offset/turn (1 sec pre and post)
frames = find_alignment_frames (alignment_frames,[4],left_padding,right_padding);
    for vr_trials = 1:length(good_trials) 
            t = vr_trials;
            frames_to_include = frames(t,:);%imaging_array(t).turn_frame-align_info.turn_onset+1 :imaging_array(t).turn_frame+align_info.turn_onset-1 ; %turn onset is frame 31
            if strcmp(alignment.data_type,'dff')
                aligned_imaging(vr_trials,:,:) = imaging(good_trials(vr_trials)).dff(cell_ids,frames_to_include);
            elseif strcmp(alignment.data_type,'z_dff')
                aligned_imaging(vr_trials,:,:) = imaging(good_trials(vr_trials)).z_dff(cell_ids,frames_to_include);
            else
                aligned_imaging(vr_trials,:,:) = imaging(good_trials(vr_trials)).deconv(cell_ids,frames_to_include);
            end
           
    end

% 3) align data based on reward (include only reward period?)
elseif strcmp(alignment.type ,'reward')
    frames = find_alignment_frames (alignment_frames,[5],left_padding,right_padding);
        for vr_trials = 1:length(good_trials) 
            t = vr_trials;
            frames_to_include = frames(t,:);%align_info.reward_onsets(vr_trials)-align_info.reward_onset+1:align_info.reward_onsets(vr_trials)+align_info.max_length_reward-align_info.reward_onset-1; %reward onset at min_length_reward+1
            if strcmp(alignment.data_type,'dff')
                aligned_imaging(vr_trials,:,:) = imaging(good_trials(t)).dff(cell_ids,frames_to_include);
            elseif strcmp(alignment.data_type,'z_dff')
                aligned_imaging(vr_trials,:,:) = imaging(good_trials(t)).z_dff(cell_ids,frames_to_include);
            else
                aligned_imaging(vr_trials,:,:) = imaging(good_trials(t)).deconv(cell_ids,frames_to_include);
            end
           
        end
elseif strcmp(alignment.type ,'ITI')
    frames = find_alignment_frames (alignment_frames,[6],left_padding,right_padding);
        for vr_trials = 1:length(good_trials) 
            t = vr_trials;
            frames_to_include = frames(t,:);%
            if strcmp(alignment.data_type,'dff')
                aligned_imaging(vr_trials,:,:) = imaging(good_trials(t)).dff(cell_ids,frames_to_include);
            elseif strcmp(alignment.data_type,'z_dff')
                aligned_imaging(vr_trials,:,:) = imaging(good_trials(t)).z_dff(cell_ids,frames_to_include);
            else
                aligned_imaging(vr_trials,:,:) = imaging(good_trials(t)).deconv(cell_ids,frames_to_include);
            end
           
        end
elseif strcmp(alignment.type ,'all')
    frames = find_alignment_frames (alignment_frames,[1:6],left_padding,right_padding);
        for vr_trials = 1:length(good_trials) 
            t = vr_trials;
            frames_to_include = frames(t,:);%
            if strcmp(alignment.data_type,'dff')
                aligned_imaging(vr_trials,:,:) = imaging(good_trials(t)).dff(cell_ids,frames_to_include);
            elseif strcmp(alignment.data_type,'z_dff')
                aligned_imaging(vr_trials,:,:) = imaging(good_trials(t)).z_dff(cell_ids,frames_to_include);
            else
                aligned_imaging(vr_trials,:,:) = imaging(good_trials(t)).deconv(cell_ids,frames_to_include);
            end
           
        end
    elseif strcmp(alignment.type ,'pre')
    frames = find_alignment_frames (alignment_frames,[1:5],left_padding,right_padding);
        for vr_trials = 1:length(good_trials) 
            t = vr_trials;
            frames_to_include = frames(t,:);%
            if strcmp(alignment.data_type,'dff')
                aligned_imaging(vr_trials,:,:) = imaging(good_trials(t)).dff(cell_ids,frames_to_include);
            elseif strcmp(alignment.data_type,'z_dff')
                aligned_imaging(vr_trials,:,:) = imaging(good_trials(t)).z_dff(cell_ids,frames_to_include);
            else
                aligned_imaging(vr_trials,:,:) = imaging(good_trials(t)).deconv(cell_ids,frames_to_include);
            end
           
        end
    
end
