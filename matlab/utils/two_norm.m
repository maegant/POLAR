function [objectives, best_objective, best_action, best_action_ind] = two_norm(actions)

% random best action 
best_action_ind = randsample(size(actions,1),1);
best_action = actions(best_action_ind,:);

objectives = vecnorm(actions-best_action,2,2);

% convert to percent of best objective (0 - 1)
objectives = (objectives - min(objectives))./(max(objectives) - min(objectives));
best_objective = max(objectives); %should be 1

end