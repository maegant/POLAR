function newSampleVisitedInds = getVisitedInd(obj,samples)
% gets unique index of action based on obj.unique_visited_actions

num_samples = size(samples,1);
newSampleVisitedInds = zeros(num_samples,1);
temp_new_unique = obj.unique_visited_actions;

for i = 1:num_samples
    
    currentSample = samples(i,:);
    
    if ~isempty(temp_new_unique)
        if min(vecnorm(currentSample - temp_new_unique,2,2)) < 1e-3
            [~,ind] = min(vecnorm(currentSample - temp_new_unique,2,2));
            newSampleVisitedInds(i) = ind(1);
        else
            temp_new_unique = cat(1,temp_new_unique,currentSample);
            newSampleVisitedInds(i) = size(temp_new_unique,1);
        end
    else
        temp_new_unique = currentSample;
        newSampleVisitedInds(i) = 1;
    end
    
end
