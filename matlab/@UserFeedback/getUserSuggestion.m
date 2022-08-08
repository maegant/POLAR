function coac_data = getUserSuggestion(obj, alg, iteration)
% Query user for coactive suggestion

%%%%%%%%%%%%
% This function translates user suggestions into coactive feedback (i.e., a
%   suggested improvement). To do this, we translate feedback of the form
%   "suggested direction in a given action space dimension". For example,
%   coactive user feedback could be "I would prefer a longer step length"
%   for gait tuning. This function then translates this type of user
%   feedback into a pairwise preference between the sampled action and a
%   synthetic coactive action where the coactive action is preferred.
%
%   Method: Coactive actions are selected as the neighboring action in a
%   specified coordinate dimension and in a specified direction
%
% Outputs:
%   feedback has the following structure elements:
%     1) c_x_subset: nx2 index comparisons in terms of subset indices
%     2) c_x_full: nx2 index comparisons in terms of global indices
%     3) c_y = nx1 preferences corresponding to coactive comparisons
%           (always 2 to signify that second index in comparisons is
%           suggested action);
%
%%%%%%%%%%%%

if nargin < 2
    iteration = length(alg.iteration);
end

coac_data = struct('c_x_subset',[],'c_x_full',[],'c_y', []);

if any(alg.settings.feedback.types == 2)
    
    % go through each of the sampled actions
    num_actions = length(alg.iteration(iteration).samples.visitedInds);
    num_dims = length(alg.settings.parameters);
    for n = 1:num_actions
        
        % get the action that is being compared to:
        current_action = alg.iteration(iteration).samples.actions(n,:);
        current_globalInd = alg.iteration(iteration).samples.globalInds(n);
        current_visitedInd = alg.iteration(iteration).samples.visitedInds(n);
        
        % ask user if they have a suggestion
        isFeedback = input(sprintf('Enter suggestion for sampled action %i? (y or n): ',n),'s');
        while ~any([strcmpi(isFeedback,'y'), strcmpi(isFeedback,'n')])
            isFeedback = input('Error - Input must be y or n: ','s');
        end
        
        % if there is a suggestion get more information
        if strcmpi(isFeedback,'y')
            
            % get dimensions
            dim = input(sprintf(['Enter dimensions to give feedback ', ...
                '\n (vector of scalars between 1:%i corresponding to ', ...
                '[', repmat('%s, ',1,num_dims-1),'%s]): '], ...
                num_dims, alg.settings.parameters(:).name));
            while ~all(ismember(dim,1:num_dims))
                dim = input(sprintf('Error - input must be vector of scalars between 1 and %i: ', num_dims));
            end
            
            % initialize outputs based on number of params with feedback
            coac_data.c_x_subset = zeros(length(dim),2);
            coac_data.c_x_full = zeros(length(dim),2);
            coac_data.c_y = 2*ones(length(dim),1);
            
            
            % go through each of the dims in which user has suggestion
            for d = 1:length(dim)
                
                % get direction
                direction = input(sprintf('smaller or larger for dimension %i? (1 or 2): ',dim(d)));
                while ~any(direction == [1,2])
                    direction = input('Error - must be scalar 1 or 2: ');
                end
                
                % convert dimension and direction into a delta
                delta = zeros(1,num_dims);
                if direction == 1
                    
                    % calculate delta for smaller direction
                    delta(d) = -alg.settings.parameters(dim(d)).discretization;
                    
                elseif direction == 2
                    
                    % calculate delta for larger direction
                    delta(d) = alg.settings.parameters(dim(d)).discretization;
                    
                else
                    warning('There was a bug in the code, direction should only be 1 or 2');
                end
                
                % apply delta to get suggested action
                suggested_action = current_action + delta;
                suggested_action = boundAction(alg,suggested_action);
                
                if ~isequal(suggested_action,current_action)
                    
                    % find globalInd closest to suggested action
                    suggested_globalInd = alg.getGlobalInd(suggested_action);
                    
                    % get visitedInd for suggested action
%                     suggested_visitedInd = alg.getVisitedInd(suggested_action);
%                     
                    
                    % append coactive point to output
                    coac_data.c_x_subset(d,:) = [current_visitedInd, 0];
                    coac_data.c_x_full(d,:) = [current_globalInd, suggested_globalInd];
                    
                end
            end
        end
    end
end

% remove all zero rows
zero_rows = all(coac_data.c_x_subset == 0,2);
coac_data.c_x_subset(zero_rows,:) = [];
coac_data.c_x_full(zero_rows,:) = [];
coac_data.c_y(zero_rows,:) = [];

end


% make sure coactive point is within action bounds
function bounded_action = boundAction(alg,suggested_action)
bounded_action = max(alg.settings.lower_bounds,suggested_action);
bounded_action = min(alg.settings.upper_bounds,bounded_action);
end