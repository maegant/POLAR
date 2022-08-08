function getOptimalError(metrics,alg,iteration)

if nargin < 3
    iteration = length(alg.iteration);
end

% Get true objective associated with best action
if alg.settings.useSyntheticObjective
    
    % Compute instantaneous regret
    cur_sample_utilities = alg.settings.simulation.true_objectives(alg.iteration(iteration).samples.globalInds);
    metrics.inst_regret = sum(alg.settings.simulation.true_bestObjective - cur_sample_utilities);
    
end

end