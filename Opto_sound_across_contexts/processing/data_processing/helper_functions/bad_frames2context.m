function context_tr = bad_frames2context (bad_frames,exp,nonexp,context_intervals)
for context = 1:length(context_intervals)
    context_tr{context,1} = exp(find(ismember(exp,context_intervals{context})));
    context_tr{context,2} = nonexp(find(ismember(nonexp,context_intervals{context})));
    context_tr{context,3} = find(ismember(exp,context_intervals{context}));
    context_tr{context,4} = find(ismember(nonexp,context_intervals{context}));
end