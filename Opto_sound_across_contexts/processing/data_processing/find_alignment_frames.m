function frames = find_alignment_frames (alignment_frames,event_id,left_padding,right_padding)

frames = zeros(size(alignment_frames, 2), sum(left_padding(event_id)) + sum(right_padding(event_id)) + length(event_id));
for i=1:size(alignment_frames, 2)
    temp_frames = [];
    for events = event_id;%1:size(alignment_frames,1)
        temp_frames = cat(2,temp_frames,alignment_frames(events,i) + (-left_padding(events):right_padding(events)));
    end
    frames(i,:) = temp_frames;
end

%get rid of zero frames (for passive)
if length(find(frames==0))>1
    zero_frames = find(frames(1,:)==0);
    frames(:,zero_frames) = [];
end
