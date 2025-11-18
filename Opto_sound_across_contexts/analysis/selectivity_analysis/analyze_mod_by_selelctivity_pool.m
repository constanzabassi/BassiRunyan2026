function selectivity_results = analyze_mod_by_selelctivity_pool(mod_index_results, pools, params)
%description of function... divide modulation indices based on pools of
%selectiivty per cells

pool_fields = fields(pools.active);

    for context_index = 1:2
        if context_index == 1
            context_id = 'active';
        else
            context_id = 'passive';
        end

        for current_pool = 1:length(pool_fields)
            current_pool_field = pool_fields{current_pool};
            left_mod{context_index}.(current_pool_field) = mod_index_results.context(context_index).cv_mod_index_separate.left(pools.(context_id).(current_pool_field));
            right_mod{context_index}.(current_pool_field) = mod_index_results.context(context_index).cv_mod_index_separate.right(pools.(context_id).(current_pool_field));
        end
        
    end
