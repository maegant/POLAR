function coac_data = getSyntheticSuggestion(feedback,alg, iteration)
%%%%%%%%%%%%
% This function returns coactive feedback (i.e., a suggested improvement)
%   for the specified point. To do this, we use information about the
%   objective function in an epsilon ball around the queried point, with
%   epsilon equal to settings.synth_coac.sightRanges. The default for this is
%   20% of the parameter range. The action with the highest true objective
%   utility within the epsilon ball is given as the suggested action.
%
% Outputs:
%   coac_feedback has the following structure elements:
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

if any(alg.settings.feedback.types == 2)
    
    % get global indices of last executed action(s)
    compared_actions = alg.iteration(iteration).samples.globalInds;
    num_actions = length(compared_actions);
    
    % initialize compared indices output
    coactiveVisitedIndices = zeros(num_actions,2);
    coactiveGlobalIndices = zeros(num_actions,2);
    
    %Labels are such that second action always corresponds to coac point
    coactiveLabels = 2*ones(num_actions,1);
    
    for a = 1:num_actions
        curAction = alg.settings.points_to_sample(compared_actions(a),:);
        curObj = alg.settings.simulation.true_objectives(compared_actions(a));
        % first decide on magnitude of suggestion
        if curObj < alg.settings.simulation.synth_coac.largeTrigger
            curSize = 2;
            sightRanges = alg.settings.simulation.synth_coac.sightRanges;
        elseif curObj < alg.settings.simulation.synth_coac.smallTrigger
            curSize = 1;
            sightRanges = alg.settings.simulation.synth_coac.sightRanges/2;
        else
            curSize = 0;
        end
        
        if curSize ~= 0
            
            % compute distances
            distances = abs(alg.settings.points_to_sample - curAction).^2;
            
            % find which points are inside sight range
            inside_inds = all(sightRanges - distances > 0,2);
            inside_pts = alg.settings.points_to_sample(inside_inds,:);
            
            % obtain objectives of inside points
            inside_objs = alg.settings.simulation.true_objectives(inside_inds);
            
            % find maximum objective value of inside objective values
            [~,maxInd] = max(inside_objs);
            
            % if there are multiple maximum values - choose one randomly
            maxInd = randi(maxInd,1);
            coacObj = inside_objs(maxInd);
            
            % suggested action is action with maximum utility within sight
            suggested_action = inside_pts(maxInd,:);
            suggested_action = boundAction(alg,suggested_action);

            % find globalInd closest to suggested action
            coac_global = alg.getGlobalInd(suggested_action);

            % get visitedInd for suggested action
            coac_visited = alg.getVisitedInd(suggested_action);

            % only give coactive feedback if maxObj is larger than current
            if coacObj > curObj
                
                % Use noise to determine if coactive feedback is given
                if alg.settings.simulation.simulated_coac_noise == 0
                    pref_prob = 1;
                else
                    tempx = (alg.settings.simulation.true_objectives(coac_global) ...
                        - alg.settings.simulation.true_objectives(alg.iteration(iteration).samples.globalInds(a))) ...
                        /alg.settings.simulation.simulated_coac_noise;
                    pref_prob = sigmoid(tempx);
                end
                    
                giveCoacFlag = randsample([1,0],1,'true',[pref_prob,1-pref_prob]);
                
                if giveCoacFlag
                    coactiveVisitedIndices(a,1) = alg.iteration(iteration).samples.visitedInds(a);
                    coactiveVisitedIndices(a,2) = coac_visited;
                    coactiveGlobalIndices(a,1) = alg.iteration(iteration).samples.globalInds(a);
                    coactiveGlobalIndices(a,2) = coac_global;
                end
            end
            
            
        end
    end
    
    % remove all zero rows
    coactiveLabels(all(coactiveVisitedIndices == 0,2),:) = [];
    coactiveVisitedIndices(all(coactiveVisitedIndices == 0,2),:) = [];
    coactiveGlobalIndices(all(coactiveGlobalIndices == 0,2),:) = [];
end

coac_data.c_x_subset = coactiveVisitedIndices;
coac_data.c_x_full = coactiveGlobalIndices;
coac_data.c_y = coactiveLabels;

end


% make sure coactive point is within action bounds
function bounded_action = boundAction(obj,suggested_action)
    bounded_action = max(obj.settings.lower_bounds,suggested_action);
    bounded_action = min(obj.settings.upper_bounds,bounded_action);
end