function getNewActions(obj,iteration)
% Draws new actions to query using @Sampling class

if nargin < 2
    if isempty(obj.iteration(end).samples) %Special for first iteration
        iteration = length(obj.iteration);
    else
        iteration = length(obj.iteration) + 1;
    end
end

% initialize iteration with empty elements
obj.iteration(iteration) = struct('buffer',[],'samples',[],'best',[],'subset',[],'feedback',[]);

%----------------- Update posterior over prior information ----------------
if iteration == 1 && ~isempty(obj.previous_data)
    
    % update posterior over visited actions
    points_to_sample = obj.unique_visited_actions;
    points_to_sample_globalInds = obj.getGlobalInd(points_to_sample);
    obj.updatePosterior('subset',points_to_sample, points_to_sample_globalInds, iteration);
    
    % update best action
    obj.updateBestAction(iteration);
        
    % Draw new linear subspace
    linear_subspace = obj.getLinearSubspace;

    % add linear subspace to object
    obj.iteration(iteration).subset.actions = [obj.unique_visited_actions; linear_subspace];

    % Infer subset posterior over new subset
    points_to_sample = obj.iteration(iteration).subset.actions;
    points_to_sample_globalInds = obj.getGlobalInd(points_to_sample);
    obj.updatePosterior('subset',points_to_sample, points_to_sample_globalInds, iteration);
    
    % fill buffer with empty elements
    obj.iteration(iteration).buffer = struct('actions',[],'visitedInds',[],'globalInds',[]);
end

%-------------------------- Update buffer actions -------------------------
% if not first iteration
if iteration > 1
    required_past_iterations = ceil(obj.settings.b/obj.settings.n);
    listActions = []; listVisitedInds = []; listGlobalInds = [];
    for i = min(required_past_iterations,length(obj.iteration)-1):-1:1
       listActions = cat(1,listActions,obj.iteration(iteration-i).samples.actions);
       listVisitedInds = cat(1,listVisitedInds,obj.iteration(iteration-i).samples.visitedInds);
       listGlobalInds = cat(1,listGlobalInds,obj.iteration(iteration-i).samples.globalInds);
    end
    
    % take the last num_buffer actions in the history of the sampled
    % actions and store them as the buffer
    num_buffer = min(size(listActions,1),obj.settings.b);
    obj.iteration(iteration).buffer.actions = listActions(end-num_buffer+1:end,:);
    obj.iteration(iteration).buffer.visitedInds = listVisitedInds(end-num_buffer+1:end,:);
    if isempty(obj.settings.points_to_sample)
        obj.iteration(iteration).buffer.globalInds = [];
    else
        obj.iteration(iteration).buffer.globalInds = listGlobalInds(end-num_buffer+1:end,:);
    end
    
end

%----------------------------- Update Subset ------------------------------

% If using Thompson sampling - posterior needs to be updated over new
% linear subspace that intersects the best point as determined by the
% posterior updated over the visited actions in obj.addFeedback
if obj.settings.sampling.type == 1 && obj.settings.useSubset == 1
    if iteration > 1 && ~isempty(obj.iteration(max(iteration-1,1)).best)
        % Draw new linear subspace
        linear_subspace = obj.getLinearSubspace;
        
        % add linear subspace to object
        obj.iteration(iteration).subset.actions = [obj.unique_visited_actions; linear_subspace];
        
        % Infer subset posterior over new subset
        points_to_sample = obj.iteration(iteration).subset.actions;
        points_to_sample_globalInds = obj.getGlobalInd(points_to_sample);
        obj.updatePosterior('subset',points_to_sample, points_to_sample_globalInds, iteration);
    end
end

% If using Information Gain, the subspace considered is the actions in the
% posterior as updated during the last iteration

%--------------------- Draw new actions to sample -------------------------
tstart = tic;

% Draw new samples to query
samples = Sampling(obj,iteration);
obj.iteration(iteration).samples.actions = samples.actions;
obj.iteration(iteration).samples.globalInds = samples.global_inds;
obj.iteration(iteration).samples.visitedInds = samples.visited_inds;
obj.iteration(iteration).samples.rewards = samples.rewards;

tstop = toc(tstart);
obj.comp_time.acquisition(iteration) = tstop;

%---------------- Record information about drawn actions  -----------------

% Add compared action indices for preference feedback
if isempty(obj.iteration(iteration).buffer)
    compared_actions_global = obj.iteration(iteration).samples.globalInds;
    compared_actions_visited = obj.iteration(iteration).samples.visitedInds;
else
    compared_actions_global = [obj.iteration(iteration).buffer.globalInds; ...
        obj.iteration(iteration).samples.globalInds];
    compared_actions_visited = [obj.iteration(iteration).buffer.visitedInds; ...
        obj.iteration(iteration).samples.visitedInds];
end
obj.iteration(iteration).feedback.globalInds = compared_actions_global;
obj.iteration(iteration).feedback.visitedInds = compared_actions_visited;

% Convert compared_action indices to pairwise comparisons
if any(obj.settings.feedback.types == 1)
    if length(compared_actions_visited) > 1
        if length(compared_actions_visited) == 2
            comparisons_visited = reshape(compared_actions_visited,[],2);
            comparisons_global = reshape(compared_actions_global,[],2);
        elseif length(compared_actions_visited) > 2
            [comparisonInds, ~] = rankingToPreferences(1:length(compared_actions_global));
            comparisons_visited = compared_actions_visited(comparisonInds);
            comparisons_global = compared_actions_global(comparisonInds);
        end
        obj.iteration(iteration).feedback.p_x_subset = comparisons_visited;
        obj.iteration(iteration).feedback.p_x_full = comparisons_global;
    else
        obj.iteration(iteration).feedback.p_x_subset = [];
        obj.iteration(iteration).feedback.p_x_full = [];
    end
end

% Convert new action indices to ordinal action indices
if any(obj.settings.feedback.types == 3)
    obj.iteration(iteration).feedback.o_x_subset = reshape(obj.iteration(iteration).samples.visitedInds,[],1);
    obj.iteration(iteration).feedback.o_x_full = reshape(obj.iteration(iteration).samples.globalInds,[],1);
end


if obj.settings.printInfo
    fprintf('Iteration %i Actions Sampled (took %2.2f seconds) \n',iteration, tstop);
end

end