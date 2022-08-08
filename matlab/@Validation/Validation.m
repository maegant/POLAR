classdef Validation < handle
    % Evaluate the accuracy of the preference-based learning framework
    %   - For preference-optimization:
    %          compare best action to randomly selected actions using blind
    %          comparisons
    %   - For preference-characterization:
    %          compare predicted ordinal labels with user provided ordinal
    %          labels across the entire action space (not including ROA)
    
    properties
        actions
        comparisons
        predicted_feedback
        actual_feedback
    end
    
    methods
        function obj = Validation(alg,num_trials)
            
            switch alg.settings.sampling.type
                case 1 %Thompson Sampling
                    obj.enterValidationOptimization(alg,num_trials);
                case 2
                    obj.enterValidationCharacterization(alg,num_trials);
            end
            
        end
    end
    
    methods (Access = 'private')
        % get actions
        getOptimizationActions(obj,alg,num_trials);
        getCharacterizationActions(obj,alg,num_trials);
        
        % validation
        enterValidationOptimization(obj,alg,num_trials);
        enterValidationCharacterization(obj,alg,num_trials);
    end
    
    methods (Static)

        function preference = getUserPreference
            preference = input('Which gait do you prefer? (1,2 or 0 for no preference):   ');
            while ~any([preference == 0, preference == 1, preference == 2])
                preference = input('Incorrect input given. Please enter 0, 1 or 2:   ');
            end
        end
        
        function label = getUserLabel(alg)
            num_ord_cat = alg.settings.feedback.num_ord_categories;
            label = input(sprintf('Label for Val Action (0:%i where 0 is no label): ',num_ord_cat));
            while floor(label) ~= label || ~any(label == 0:num_ord_cat)
                if floor(label) ~= label
                    label = input('Error - Label must be an integer: ');
                end
                if ~any(label == 0:num_ord_cat)
                    label = input(sprintf('Error - Label must be between 0 and %i: ',num_ord_cat));
                end
            end
        end
        
        function printValidationAction(alg,actions_to_print,val_num)
        
            % Print all actions to execute
            for i = 1:size(actions_to_print,1)
                num_params = length(alg.settings.parameters);
                actionformat = ['[',repmat('%f, ',1,num_params-1), '%f] \n'];
                fprintf(sprintf(['Validation Action %i: ',actionformat],val_num(i),actions_to_print(i,:)));
            end
            
        end
    end
end

