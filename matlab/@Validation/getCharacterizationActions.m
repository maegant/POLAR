function getCharacterizationActions(obj,alg,num_trials)
% Description:
%   - alg: preference-based learing algorithm object
%   - num_trials: number of total actions to execute during validation. Each
%           action samples an ordinal category excluding the roa

%% Use last GP as approximation of final GP
model = alg.post_model(end);

%%
all_ord_categories = 1:alg.settings.feedback.num_ord_categories;

if alg.settings.roa.use_roa
    ord_categories = all_ord_categories(all_ord_categories > alg.settings.roa.ord_label_to_avoid);
else
    ord_categories = all_ord_categories;
end
ord_thresholds = alg.settings.gp_settings.ordinal_thresholds;

% Evenly divide actions in each category, then randomly sample the
%   actions for the remaining trials
num_categories = length(ord_categories);
num_actions_per_cat = floor(num_trials/num_categories);
all_actions = [];
obj.predicted_feedback.labels = [];
for ord = ord_categories
    cur_range = ord_thresholds([ord,ord+1]);
    for i = 1:num_actions_per_cat
        isValidAction = 0;
        
        while ~isValidAction
           
            % get action corresponding to current ordinal category
            isValidAction = 1;
            action_inds_for_cat = find(model.mean > cur_range(1) & model.mean < cur_range(2));
            
            if isempty(action_inds_for_cat)
                error(sprintf('No actions with ord label %i',ord));
            end
            
            randInd = randsample(action_inds_for_cat,1);
            temp_action = model.actions(randInd,:);
            temp_utility = model.mean(randInd);
            
            % for sanity -- check if action is within ordinal category
             if ~(temp_utility > cur_range(1) && temp_utility < cur_range(2))
                 isValidAction = 0;
             else
                 % check if action is repeating
                 for j = 1:size(all_actions,1)
                     if temp_action == all_actions(j,:)
                         isValidAction = 0;
                     end
                 end
             end
             
        end
        
        % Assign valid action to list of actions
        all_actions = cat(1,all_actions,temp_action);
        
        % Assign predicted label to predicted labels
        obj.predicted_feedback.labels = cat(1,obj.predicted_feedback.labels,ord);
    end
end

%% Add random actions as remaining actions
for i = 1:num_trials-(num_actions_per_cat*num_categories)
    isValidAction = 0;
    
    while ~isValidAction
        
        % get action corresponding to current ordinal category
        isValidAction = 1;
        randInd = randsample(size(model.actions,1),1);
        temp_action = model.actions(randInd,:);
        temp_utility = model.mean(randInd);
            
        % check if action is outside of roa
        if alg.settings.roa.use_roa
            if temp_utility < ord_thresholds(alg.settings.roa.ord_label_to_avoid+1)
                 isValidAction = 0;
            end
        end
        
        % check that action isn't repeating
        for j = 1:size(all_actions,1)
            if temp_action == all_actions(j,:)
                isValidAction = 0;
            end
        end
    end
    
    % Assign valid action to list of actions
    all_actions = cat(1,all_actions,temp_action);
    
    % Assign predicted label to predicted labels
    temp = find(temp_utility > ord_thresholds);
    predicted_label = temp(end);
    obj.predicted_feedback.labels = cat(1,obj.predicted_feedback.labels,predicted_label);
    
end

%% Randomize the order of the actions
random_order = randsample(1:num_trials,num_trials);
obj.actions = all_actions(random_order,:);
obj.predicted_feedback.labels = obj.predicted_feedback.labels(random_order,1);


end