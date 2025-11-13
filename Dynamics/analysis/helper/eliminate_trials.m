function [updated_imaging_st,eliminated] = eliminate_trials(imaging_st,min_before_first_onset,max_length)
updated_imaging_st = imaging_st;
[r,c] = determine_num_tiles(length(imaging_st));
figure(99);clf;
tiledlayout(r,c)
for m = 1:length(imaging_st)
    imaging = imaging_st{1,m};
    empty_trials = find(cellfun(@isempty,{imaging.good_trial}));
    good_trials =  setdiff(1:length(imaging),empty_trials); %only trials with all imaging data considered!
    
    imaging_array = [imaging(good_trials).movement_in_imaging_time]; %convert to array for easier indexing
    aligned_imaging =[]; %this is needed so there is an output if there are zero trials in the condition (happens w reward)
    
    %get trial information inside imaging array
    maze_length= cellfun(@length,{imaging_array.maze_frames}); %frame length of every trial
    
    %get stimulus info
    [~,stimulus_repeats_onsets] = cellfun(@(x) findpeaks(diff(x)),{imaging_array.stimulus},'UniformOutput',false);%finds stim onset but is one early (diff)
    stimulus_repeats_onsets = cellfun(@(x) x+1,stimulus_repeats_onsets,'UniformOutput',false); %frame stimulus onsets on each trial
    total_stimulus_repeats = cellfun(@(x) length(x)+1,stimulus_repeats_onsets);
    stim_onset = cellfun(@min,stimulus_repeats_onsets,'UniformOutput',false); %find first one in stimulus to determine stimulus onset #1
    
    % trials too short
    trial_below = find([stim_onset{1,:}] < min_before_first_onset);
    %trials that are too long
    trial_above = find(maze_length > max_length);
    trials_to_eliminate = unique([trial_below,trial_above]);
    if ~isempty(trials_to_eliminate)
        for t = 1:length(trials_to_eliminate)
            updated_imaging_st{1,m}(good_trials(trials_to_eliminate(t))).good_trial = [];     
        end
        fprintf(strcat('eliminating ',num2str(length(trials_to_eliminate)) ,' trials in mouse ',num2str(m),'\n'))
    end

    % make plots of maze length!

    nexttile
    hold on
    plot(maze_length, '-k','linewidth', 1.5)
    if ~isempty(trials_to_eliminate)
        plot(trials_to_eliminate,maze_length(trials_to_eliminate),'*r','linewidth', 1.5)
    end
    xlabel('Trial ID')
    ylabel('Maze length (frames)')
    title (['Maze length dataset# ' num2str(m)])
    xlim([1 length(good_trials)])
    hold off

    eliminated{m} = good_trials(trials_to_eliminate);
end