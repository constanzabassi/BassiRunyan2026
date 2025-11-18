function coeff_struct_final = extract_and_rename_coefficients(lme_active, lme_passive, source_model, new_labels)
% Extracts:
%   - EngagementProj slopes from BOTH models (active/passive reference)
%   - Context and Interaction from the specified source_model
%
% Inputs:
%   lme_active   : model with active = 0 as reference
%   lme_passive  : model with passive = 0 as reference
%   source_model : 'active' or 'passive'
%   new_labels   : (optional) cell array of custom names for output
%
% Output:
%   coeff_struct: struct with fields
%       - names
%       - estimates
%       - SEs
%       - pvals

    % Check source model validity
    if strcmpi(source_model, 'active')
        fe_source = lme_active.Coefficients;
    elseif strcmpi(source_model, 'passive')
        fe_source = lme_passive.Coefficients;
    elseif isempty(source_model)
        fe_source = lme_active.Coefficients;
    else
        error('source_model must be either "active" or "passive" or empty');
    end

    % Get slope from both models
    % Active reference
    fe_a = lme_active.Coefficients;
    idx_slope_a = strcmp(fe_a.Name, 'EngagementProj');
    slope_active = fe_a.Estimate(idx_slope_a);
    se_active = fe_a.SE(idx_slope_a);
    pval_active = fe_a.pValue(idx_slope_a);

    % Passive reference
    fe_p = lme_passive.Coefficients;
    idx_slope_p = strcmp(fe_p.Name, 'EngagementProj');
    slope_passive = fe_p.Estimate(idx_slope_p);
    se_passive = fe_p.SE(idx_slope_p);
    pval_passive = fe_p.pValue(idx_slope_p);

    % From source model: context and interaction
    idx_ctx = ismember(fe_source.Name, {'Context', 'Context_1'});
    idx_inter = ismember(fe_source.Name, {'EngagementProj:Context', 'EngagementProj:Context_1'});

    context_coef = fe_source.Estimate(idx_ctx);
    se_ctx       = fe_source.SE(idx_ctx);
    pval_ctx     = fe_source.pValue(idx_ctx);

    inter_coef   = fe_source.Estimate(idx_inter);
    se_inter     = fe_source.SE(idx_inter);
    pval_inter   = fe_source.pValue(idx_inter);

    % Output names
    default_names = {'Slope (Active)', 'Slope (Passive)', 'Context', 'Interaction'};
    if nargin < 4 || isempty(new_labels)
        names = default_names;
    else
        names = new_labels;
    end

    % Package
    coeff_struct.Name     = names;
    coeff_struct.Estimate = [slope_active, slope_passive, context_coef, inter_coef];
    coeff_struct.SE       = [se_active, se_passive, se_ctx, se_inter];
    coeff_struct.pValue     = [pval_active, pval_passive, pval_ctx, pval_inter];

    coeff_struct_final.Coefficients = coeff_struct;

    if isempty(source_model)
        % Package
        coeff_struct.Name     = names;
        coeff_struct.Estimate = [slope_active, context_coef, inter_coef];
        coeff_struct.SE       = [se_active, se_ctx, se_inter];
        coeff_struct.pValue     = [pval_active, pval_ctx, pval_inter];
    
        coeff_struct_final.Coefficients = coeff_struct;
    end

end
