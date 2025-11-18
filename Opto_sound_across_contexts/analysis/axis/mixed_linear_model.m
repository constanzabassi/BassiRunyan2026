function [lme,tbl,proj_all,engagement_proj_all,context_all] = mixed_linear_model(proj, axis_type,celltype,frame_range_pre,frame_range_post,varargin)
%% linear mixed models 

proj_all = [];
engagement_proj_all = [];
context_all = [];
animal_id_all = [];
n_datasets = 24;
for dataset = 1:n_datasets
    for ctx = 1:2   % context 1=active, 2=passive
        s_proj = mean(proj{dataset, celltype(1), ctx}.(lower(axis_type))(:,frame_range_post), 2); % post
        % IN CASE WE WANT TO COMPARE DIFFERENT CELL TYPES
        if length(celltype) > 1
            if nargin > 5 %compare to something besides context
                e_proj = mean(proj{dataset,celltype(2),ctx}.(lower(varargin{1,1}))(:,frame_range_pre), 2); % pre
            else
                e_proj = mean(proj{dataset,celltype(2),ctx}.context(:,frame_range_pre), 2); % pre
            end
        else
            if nargin > 5 %compare to something besides context
                e_proj = mean(proj{dataset,celltype,ctx}.(lower(varargin{1,1}))(:,frame_range_pre), 2); % pre
            else
                e_proj = mean(proj{dataset,celltype,ctx}.context(:,frame_range_pre), 2); % pre
            end
        end

        proj_all = [proj_all; s_proj];
        engagement_proj_all = [engagement_proj_all; e_proj];

        if nargin > 6 %change reference to get intercept and slopes for each context
            context_all = [context_all; repmat(rem(ctx,2), size(s_proj,1), 1)];% 1 = active/0 = passive (change reference)
        else
            context_all = [context_all; repmat(ctx-1, size(s_proj,1), 1)];  % 0 = active/1 = passive
        end
        animal_id_all = [animal_id_all; repmat(dataset, size(s_proj,1), 1)];
    end
end
% convert to categorical
animal_id_all = categorical(animal_id_all);

response_var = strcat(axis_type, 'Proj');
tbl = table(proj_all, engagement_proj_all, context_all, animal_id_all, ...
    'VariableNames', {strcat(axis_type,'Proj'),'EngagementProj','Context','AnimalID'});

formula = sprintf('%s ~ EngagementProj * Context + (1|AnimalID)', response_var);
lme = fitlme(tbl, formula);
disp(lme)

% %% 2) STIM
% 
% stim_proj_all = [];
% engagement_proj_all = [];
% context_all = [];
% animal_id_all = [];
% n_datasets = 24;
% for n = 1:n_datasets
%     for c = 1:2   % context 1=active, 2=passive
%         s_proj = mean(proj{n,4,c}.stim(:,frame_range2), 2); % post
%         e_proj = mean(proj{n,4,c}.context(:,frame_range1), 2); % pre
%         stim_proj_all = [stim_proj_all; s_proj];
%         engagement_proj_all = [engagement_proj_all; e_proj];
%         context_all = [context_all; repmat(c-1, size(s_proj,1), 1)];  % 0/1
%         animal_id_all = [animal_id_all; repmat(n, size(s_proj,1), 1)];
%     end
% end
% % convert to categorical
% animal_id_all = categorical(animal_id_all);
% 
% 
% tbl = table(stim_proj_all, engagement_proj_all, context_all, animal_id_all, ...
%     'VariableNames', {'StimProj','EngagementProj','Context','AnimalID'});
% lme = fitlme(tbl, 'StimProj ~ EngagementProj * Context + (1|AnimalID)');
% disp(lme)