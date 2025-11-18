function [cv_mod_index, cv_mod_index_separate, bootstrapResults] = calc_mod_index_cv(...
    stim_data, ctrl_data, stim_trials, ctrl_trials, current_conditions, current_conditions_ctrl, ...
    response_range, mod_type, mode, nRepeats, nShuffles, specified_lr)

% Constants
VALID_MOD_TYPES = {'ctrl', 'influence', 'prepost', 'prepost_sound','prepost_ctrl','prepost_sound','prepost_num','ctrl_num','prepost_ctrl_abs','prepost_abs','ctrl_abs','signed_ctrl','prepost_sound_num','pre_engagement','pre_engagement_num'};
VALID_MODES = {'pooled', 'separate', 'simple', 'selectivity'};
DEFAULT_REPEATS = 10;
DEFAULT_SHUFFLES = 0;

% Input validation
validateattributes(stim_data, {'numeric'}, {'3d'}, 'calc_mod_index_cv', 'stim_data');
validateattributes(ctrl_data, {'numeric'}, {'3d'}, 'calc_mod_index_cv', 'ctrl_data');
validateattributes(response_range, {'cell'}, {}, 'calc_mod_index_cv', 'response_range');
validatestring(mod_type, VALID_MOD_TYPES, 'calc_mod_index_cv', 'mod_type');

% Set default values
if nargin < 9 || isempty(mode)
    mode = 'pooled';
end
if nargin < 10 || isempty(nRepeats)
    nRepeats = DEFAULT_REPEATS;
end
if nargin < 11 || isempty(nShuffles)
    nShuffles = DEFAULT_SHUFFLES;
end
if nargin < 12
    specified_lr = [];
end

% Initialize outputs
bootstrapResults = [];

% Main processing based on mode
switch lower(mode)
    case 'pooled'
        [cv_mod_index, cv_mod_index_separate, bootstrapResults] = ...
            handle_pooled_mode(stim_data, ctrl_data, stim_trials, ctrl_trials, ...
            current_conditions, current_conditions_ctrl, response_range, ...
            mod_type, nRepeats, nShuffles, specified_lr);
            
    case 'separate'
        [cv_mod_index, cv_mod_index_separate, bootstrapResults] = ...
            handle_separate_mode(stim_data, ctrl_data, stim_trials, ctrl_trials, ...
            current_conditions, current_conditions_ctrl, response_range, ...
            mod_type, nRepeats, nShuffles, specified_lr);

    case 'selectivity' %uses only control trials
        [cv_mod_index, cv_mod_index_separate, bootstrapResults] = ...
            handle_selectivity_mode(stim_data, ctrl_data, stim_trials, ctrl_trials, ...
            current_conditions, current_conditions_ctrl, response_range, ...
            mod_type, nRepeats, nShuffles, specified_lr);
            
    case 'simple' %does no balancing uses trials given
        [cv_mod_index, bootstrapResults] = calc_simple_mod_index_cv(...
            stim_data, ctrl_data, response_range, mod_type, nRepeats, nShuffles);
        cv_mod_index_separate = [];
        
    otherwise
        error('Unknown mode. Please choose from: %s', strjoin(VALID_MODES, ', '));
end
end








