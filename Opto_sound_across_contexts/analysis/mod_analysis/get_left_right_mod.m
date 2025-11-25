function summary_dict= get_left_right_mod(summary_dict)
ndatasets = length(summary_dict.mod);
ncontexts = 2;

for d = 1:ndatasets
    for contexts = 1:ncontexts
        summary_dict.mod_left{d,contexts} = summary_dict.results(d).context(contexts).cv_mod_index_separate.left;
        summary_dict.mod_right{d,contexts} = summary_dict.results(d).context(contexts).cv_mod_index_separate.right;
    end
end
