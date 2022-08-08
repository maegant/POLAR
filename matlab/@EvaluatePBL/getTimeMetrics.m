function getTimeMetrics(metrics,alg,iteration)

if nargin < 3
    iteration = length(alg.iteration);
end

% Get true objective associated with best action
if alg.settings.useSyntheticObjective

    metrics.post_update_time = alg.comp_time.posterior(iteration);
    metrics.acq_time = alg.comp_time.acquisition(iteration);
end

end