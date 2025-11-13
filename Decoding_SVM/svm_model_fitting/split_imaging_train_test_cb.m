function [train_imaging_spk, test_imaging_spk,all_trials] = split_imaging_train_test_cb(imaging_spk,condition_array_trials,train_fraction,allorno,saveorno)
%%% Inputs: imaging structure, condition_array_trials(good_trials, choice
%%% (0,1), left or right, stim or not)
%%% Outputs: train_imaging_spk imaging_sk with training trials,
%%% test_imaging_spk imaging_sk with testing trials,
%%% all_trails{train,test,train referencing good trials, test referencing
%%% good trials)

%%%Split the data structure into train and test segments for training and
%%%testing encoding models. Keeps the distribution of trial types 
%%%(choices & stimuli) the same across train and test 
%%%all_trials has train and test trials

train_imaging_spk = [];
test_imaging_spk = [];
all_trials1 = [];
all_trials2 =[];


empty_trials = find(cellfun(@isempty,{imaging_spk.good_trial}));
good_trials =  setdiff(1:length(imaging_spk),empty_trials); %only trials with all imaging data considered!
imaging_array = [imaging_spk(good_trials).virmen_trial_info]; %convert to array for easier indexing

choices = condition_array_trials(:,2);
if allorno == 1 %use all stimuli conditions
    stimuli = [imaging_array.condition];
else %use left or right as the stimuli conditions
    stimuli = condition_array_trials(:,3)';
end


%using trials with imaging data?
if size( condition_array_trials,2) == 3 %only 2 conditions to balance
    for ch = unique(choices')
        for locs = unique(stimuli) %stimulus features 
            current_loc = locs;
            current_choice = ch;
            loc_inds = condition_array_trials(find(stimuli == current_loc),1);
            choice_inds = condition_array_trials(find([imaging_array.correct] == current_choice),1);%get_choice_inds(imaging_spk,choices(ch));
            trials = intersect(loc_inds,choice_inds);
            if isempty(trials)==0
                num_trials = length(trials)
                trials = trials(randperm(num_trials));%shuffle(trials); %unsure about what this shuffle function was doing
                num_train_trials = round(num_trials*train_fraction);
                num_test_trials = num_trials - num_train_trials;
                train_trials = trials(1:num_train_trials);
                test_trials = trials(num_train_trials+1:end);
                train_imaging_spk = cat(2,train_imaging_spk,imaging_spk(train_trials));
                test_imaging_spk = cat(2,test_imaging_spk,imaging_spk(test_trials));
                if isempty(intersect(train_trials,test_trials))==0
                    keyboard
                end
                all_trials1 = [all_trials1;train_trials];
                all_trials2 = [all_trials2;test_trials];
            end
        end
    end
else % 3 conditions to balance
    opto = condition_array_trials(:,4);
    for ch = unique(choices')
        for locs = unique(stimuli) %stimulus features 
            for opto_trial = unique(opto')
                current_loc = locs;
                current_choice = ch;
                current_opto = opto_trial;
                loc_inds = condition_array_trials(find(stimuli == current_loc),1);
                choice_inds = condition_array_trials(find([imaging_array.correct] == current_choice),1);%get_choice_inds(imaging_spk,choices(ch));
                opto_inds = condition_array_trials(find(condition_array_trials(:,4) == current_opto),1);
                trials = intersect(intersect(loc_inds,choice_inds),opto_inds);
                if isempty(trials)==0
                    num_trials = length(trials)
                    trials = trials(randperm(num_trials));%shuffle(trials); %unsure about what this shuffle function was doing
                    num_train_trials = round(num_trials*train_fraction);
                    num_test_trials = num_trials - num_train_trials;
                    train_trials = trials(1:num_train_trials);
                    test_trials = trials(num_train_trials+1:end);
                    train_imaging_spk = cat(2,train_imaging_spk,imaging_spk(train_trials));
                    test_imaging_spk = cat(2,test_imaging_spk,imaging_spk(test_trials));
                    if isempty(intersect(train_trials,test_trials))==0
                        keyboard
                    end
                    all_trials1 = [all_trials1;train_trials];
                    all_trials2 = [all_trials2;test_trials];
                    
                end
            end
        end
    end
end
%get trial indices
%across all trials
all_trials{1,:} = all_trials1; %train
all_trials{2,:} = all_trials2; %test
%only referencing good trials
 
for a = 1:2
    current_t=[] ;
    trialss =[all_trials{a,1}];
    for t = 1:length(all_trials{a,1})
        current_t = [current_t, find(condition_array_trials(:,1) == trialss(t))];
    end
    all_trials{a+2,:} = current_t;
end


% else %maybe was used for passive??
%     location_list = unique(sound_locations(imaging_spk));
%     for locs = 1:length(location_list)
%         loc_inds = get_loc_inds(imaging_spk,location_list(locs));
%         trials = loc_inds;
%         trials = shuffle(trials);
%         num_trials = length(loc_inds);
%         num_train_trials = ceil(num_trials*train_fraction);
%         num_test_trials = num_trials - num_train_trials;
%         train_trials = trials(1:num_train_trials);
%         test_trials = trials(num_train_trials+1:end);
%         train_imaging_spk = cat(2,train_imaging_spk,imaging_spk(train_trials));
%         test_imaging_spk = cat(2,test_imaging_spk,imaging_spk(test_trials));
%         if isempty(intersect(train_trials,test_trials))==0
%             keyboard
%         end
%     end
% end
save all_trials all_trials
if saveorno == 1;
    save train_imaging_spk train_imaging_spk '-v7.3'
    save test_imaging_spk test_imaging_spk '-v7.3'
end
