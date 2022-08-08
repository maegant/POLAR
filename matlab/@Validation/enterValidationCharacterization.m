function enterValidationCharacterization(obj,alg,num_trials)
% Begins a validation phase to validate the provided posterior model.

%% Get num_trials new actions (also predicts the labels)
obj.getCharacterizationActions(alg,num_trials);

%% Execute all trials, and get user labels
for i = 1:num_trials
    
    % compare best action and random action
    actions_to_print = obj.actions(i,:);
    obj.printValidationAction(alg,actions_to_print,i)
    
    % Get user preference
    label = obj.getUserLabel(alg);
    
    obj.actual_feedback.labels(i,1) = label;
end

end