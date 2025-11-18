function sorting_ids = sort_avg_context_index(index)

meancontextindex = nanmean(index , 2);%nanmean(stim_mod(chosen_cels,:) , 2);
[~ ,sorting_ids] = sort(meancontextindex,'descend');
