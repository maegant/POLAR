function obj = addToHistory(obj,iteration)

% if new iteration, append row to history
if iteration > size(obj.history_visitedindices,1)
    obj.history_visitedindices = cat(1,obj.history_visitedindices,zeros(1,obj.settings.n));
    obj.history_globalindices = cat(1,obj.history_globalindices,zeros(1,obj.settings.n));
    obj.history_actions = cat(1,obj.history_actions,cell(1,obj.settings.n));
    
% Else, this means an iteration is being rewritten - unlikely but in this
% case remove actions associated with this old iteration
else
%     iterActionInds = obj.history_visitedindices(iteration,:);
%     obj.unique_visited_actions(iterActionInds,:) = [];
end

% update unique visited actions
obj.unique_visited_actions(obj.iteration(iteration).samples.visitedInds,:) = obj.iteration(iteration).samples.actions;

% add sampled points to unique_visited_actions
for i = 1:obj.settings.n    
    obj.history_visitedindices(iteration,i) = obj.iteration(iteration).samples.visitedInds(i);
    obj.history_globalindices(iteration,i) = obj.iteration(iteration).samples.globalInds(i);
    obj.history_actions{iteration,i} = obj.iteration(iteration).samples.actions(i,:);
end

end