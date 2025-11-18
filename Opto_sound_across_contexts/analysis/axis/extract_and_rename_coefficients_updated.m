function coeff_struct_final = extract_and_rename_coefficients_updated(lme_active, lme_passive, source_model, new_labels)
% Updated version to extract:
%   - Slopes for EngagementProj and InhibProj from BOTH models (active/passive reference)
%   - Context and both interaction terms from the specified source_model
%
% Inputs:
%   lme_active   : model with active = 0 as reference
%   lme_passive  : model with passive = 0 as reference
%   source_model : 'active' or 'passive'
%   new_labels   : (optional) custom names for the output
%
% Output:
%   coeff_struct_final: struct with fields
%       - Name
%       - Estimate
%       - SE
%       - pValue

    % Choose source model for context/interactions
    if strcmpi(source_model, 'active')
        fe_source = lme_active.Coefficients;
    elseif strcmpi(source_model, 'passive')
        fe_source = lme_passive.Coefficients;
    elseif isempty(source_model)
        fe_source = lme_active.Coefficients;
    else
        error('source_model must be either "active" or "passive"');
    end

    % --- Slopes from both models ---
    % EngagementProj
    fe_a = lme_active.Coefficients;
    idx_eng_a = strcmp(fe_a.Name, 'EngagementProj');
    slope_eng_a = fe_a.Estimate(idx_eng_a);
    se_eng_a = fe_a.SE(idx_eng_a);
    p_eng_a = fe_a.pValue(idx_eng_a);

    fe_p = lme_passive.Coefficients;
    idx_eng_p = strcmp(fe_p.Name, 'EngagementProj');
    slope_eng_p = fe_p.Estimate(idx_eng_p);
    se_eng_p = fe_p.SE(idx_eng_p);
    p_eng_p = fe_p.pValue(idx_eng_p);

    % InhibProj
    if any(ismember(fe_a.Name,'InhibProj'))
        idx_inhib_a = strcmp(fe_a.Name, 'InhibProj');
        slope_inhib_a = fe_a.Estimate(idx_inhib_a);
        se_inhib_a = fe_a.SE(idx_inhib_a);
        p_inhib_a = fe_a.pValue(idx_inhib_a);
    
        idx_inhib_p = strcmp(fe_p.Name, 'InhibProj');
        slope_inhib_p = fe_p.Estimate(idx_inhib_p);
        se_inhib_p = fe_p.SE(idx_inhib_p);
        p_inhib_p = fe_p.pValue(idx_inhib_p);
    else
        idx_inhib_a = [];
        slope_inhib_a = [];
        se_inhib_a = [];
        p_inhib_a = [];

        idx_inhib_p = [];
        slope_inhib_p = [];
        se_inhib_p = [];
        p_inhib_p = [];
    end

    % --- From source model: Context & Interaction terms ---
    idx_ctx = ismember(fe_source.Name, {'Context', 'Context_1'});
    idx_inter_eng = ismember(fe_source.Name, {'EngagementProj:Context', 'EngagementProj:Context_1'});
    idx_inter_inhib = ismember(fe_source.Name, {'InhibProj:Context', 'InhibProj:Context_1'});

    context_coef = fe_source.Estimate(idx_ctx);
    se_ctx       = fe_source.SE(idx_ctx);
    pval_ctx     = fe_source.pValue(idx_ctx);

    inter_eng_coef = fe_source.Estimate(idx_inter_eng);
    se_inter_eng   = fe_source.SE(idx_inter_eng);
    pval_inter_eng = fe_source.pValue(idx_inter_eng);

    inter_inhib_coef = fe_source.Estimate(idx_inter_inhib);
    se_inter_inhib   = fe_source.SE(idx_inter_inhib);
    pval_inter_inhib = fe_source.pValue(idx_inter_inhib);

    % --- Output Names ---
    default_names = {
        'Engagement Slope (Active)', ...
        'Engagement Slope (Passive)', ...
        'Inhib Slope (Active)', ...
        'Inhib Slope (Passive)', ...
        'Context', ...
        'Engagement x Context', ...
        'Inhib x Context'};

    if nargin < 4 || isempty(new_labels)
        names = default_names;
    else
        names = new_labels;
    end

    % --- Package Output ---
    coeff_struct.Name = names;
    coeff_struct.Estimate = [
        slope_eng_a, ...
        slope_eng_p, ...
        slope_inhib_a, ...
        slope_inhib_p, ...
        context_coef, ...
        inter_eng_coef, ...
        inter_inhib_coef];
    coeff_struct.SE = [
        se_eng_a, ...
        se_eng_p, ...
        se_inhib_a, ...
        se_inhib_p, ...
        se_ctx, ...
        se_inter_eng, ...
        se_inter_inhib];
    coeff_struct.pValue = [
        p_eng_a, ...
        p_eng_p, ...
        p_inhib_a, ...
        p_inhib_p, ...
        pval_ctx, ...
        pval_inter_eng, ...
        pval_inter_inhib];

    coeff_struct_final.Coefficients = coeff_struct;

    if isempty(source_model)
        % Package
        coeff_struct.Name = names;
        coeff_struct.Estimate = [
            slope_eng_a, ...
            
            slope_inhib_a, ...
            
            context_coef, ...
            inter_eng_coef, ...
            inter_inhib_coef];
        coeff_struct.SE = [
            se_eng_a, ...
            
            se_inhib_a, ...
            
            se_ctx, ...
            se_inter_eng, ...
            se_inter_inhib];
        coeff_struct.pValue = [
            p_eng_a, ...
            
            p_inhib_a, ...
            
            pval_ctx, ...
            pval_inter_eng, ...
            pval_inter_inhib];
        coeff_struct_final.Coefficients = coeff_struct;
    end
end
