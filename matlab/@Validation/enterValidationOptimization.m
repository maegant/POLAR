function enterValidationOptimization(obj,alg,num_trials)
% Begins a validation phase to validate the provided posterior model.

%% Get num_trials new actions
obj.getOptimizationActions(alg,num_trials);

%% Predict Labels
obj.predicted_feedback.preferences = ones(num_trials,1);

%% Execute all comparisons, and get user preferences
for i = 1:num_trials
    
    % compare best action and random action
    actions_to_print = [obj.actions(1,:);obj.actions(1+i,:)];
    val_num = [2*i-1,2*i];
    obj.printValidationAction(alg,actions_to_print,val_num)
    
    % Get user preference
    preference = obj.getUserPreference;
    
    obj.actual_feedback.preferences(i,1) = preference;
end


end



