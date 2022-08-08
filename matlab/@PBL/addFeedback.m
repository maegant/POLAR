function addFeedback(obj,feedback,iteration)
% Uses user/simulated feedback to update posterior

% preferences is either preferences or ranking suggestions are nx4 with the
% columns:
%     1) dims: dimensions associated with coactive feedback 2) sizes:
%     either 0,1, or 2 for no, small, or large suggestion 3) directions:
%     either -1 or 1 for negative or positive direction 4) compAction:
%     index of action being compared to

if nargin < 1
    error('input needed (but may be empty) with structure elements preference, coactive, and ordinal \n ');
elseif nargin < 3
    iteration = length(obj.iteration);
end

% start timer
tstart = tic;

% unpack feedback
if ~isempty(feedback)
    preferences = feedback.preference;
    suggestions = feedback.coactive;
    ordlabels = feedback.ordinal;
else
    preferences = [];
    suggestions = struct('c_x_full',[],'c_x_subset',[],'c_y',[]);
    ordlabels = [];
end

% ----------------------- Append Visited Actions --------------------------
% append sampled actions
if ~isempty(obj.iteration(iteration).samples)
    sampled_actions = obj.iteration(iteration).samples.actions;
    obj.appendVisitedInd(sampled_actions,0);
end

% append coactive actions
if ~isempty(suggestions)
    if ~isempty(suggestions.c_y)
        coactive_actions = obj.settings.points_to_sample(suggestions.c_x_full(:,2),:);
        %     coactive_actions = suggestions.c_action;
        newSampleVisitedInds = obj.appendVisitedInd(coactive_actions,1);
        suggestions.c_x_subset(:,2) = newSampleVisitedInds;
    end
end

%------ Record information about drawn actions (for manual inputs)  -------

if isempty(obj.iteration(iteration).feedback)
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
    
    % fixes error that happens when manually entered data has no preference
    noPrefInds = find(preferences == 0);
    if ~isempty(noPrefInds)
        obj.iteration(iteration).feedback.p_x_subset(noPrefInds,:) = zeros(1,2);
        obj.iteration(iteration).feedback.p_x_full(noPrefInds,:) = zeros(1,2);
    end
    
    % Convert new action indices to ordinal action indices
    if any(obj.settings.feedback.types == 3)
        obj.iteration(iteration).feedback.o_x_subset = reshape(obj.iteration(iteration).samples.visitedInds,[],1);
        obj.iteration(iteration).feedback.o_x_full = reshape(obj.iteration(iteration).samples.globalInds,[],1);
    end
end


% ----------------------- Collect/record feedback -------------------------

% initialize flag for if feedback was given
feedbackGiven = 0;

if ~isempty(obj.previous_data)
    feedbackGiven = 1;
end

if ~isempty(obj.iteration(iteration).feedback)
    % Preference Feedback
    if any(obj.settings.feedback.types == 1)
        
        % if there's a pairwise comparison: (not the case during the first
        % iteration for b = 1, n = 1)
        if ~isempty(preferences)
            feedbackGiven = 1;
            
            if obj.settings.useSubset
                compared_actions = obj.iteration(iteration).feedback.visitedInds;
            else
                compared_actions = obj.iteration(iteration).feedback.globalInds;
            end
            
            % convert ranking to preferences if necessary
            if isequal(sort(preferences), 1:length(compared_actions))
                [~, preferences] = rankingToPreferences(preferences);
            end
            
            % Add new data to list
            obj.iteration(iteration).feedback.p_y = reshape(preferences,[],1);
        else
            obj.iteration(iteration).feedback.p_y = [];
        end
    end
    
    % Coactive Feedback
    if any(obj.settings.feedback.types == 2)
        if ~isempty(suggestions.c_y)
            feedbackGiven = 1;
            
            % unpack coactive feedback
            obj.iteration(iteration).feedback.c_x_subset = suggestions.c_x_subset;
            obj.iteration(iteration).feedback.c_x_full = suggestions.c_x_full;
            obj.iteration(iteration).feedback.c_y = suggestions.c_y;
        else
            obj.iteration(iteration).feedback.c_x_subset = [];
            obj.iteration(iteration).feedback.c_x_full = [];
            obj.iteration(iteration).feedback.c_y = [];
        end
    end
    
    % Ordinal Feedback
    if any(obj.settings.feedback.types == 3)
        
        % remove 'no label' labels
        noLabelInds = find(ordlabels == 0);
        obj.iteration(iteration).feedback.o_x_subset(noLabelInds,:) = [];
        if ~isempty(obj.iteration(iteration).feedback.o_x_full)
            obj.iteration(iteration).feedback.o_x_full(noLabelInds,:) = [];
        end
        ordlabels(noLabelInds) = [];
        
        if ~isempty(ordlabels)
            feedbackGiven = 1;
            
            % Add new data to list
            obj.iteration(iteration).feedback.o_y = reshape(ordlabels,[],1);
        else
            obj.iteration(iteration).feedback.o_y = [];
        end
    end
else
    obj.iteration(iteration).feedback = struct('c_x_subset',[],'c_x_full',[],'c_y',[]);
end

% Compile all feedback
temp = [obj.iteration(:).feedback];
if isfield(temp,'p_x_subset')
    obj.feedback.preference.x_subset = cell2mat({temp(:).p_x_subset}');
    obj.feedback.preference.x_full = cell2mat({temp(:).p_x_full}');
    obj.feedback.preference.y = cell2mat({temp(:).p_y}');
    
    % remove 'no preferences'
    noPrefInds = find(obj.feedback.preference.y == 0);
    if ~isempty(obj.feedback.preference.x_subset)
        obj.feedback.preference.x_subset(noPrefInds,:) = [];
    end
    if ~isempty(obj.feedback.preference.x_full)
        obj.feedback.preference.x_full(noPrefInds,:) = [];
    end
    obj.feedback.preference.y(noPrefInds,:) = [];
end
if isfield(temp,'c_x_subset')
    obj.feedback.coactive.x_subset = cell2mat({temp(:).c_x_subset}');
    obj.feedback.coactive.x_full = cell2mat({temp(:).c_x_full}');
    obj.feedback.coactive.y = cell2mat({temp(:).c_y}');
end
if isfield(temp,'o_x_subset')
    obj.feedback.ordinal.x_subset = cell2mat({temp(:).o_x_subset}');
    obj.feedback.ordinal.x_full = cell2mat({temp(:).o_x_full}');
    obj.feedback.ordinal.y = cell2mat({temp(:).o_y}');
end

% ------------------ Update Posterior using feedback ----------------------


% If subset - update GP over unique visited actions
if obj.settings.useSubset
    
    %         newSampleVisitedInds = obj.getVisitedInd(actions);
    %         numsIncluded = 1:size(obj.unique_visited_actions,1);
    
    switch obj.settings.sampling.type
        case 1
            % for Thompson sampling with useSubset - just update
            % posterior over the visited points. In the next
            % iteration the subset over which to draw samples for
            % Thompson sampling will be updated in
            % obj.getNextAction
            points_to_sample = obj.unique_visited_actions;
            points_to_sample_globalInds = obj.unique_visited_action_globalInds;
            obj.updatePosterior('subset', ...
                points_to_sample, ...
                points_to_sample_globalInds, ...
                iteration);
        case 2
            % for Information Gain with useSubset - update
            % posterior over obj.settings.subsetSize random points
            % plus the visited actions. This posterior will be used
            % in the next iteration with Information Gain
            
            % set of nonvisited points
            nonVisited = reshape(1:obj.settings.num_actions,[],1);
            nonVisited(obj.unique_visited_action_globalInds) = [];
            
            % draw subsetSize samples from nonvisited set
            if length(nonVisited) < obj.settings.subsetSize
                randInds = nonVisited;
            else
                randInds = randsample(nonVisited,obj.settings.subsetSize);
            end
            randActions = obj.settings.points_to_sample(randInds,:);
            
            % append random actions to visited actions
            points_to_sample = [obj.unique_visited_actions; randActions];
            points_to_sample_globalInds = [obj.unique_visited_action_globalInds; randInds];
            obj.updatePosterior('subset', ...
                points_to_sample, ...
                points_to_sample_globalInds, ...
                iteration);
        case 3
            % for Random Sampling - update posterior over the visited
            % points.
            points_to_sample = obj.unique_visited_actions;
            points_to_sample_globalInds = obj.unique_visited_action_globalInds;
            obj.updatePosterior('subset', ...
                points_to_sample, ...
                points_to_sample_globalInds, ...
                iteration);
    end
    
    % If full dimensionality - update GP over all actions
else
    obj.updatePosterior('full', ...
        obj.settings.points_to_sample, ...
        reshape(1:obj.settings.num_actions,[],1), ...
        iteration);
end

% Update best action
obj.updateBestAction(iteration);

tstop = toc(tstart);
obj.comp_time.posterior(iteration) = tstop;
if obj.settings.printInfo
    fprintf('Iteration %i Feedback Added (took %2.2f seconds) \n',iteration,tstop);
end

if obj.settings.isSave
    % save algorithm object to save folder
    if ~isfolder(obj.settings.save_folder)
        mkdir(obj.settings.save_folder);
    end
    alg = obj;
    save(fullfile(obj.settings.save_folder,'alg'),'alg');
end

end