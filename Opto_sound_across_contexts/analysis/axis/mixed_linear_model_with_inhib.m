function [lme,tbl,proj_all,engagement_proj_all,inhib_proj_all,context_all] = mixed_linear_model_with_inhib(proj, axis_type, celltype, frame_range_pre, frame_range_post, inhib_proj, varargin)
%% Linear mixed effects model with additional inhibitory predictor (e.g., PV/SOM post)

proj_all = [];
engagement_proj_all = [];
inhib_proj_all = [];
context_all = [];
animal_id_all = [];
n_datasets = 24;

for dataset = 1:n_datasets
    for ctx = 1:2   % context 1=active, 2=passive
        s_proj = mean(proj{dataset, celltype(1), ctx}.(lower(axis_type))(:, frame_range_post), 2); % post
        
        if length(celltype) > 1
            if nargin > 6
                e_proj = mean(proj{dataset, celltype(2), ctx}.(lower(varargin{1,1}))(:, frame_range_pre), 2); % pre
            else
                e_proj = mean(proj{dataset, celltype(2), ctx}.context(:, frame_range_pre), 2); % pre
            end
        else
            if nargin > 6
                e_proj = mean(proj{dataset, celltype, ctx}.(lower(varargin{1,1}))(:, frame_range_pre), 2); % pre
            else
                e_proj = mean(proj{dataset, celltype, ctx}.context(:, frame_range_pre), 2); % pre
            end
        end

        if nargin > 8
            i_proj = mean(inhib_proj{dataset, celltype(3), ctx}.(lower(varargin{1,3}))(:,frame_range_post), 2); % inhibitory (e.g., orthogonalized PV/SOM post)
        else
            i_proj = mean(inhib_proj{dataset, celltype(3), ctx}.stim_post(:,frame_range_post), 2); % inhibitory (e.g., orthogonalized PV/SOM post)
        end
        proj_all = [proj_all; s_proj];
        engagement_proj_all = [engagement_proj_all; e_proj];
        inhib_proj_all = [inhib_proj_all; i_proj];
%         context_all = [context_all; repmat(ctx-1, size(s_proj,1), 1)];

        if nargin > 7 && varargin{1,2} == 1%change reference to get intercept and slopes for each context
            context_all = [context_all; repmat(rem(ctx,2), size(s_proj,1), 1)];% 1 = active/0 = passive (change reference)
        else
            context_all = [context_all; repmat(ctx-1, size(s_proj,1), 1)];  % 0 = active/1 = passive
        end

        animal_id_all = [animal_id_all; repmat(dataset, size(s_proj,1), 1)];
    end
end

animal_id_all = categorical(animal_id_all);

response_var = strcat(axis_type, 'Proj');
tbl = table(proj_all, engagement_proj_all, inhib_proj_all, context_all, animal_id_all, ...
    'VariableNames', {response_var, 'EngagementProj', 'InhibProj', 'Context', 'AnimalID'});
tbl.Context = categorical(tbl.Context);
% Include interaction terms to allow context-dependent effects of both engagement and inhibition
formula = sprintf('%s ~ EngagementProj * Context + InhibProj * Context + (1|AnimalID)', response_var);
lme = fitlme(tbl, formula);
disp(lme)
