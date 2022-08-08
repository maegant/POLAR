function addPreviousData(obj, action_list, pref_data, pref_labels, ...
                         coac_data, coac_labels, ord_data, ord_labels)
% Constructs obj.previous_data

%%% 
% Inputs:
%   1) action_list: nxdim matrix where n is the number of previously
%           sampled actions plus coactive actions and dim 
%           is the dimensionality of the action space.
%   2) pref_data: mx2 matrix with comparison indices referencing the
%           action_list
%   3) pref_labels: mx1 column vector indicating 0 for no pref, 1 for
%           preferred first action, or 2 for preferred second action
%   4) coac_data: mx2 matrix with comparisons of indices corresponding to
%           the actions in action_list
%   5) coac_labels: mx1 column matrix indicating 0 for no pref, 1 for
%           preferred first action, or 2 for preferred second action
%   5) ord_data: px1 column of indices corresponding to actions in which
%           ordinal labels were given
%   6) ord_labels: px1 column of labels (0 for no label, 1:c indicating the
%           ordinal category up to c categories)
%%%

obj.previous_data.actions = action_list;
obj.previous_data.preference = struct('x_subset',[],'x_full',[],'y',[]);
obj.previous_data.coactive = struct('x_subset',[],'x_full',[],'y',[]);
obj.previous_data.ordinal = struct('x_subset',[],'x_full',[],'y',[]);

% add previous actions to unique_visited_actions and get indices
visitedInds = obj.getVisitedInd(action_list);
globalInds = obj.getGlobalInd(action_list);

% compile previous data structure:
obj.previous_data.preference.x_subset = reshape(visitedInds(pref_data),[],2);
obj.previous_data.preference.x_full = reshape(globalInds(pref_data),[],2);
obj.previous_data.preference.y = pref_labels;
obj.previous_data.coactive.x_subset = reshape(visitedInds(coac_data),[],2);
obj.previous_data.coactive.x_full = reshape(globalInds(coac_data),[],2);
obj.previous_data.coactive.y = coac_labels;
obj.previous_data.ordinal.x_subset = visitedInds(ord_data);
obj.previous_data.ordinal.x_full = globalInds(ord_data);
obj.previous_data.ordinal.y = ord_labels;

obj.unique_visited_actions = action_list;
obj.unique_visited_action_globalInds = globalInds;
obj.unique_visited_isCoac = zeros(length(globalInds),1);


