function getOptimizationActions(obj,alg,num_trials)
% Description:
%   - alg: preference-based learing algorithm object
%   - num_trials: number of comparisons to execute during validation. Each
%           comparison consists of two actions: the best action, and one randomly
%           selected action

% obtain best action
best_action = alg.iteration(end).best.action;

all_rand_actions = [];
for i = 1:num_trials
    isValidAction = 0;
    
    
    while ~isValidAction
        
        % get random action and assume it's valid
        isValidAction = 1;
        temp_action = Sampling.getRandAction(alg,1);
        
        % check conditions under which action wouldn't be valid
        if temp_action == best_action
            isValidAction = 0;
        else
            % check that random action isn't same as any of the previously
            % sampled random actions
            for j = 1:size(all_rand_actions,1)
               if temp_action == all_rand_actions(j,:)
                   isValidAction = 0;
               end
            end
        end
               
    end
    
    % Assign valid action to list of random actions
    all_rand_actions = cat(1,all_rand_actions,temp_action);
    
end

% Append all actions together
obj.actions = [best_action;all_rand_actions];

% Get comparisons
obj.comparisons = [ones(num_trials,1),reshape(2:num_trials+1,[],1)];

end