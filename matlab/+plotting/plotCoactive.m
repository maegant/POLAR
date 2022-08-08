function plotCoactive(obj, isSave, iteration)
% Plots the coactive actions for each iteration

% Options
isNormalize = obj.settings.gp_settings.isNormalize; % Option to normalize posterior or not:

% Default inputs
if nargin < 2
    isSave = 0;
end
if nargin < 3
    iteration = length(obj.iteration);
    plotAll = 1;
else
    plotAll = 0;
end

% Either plot all iterations or just a single iteration
if plotAll
    % first plot true objective
    axs = plotTrueObjective(obj,isNormalize,iteration);
    
    % go through each iteration
    for i = 1:length(obj.post_model)
        % add coactive points
        plotIteration(obj,isSave,isNormalize,i,axs)
    end
    if isSave
        makeGIF(fullfile(obj.settings.save_folder,'CoactiveFeedback'))
    end
else
    axs = plotTrueObjective(obj,isNormalize,iteration);
    plotIteration(obj,isSave,isNormalize,iteration,axs)
end


end

% Separate function to plot posterior mean for corresponding iteration
function axs = plotTrueObjective(obj,isNormalize,iteration)
figure(206); clf;


% Load posterior model;
model = obj.post_model(iteration);

% Setup axes first:
state_dim = length(obj.settings.parameters);
if state_dim == 1
    ax = nexttile; hold(ax,'on'); axs = ax;
else
    num_plots = nchoosek(state_dim,2);
    axs = cell(1,num_plots);
    for c = 1:num_plots
        ax = nexttile; hold(ax,'on'); axs{c} = ax;
    end
end

% Don't plot if posterior model has not been updated yet
if ~isempty(model.mean)
    points = model.actions;
    [~,state_dim] = size(points);
    
    % 1D Case:
    if state_dim == 1
        
        % Plot true objective function
        if ~isempty(obj.settings.true_objectives)
            plot(ax,obj.settings.points_to_sample,obj.settings.true_objectives,'k--','LineWidth',2);
        end
        
        % Labels
        xlabel(ax,obj.settings.parameters(1).name);
        xlim(ax,[obj.settings.lower_bounds(1) obj.settings.upper_bounds(1)]);
        xticks(ax,obj.settings.parameters(1).actions);
        ylabel(ax,'Posterior Mean');
        title(ax,sprintf('Iteration %i',iteration));
        
        % 2D or more Case:
    else
        
        % Get true objective function
        if ~isempty(obj.settings.simulation.true_objectives)
            [X_true, Y_true, Z_true] = plotting.getPosteriorSurfs(obj,iteration,isNormalize,true);
            
            % Plot coactive points on averaged combinations
            C = nchoosek(1:state_dim,2);
            for c = 1:length(X_true)
                
                ax = axs{c};
                
                % Plot true objective function
                surf(ax,X_true{c},Y_true{c},Z_true{c},'FaceAlpha',0.5,'FaceColor',[0.5,0.5,0.5]);
                
                % Labels
                view(ax,3); grid(ax,'on');
                xlabel(ax,obj.settings.parameters(C(c,1)).name);
                xlim(ax,[obj.settings.lower_bounds(C(c,1)) obj.settings.upper_bounds(C(c,1))]);
                ylabel(ax,obj.settings.parameters(C(c,2)).name);
                zlabel(ax,'True Posterior Mean');
            end
            
        end
    end
    
    %amberTools.graphics.latexify
    
    drawnow
end

end

function plotIteration(obj,isSave,isNormalize,iteration,axs)
f = figure(206);

% Load posterior model;
model = obj.post_model(iteration);
norm_mean = model.mean;

% Don't plot if posterior model has not been updated yet
if ~isempty(model.mean)
    points = model.actions;
    
    [~,state_dim] = size(points);
    
    % 1D Case:
    if state_dim == 1
        
        ax = axs; hold(ax,'on');
        
        % Plot true objective function
        if ~isempty(obj.settings.true_objectives)
            true_obj = obj.settings.true_objectives;
            
            % Plot coactive points
            if ~isempty(obj.iteration(iteration).feedback.c_x_full)
                scatter(ax,obj.settings.points_to_sample(obj.iteration(iteration).feedback.c_x_full(:,1)),...
                    true_obj(obj.iteration(iteration).feedback.c_x_full(:,1)),100,'r','filled','MarkerFaceAlpha',0.2);
                scatter(ax,obj.settings.points_to_sample(obj.iteration(iteration).feedback.c_x_full(:,2)),...
                    true_obj(obj.iteration(iteration).feedback.c_x_full(:,2)),100,'g','filled','MarkerFaceAlpha',0.2);
            end
            
            ylabel(ax,'True Objective Value');
            
        else
            
            % Plot coactive points
            switch model.which
                case 'full'
                    if ~isempty(obj.iteration(iteration).feedback.c_x_full)
                        scatter(ax,obj.settings.points_to_sample(obj.iteration(iteration).feedback.c_x_full(:,1)),...
                            norm_mean(obj.iteration(iteration).feedback.c_x_full(:,1)),100,'r','filled','MarkerFaceAlpha',0.2);
                        scatter(ax,obj.settings.points_to_sample(obj.iteration(iteration).feedback.c_x_full(:,2)),...
                            norm_mean(obj.iteration(iteration).feedback.c_x_full(:,2)),100,'g','filled','MarkerFaceAlpha',0.2);
                    end
                case 'subset'
                    if ~isempty(obj.iteration(iteration).feedback.c_x_subset)
                        scatter(ax,obj.settings.points_to_sample(obj.iteration(iteration).feedback.c_x_full(:,1)),...
                            norm_mean(obj.iteration(iteration).feedback.c_x_subset(:,1)),100,'r','filled','MarkerFaceAlpha',0.2);
                        scatter(ax,obj.settings.points_to_sample(obj.iteration(iteration).feedback.c_x_full(:,2)),...
                            norm_mean(obj.iteration(iteration).feedback.c_x_subset(:,2)),100,'g','filled','MarkerFaceAlpha',0.2);
                    end
            end
            
            ylabel(ax,'Posterior Mean');
        end
        
        % 1D Labels
        xlabel(ax,obj.settings.parameters(1).name);
        xlim(ax,[obj.settings.lower_bounds(1) obj.settings.upper_bounds(1)]);
        xticks(ax,obj.settings.parameters(1).actions);
        title(ax,sprintf('Iteration %i',iteration));
        
    % 2D or more Case:
    else
        
        % Get true objective function
        if ~isempty(obj.settings.simulation.true_objectives)
            [X_true, Y_true, Z_true] = plotting.getPosteriorSurfs(obj,iteration,isNormalize,true);
            
            % Plot coactive points on averaged combinations
            C = nchoosek(1:state_dim,2);
            for c = 1:length(X_true)
                
                ax = axs{c}; hold(ax,'on');
                
                % Plot true objective function
                %                 surf(ax,X_true{c},Y_true{c},Z_true{c},'FaceAlpha',0.5,'FaceColor',[0.5,0.5,0.5]);
                
                %%% --- Plot coactive points
                if ~isempty(obj.iteration(iteration).feedback.c_x_full)
                    
                    % plot sampled point in which feedback was given
                    Z_true_temp = Z_true{c};
                    x_vals = obj.settings.points_to_sample(obj.iteration(iteration).feedback.c_x_full(:,1),C(c,1));
                    y_vals = obj.settings.points_to_sample(obj.iteration(iteration).feedback.c_x_full(:,1),C(c,2));
                    z_vals = zeros(size(x_vals));
                    for i = 1:length(x_vals)
                        [~,yInd] = find(X_true{c} == x_vals(i),1);
                        [xInd,~] = find(Y_true{c} == y_vals(i),1);
                        z_vals(i) = Z_true_temp(xInd,yInd);
                    end
                    scatter3(ax, x_vals, y_vals, z_vals,100,'r','filled');
                    
                    % plot coactive point
                    x_vals = obj.settings.points_to_sample(obj.iteration(iteration).feedback.c_x_full(:,2),C(c,1));
                    y_vals = obj.settings.points_to_sample(obj.iteration(iteration).feedback.c_x_full(:,2),C(c,2));
                    z_vals = zeros(size(x_vals));
                    for i = 1:length(x_vals)
                        [~,yInd] = find(X_true{c} == x_vals(i),1);
                        [xInd,~] = find(Y_true{c} == y_vals(i),1);
                        z_vals(i) = Z_true_temp(xInd,yInd);
                    end
                    scatter3(ax, x_vals, y_vals, z_vals, 100,'g','filled');
                end
                
                % Labels
                view(ax,3); grid(ax,'on');
                xlabel(ax,obj.settings.parameters(C(c,1)).name);
                xlim(ax,[obj.settings.lower_bounds(C(c,1)) obj.settings.upper_bounds(C(c,1))]);
                ylabel(ax,obj.settings.parameters(C(c,2)).name);
                zlabel(ax,'Posterior Mean');
            end
            
        else
            
            [X_post, Y_post, Z_post] = getPosteriorSurfs(obj,iteration,isNormalize);
            
            % Plot coactive points on averaged combinations
            C = nchoosek(1:state_dim,2);
            
            for c = 1:length(X_post)
                
                ax = axs{c}; hold(ax,'on');
                
                %%% --- Plot coactive points
                if ~isempty(obj.iteration(iteration).feedback.c_x_full)
                    
                    switch model.which
                        case 'full'
                            
                            % plot sampled point in which feedback was given
                            Z_true_temp = Z_post{c};
                            x_vals = obj.settings.points_to_sample(obj.iteration(iteration).feedback.c_x_full(:,1),C(c,1));
                            y_vals = obj.settings.points_to_sample(obj.iteration(iteration).feedback.c_x_full(:,1),C(c,2));
                            z_vals = zeros(size(x_vals));
                            for i = 1:length(x_vals)
                                [~,yInd] = find(X_post{c} == x_vals(i),1);
                                [xInd,~] = find(Y_post{c} == y_vals(i),1);
                                z_vals(i) = Z_true_temp(xInd,yInd);
                            end
                            scatter3(ax, x_vals, y_vals, z_vals,100,'r','filled');
                            
                            % plot coactive point
                            x_vals = obj.settings.points_to_sample(obj.iteration(iteration).feedback.c_x_full(:,2),C(c,1));
                            y_vals = obj.settings.points_to_sample(obj.iteration(iteration).feedback.c_x_full(:,2),C(c,2));
                            z_vals = zeros(size(x_vals));
                            for i = 1:length(x_vals)
                                [~,yInd] = find(X_true{c} == x_vals(i),1);
                                [xInd,~] = find(Y_true{c} == y_vals(i),1);
                                z_vals(i) = Z_true_temp(xInd,yInd);
                            end
                            scatter3(ax, x_vals, y_vals, z_vals, 100,'g','filled');
                            
                        case 'subset'
                            if ~isempty(obj.iteration(iteration).feedback.c_x_subset)
                                scatter3(ax,obj.settings.points_to_sample(obj.iteration(iteration).feedback.c_x_full(:,1),C(c,1)),...
                                    obj.settings.points_to_sample(obj.iteration(iteration).feedback.c_x_full(:,1),C(c,2)),...
                                    norm_mean(obj.iteration(iteration).feedback.c_x_subset(:,1)),100,'r','filled','MarkerFaceAlpha',0.2);
                                scatter3(ax,obj.settings.points_to_sample(obj.iteration(iteration).feedback.c_x_full(:,2),C(c,1)),...
                                    obj.settings.points_to_sample(obj.iteration(iteration).feedback.c_x_full(:,2),C(c,2)),...
                                    norm_mean(obj.iteration(iteration).feedback.c_x_subset(:,2)),100,'g','filled','MarkerFaceAlpha',0.2);
                            end
                    end
                end
                
                % Labels
                view(ax,3); grid(ax,'on');
                xlabel(ax,obj.settings.parameters(C(c,1)).name);
                xlim(ax,[obj.settings.lower_bounds(C(c,1)) obj.settings.upper_bounds(C(c,1))]);
                ylabel(ax,obj.settings.parameters(C(c,2)).name);
                ylim(ax,[obj.settings.lower_bounds(C(c,2)) obj.settings.upper_bounds(C(c,2))]);
                zlabel(ax,'Posterior Mean');
                
            end
        end
        
        %amberTools.graphics.latexify
        
        drawnow
        
        if isSave
            if iteration < 10
                imageName = sprintf('coactive_iter0%i',iteration);
            else
                imageName = sprintf('coactive_iter%i',iteration);
            end
            imageLocation = fullfile(obj.settings.save_folder,'Coactive Animation');
            
            % Check if dir exists
            if ~isdir(imageLocation)
                mkdir(imageLocation);
            end
            print(f, fullfile(imageLocation,imageName),'-dpng');
        end
    end
end
end
