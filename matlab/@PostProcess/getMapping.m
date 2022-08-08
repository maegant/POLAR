function newSampleGlobalInds = getMapping(obj,alg,samples)
% Get mapping from original action space to finer action space

num_original_points = size(alg.settings.points_to_sample,1);
newSampleGlobalInds = zeros(num_original_points,1);

for i = 1:num_original_points
    [~,newSampleGlobalInds(i)] = min(vecnorm(alg.settings.points_to_sample(i,:) - samples,2,2));    
end
