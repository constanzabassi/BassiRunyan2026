function event_onsets = determine_onsets(left_padding,right_padding,event_id)
temp = [];
for e = 1:length(event_id)
    if e == 1
        temp = left_padding(event_id(e))+1;
    else
        temp = [temp+left_padding(event_id(e))+1+right_padding(event_id(e-1))];
    end
    event_onsets(e,:) = temp;
end
