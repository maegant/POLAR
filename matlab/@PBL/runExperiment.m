function runExperiment(obj,plottingFlag,isSave,exportfile_path)
% Begin a new experiment using the settings loaded in obj.settings

if nargin < 2
    plottingFlag = 0;
end
if nargin < 3
    isSave = 1;
end
if nargin < 4
    exportFlag = 0;
else
    exportFlag = 1;
end

obj.settings.isSave = isSave;
obj.settings.useSyntheticObjective = 0;
obj.algSetup;

if all(structfun(@isempty,obj.iteration(end)))
    iter = 1;
else
    iter = length(obj.iteration) + 1;
end

while true
    
    % Draw samples from posterior to query next
    obj.getNewActions;
    
    % write sampled actions to yaml
    if exportFlag
        writeAction(obj.iteration(iter).samples.actions, iter, exportfile_path);
    end
    
    % Query the user for feedback
    feedback = UserFeedback(obj,iter);
    
    if feedback.preference == -1
        obj.iteration(end) = [];
        if length(obj.post_model) == iter
            obj.post_model(iter) = [];
        end
        obj.comp_time.acquisition(end) = [];
        break
    end
    
    % update posterior using feedback
    obj.addFeedback(feedback);
    
    % uncomment the following depending on what you would like to plot
    if plottingFlag
%         obj.plotFlattenedPosterior(isSave, iter);
%         obj.plotPosterior(isSave, iter);
%         obj.plotCoactive(isSave, iter);
        plotting.plotFrequency(obj);
    end
    
    % ask user to continue
%     continueFlag = input(sprintf('Continue with Iteration %i? (y or n): ',iter+1),'s');
%     while ~any([strcmpi(continueFlag,'y'), strcmpi(continueFlag,'n')])
%         continueFlag = input('Error - Input must be y or n: ','s');
%     end
%     if strcmpi(continueFlag,'n')
%         break;
%     else
        iter = iter + 1;
%     end

    % To save on time, remove second to last prior cov and prior cov inv
    obj.removeLargeMatrices
    
end

end