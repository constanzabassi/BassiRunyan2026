function [stim_splits, ctrl_splits, stim_splits_all, ctrl_splits_all] = make_threeway_cv_splits(total_trials_stim, total_trials_ctrl)
% Create 3-way CV splits for stim and ctrl across 2 contexts
% Outputs:
%   stim_splits{ctx}(f)  -> per-context splits (ctx=1:2, f=1:3)
%   ctrl_splits{ctx}(f)  -> per-context splits
%   stim_splits_all(f)   -> combined across both contexts
%   ctrl_splits_all(f)   -> combined across both contexts

    ctx_count_stim = 0;
    ctx_count_ctrl = 0;

    stim_splits = cell(1,2);
    ctrl_splits = cell(1,2);

    for ctx = 1:2
        % Stim trials
        stim_splits{ctx} =  get_threeway_cv(total_trials_stim(ctx));
        for f = 1:3
            stim_splits{ctx}(f).trainA = stim_splits{ctx}(f).trainA + ctx_count_stim;
            stim_splits{ctx}(f).trainB = stim_splits{ctx}(f).trainB + ctx_count_stim;
            stim_splits{ctx}(f).test   = stim_splits{ctx}(f).test   + ctx_count_stim;
        end

        % Ctrl trials
        ctrl_splits{ctx} = get_threeway_cv(total_trials_ctrl(ctx));
        for f = 1:3
            ctrl_splits{ctx}(f).trainA = ctrl_splits{ctx}(f).trainA + ctx_count_ctrl;
            ctrl_splits{ctx}(f).trainB = ctrl_splits{ctx}(f).trainB + ctx_count_ctrl;
            ctrl_splits{ctx}(f).test   = ctrl_splits{ctx}(f).test   + ctx_count_ctrl;
        end

        % Update offsets
        ctx_count_stim = ctx_count_stim + total_trials_stim(ctx);
        ctx_count_ctrl = ctx_count_ctrl + total_trials_ctrl(ctx);
    end

    % --- Combine across contexts ---
    for f = 1:3
        stim_splits_all(f).trainA = [stim_splits{1}(f).trainA, stim_splits{2}(f).trainA];
        stim_splits_all(f).trainB = [stim_splits{1}(f).trainB, stim_splits{2}(f).trainB];
        stim_splits_all(f).test   = [stim_splits{1}(f).test,   stim_splits{2}(f).test];

        ctrl_splits_all(f).trainA = [ctrl_splits{1}(f).trainA, ctrl_splits{2}(f).trainA];
        ctrl_splits_all(f).trainB = [ctrl_splits{1}(f).trainB, ctrl_splits{2}(f).trainB];
        ctrl_splits_all(f).test   = [ctrl_splits{1}(f).test,   ctrl_splits{2}(f).test];
    end
end

