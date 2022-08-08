function newSampleGlobalInds = getGlobalInd(obj,samples)
% Gets global index of action according to obj.settings.points_to_sample

if isempty(obj.settings.points_to_sample)
    newSampleGlobalInds = [];
else
    num_samples = size(samples,1);
    newSampleGlobalInds = zeros(num_samples,1);
    
    for i = 1:num_samples
        [~,newSampleGlobalInds(i)] = min(vecnorm(samples(i,:) - obj.settings.points_to_sample,2,2));
    end
end
