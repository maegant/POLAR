function updateBestAction(obj,iteration)

if nargin < 2
    iteration = length(obj.iteration);
end


model = obj.post_model(iteration);
num_actions = size(obj.unique_visited_actions,1);

% Consider entire posterior
visited_means = model.mean;

if isempty(visited_means)
    
    % If posterior model is empty - take best action as the last sampled
    % action
    best_action = obj.iteration(iteration).samples.actions(num_actions,:);
else
    
    % Take the best action to be the action that maximizes the posterior
    [~,bestInd] = max(visited_means);
    best_action = model.actions(bestInd,:);
end

% Store best action in structure
obj.iteration(iteration).best.action = best_action;
[~,obj.iteration(iteration).best.visitedInd] = min(vecnorm(best_action - obj.unique_visited_actions,2,2));
if isempty(obj.settings.points_to_sample)
    obj.iteration(iteration).best.globalInd = [];
else
    [~,obj.iteration(iteration).best.globalInd] = min(vecnorm(best_action - obj.settings.points_to_sample,2,2));
end

% Get true objective associated with best action
if obj.settings.useSyntheticObjective
    true_utility = obj.settings.simulation.true_objectives(obj.iteration(iteration).best.globalInd);
    obj.iteration(iteration).best.true_utility = true_utility;
    obj.iteration(iteration).best.optimal_error = obj.settings.simulation.true_bestObjective - true_utility;
    
    % get fit error
    post_vals = obj.post_model(iteration).mean;
    true_vals = obj.settings.simulation.true_objectives(obj.post_model(iteration).action_globalInds);
    obj.iteration(iteration).best.fit_error = norm(post_vals-true_vals,2);
    
end

end