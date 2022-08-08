function plotSampledActions(obj,isSave,max_iteration)
% Plots the sampled actions

% default inputs
if nargin < 2
    isSave = 0;
end
if nargin < 3
    max_iteration = length(obj.iteration);
end

%% setup figure
f = figure(208); clf; % reserved for sampled actions
tiledlayout('flow');

%% plot
state_dim = size(obj.settings.points_to_sample,2);

% concatenate all iterations
all_iter_samples = [obj.iteration(1:max_iteration).samples];
all_iter_feedback = [obj.iteration(1:max_iteration).feedback];

% get sampled actions
sampled_actions = cat(1,all_iter_samples.actions);
sampled_posteriorInds = cat(1,all_iter_samples.globalInds);

% get coactive actions
all_coactive_inds = cat(1,all_iter_feedback.c_x_full);
all_coactive_inds = all_coactive_inds(:,2);
all_coactive_actions = obj.settings.points_to_sample(all_coactive_inds,:);

%------------------  plot sampled and coactive actions --------------------
if state_dim == 1
    
    ax = axs(1); hold(ax,'on');
    
    p1 = scatter(ax, sampled_actions, ...
            obj.post_model(max_iteration).mean(sampled_posteriorInds), ...
            100,'b','filled');
    p2 = scatter(ax, all_coactive_actions, ...
            obj.post_model(max_iteration).mean(all_coactive_inds), ...
            100,'g','filled');
    
else
    
    C = nchoosek(1:state_dim,2);
    for c = 1:size(C,1)
        nexttile; hold on;
        p1 = scatter3(sampled_actions(:,C(c,1)), ...
                sampled_actions(:,C(c,2)), ...
                obj.post_model(max_iteration).mean(sampled_posteriorInds), ...
                100,'b','filled');
        p2 = scatter3(all_coactive_actions(:,C(c,1)), ...
                all_coactive_actions(:,C(c,2)), ...
                obj.post_model(max_iteration).mean(all_coactive_inds), ...
                100,'g','filled');
            
        % x and y axis formatting
        xlabel(obj.settings.parameters(C(c,1)).name)
        ylabel(obj.settings.parameters(C(c,2)).name)
        xlim([obj.settings.lower_bounds(C(c,1)),obj.settings.upper_bounds(C(c,1))])
        ylim([obj.settings.lower_bounds(C(c,2)),obj.settings.upper_bounds(C(c,2))])
        
    end
    
end


%% formatting
legend([p1,p2],{'Sampled Actions','Coactive Actions'});
latexify;
fontsize(22,'legend',12);


% save figure
if isSave
    imageName = 'sampledActions.png';
    imageLocation = obj.settings.save_folder;
    
    % Check if dir exists
    if ~isdir(imageLocation)
        mkdir(imageLocation);
    end
    print(f, fullfile(imageLocation,imageName),'-dpng');
end

end
