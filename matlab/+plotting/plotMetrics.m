function plotMetrics(obj,isSave,iteration)
% Plots the utility value associated with the action that maximizes the
% posterior mean

if nargin < 2
    iteration = length(obj.iteration);
    isSave = 0;
elseif nargin < 3
    iteration = length(obj.iteration);
end

if isempty(obj.iteration(iteration).best)
    iteration = iteration-1;
end

% Setup axes
f = figure(204); % reserved for plot best objective
tiledlayout('flow');
for i = 1:4
%     ax(i) = nexttile;
    ax(i) = subplot(1,4,i);
end
   
% Plot instantaneous regret
plot(ax(1),[obj.metrics(:).optimal_error],'k')
title(ax(1),'Optimal Utility Error');
xlabel(ax(1),'Iteration Number');
ylabel(ax(1),'error');

% Plot instantaneous regret
plot(ax(2),[obj.metrics(:).inst_regret],'k')
title(ax(2),'Instantaneous Regret');
xlabel(ax(2),'Iteration Number');
ylabel(ax(2),'error');

% Plot Label Prediction Error
plot(ax(3),[obj.metrics(:).label_error],'k')
title(ax(3),'Label Prediction Error');
xlabel(ax(3),'Iteration Number');
ylabel(ax(3),'error');

% Plot Pref Prediction Error
plot(ax(4),[obj.metrics(:).pref_error],'k')
title(ax(4),'Preference Prediction Error');
xlabel(ax(4),'Iteration Number');
ylabel(ax(4),'error');

if isSave
    imageName = 'metrics.png';
    imageLocation = fullfile(obj.settings.save_folder,'Metrics');
    
     % Check if dir exists
    if ~isfolder(imageLocation)
        mkdir(imageLocation);
    end
    print(f, fullfile(imageLocation,imageName),'-dpng');
end


end
