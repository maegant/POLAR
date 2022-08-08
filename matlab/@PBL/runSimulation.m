function runSimulation(obj,plottingFlag,isSave)
% Begin a new simulation using the settings loaded in obj.settings

% Default settings:
if nargin < 2
    plottingFlag = 0;
end
if nargin < 3
    isSave = 0;
end
obj.settings.isSave = isSave;

% make sure synthetic objective is turned on
if ~ obj.settings.useSyntheticObjective
    obj.settings.useSyntheticObjective = 1;
end

% set starting iteration with previous runs:
if all(structfun(@isempty,obj.iteration(end)))
    start_iter = 1;
else
    start_iter = length(obj.iteration) + 1;
end
iter = start_iter;

% Make sure all required settings are updated
obj.algSetup;

% Start Learning:
while iter <= (start_iter-1 + obj.settings.maxIter)
    
    % get new actions
    obj.getNewActions;
    
    % Get synthetic feedback
    if isempty(obj.settings.simulation.true_objectives)
        obj = PBL(obj.settings);
        error('Cannot find "ObjectiveFunction.m" within Example Folder or settings.useObjectiveFunction set to 0')
    else
        feedback = SyntheticFeedback(obj,iter);
    end
    
    % update posterior using feedback
    obj.addFeedback(feedback);
    
    % Evaluate Learning
    if isempty(obj.metrics)
        obj.metrics = EvaluatePBL(obj,iter);
    else
        obj.metrics(iter) = EvaluatePBL(obj,iter);
    end
    
    % uncomment the following depending on what you would like to plot
    if plottingFlag
        plotting.plotFlattenedPosterior(obj,0,iter);
        plotting.plotMetrics(obj);
        plotting.plotFrequency(obj);
    end
    
    % save final figures at end
    if isSave && iter == obj.settings.maxIter
        plotting.plotFlattenedPosterior(obj,isSave, iter);
        plotting.plotMetrics(obj,isSave,iter);
    end
    
    % To save on time, remove second to last prior cov and prior cov inv
    obj.removeLargeMatrices
    
    iter = iter + 1;
end



end