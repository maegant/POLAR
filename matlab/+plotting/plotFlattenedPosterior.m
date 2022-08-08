function plotFlattenedPosterior(obj, isSave, iteration)
% Plots the flattened posterior mean (good for 1D visualization)

% Options
isNormalize = obj.settings.gp_settings.isNormalize; % Option to normalize posterior or not:

if nargin < 2
    plotAll = 1;
    isSave = 1;
elseif nargin < 3
    plotAll = 1;
else
    plotAll = 0;
end

% Either plot all iterations or just a single iteration
if plotAll
    for i = 1:length(obj.post_model)
        plotIteration(obj,isSave,isNormalize,i)
    end
    if isSave
        makeGIF(fullfile(obj.settings.save_folder,'FlattenedPoints'))
    end
else
    plotIteration(obj,isSave,isNormalize,iteration)
end

end

%% -- Separate function to plot posterior mean for corresponding iteration
function plotIteration(obj,isSave,isNormalize,iteration)

f = figure(202); clf;
tiledlayout('flow');
ax = nexttile; hold on;

if obj.settings.sampling.type == 1
    plotSamples = 1;
else
    plotSamples = 0;
end

% Load posterior model;
model = obj.post_model(iteration);

% Don't plot if posterior model has not been updated yet
if ~isempty(model.mean)
    points = model.actions;
    post_mean = model.mean;
    if ~all(post_mean == 0) && isNormalize
        post_mean = (post_mean-min(post_mean))/(max(post_mean)-min(post_mean));
    end
    
    switch model.which
        case 'full'
            sampledInds = [];
            for i = 1:iteration
                sampledInds = cat(1,sampledInds,obj.iteration(i).samples.globalInds);
            end
            curind = obj.iteration(iteration).samples.globalInds;
            if ~isempty(obj.iteration(iteration).buffer)
                bufind = obj.iteration(iteration).buffer.globalInds;
            end
            bestInd = obj.iteration(iteration).best.globalInd;
        case 'subset'
            sampledInds = [];
            for i = 1:iteration
                sampledInds = cat(1,sampledInds,obj.iteration(i).samples.visitedInds);
            end
            curind = obj.iteration(iteration).samples.visitedInds;
            if ~isempty(obj.iteration(iteration).buffer)
                bufind = obj.iteration(iteration).buffer.visitedInds;
            end
            bestInd = obj.iteration(iteration).best.visitedInd;
        otherwise
            error('model type must be full or subset');
    end
    
    numpoints = reshape(1:size(points,1),[],1);
    
    % scale uncertainty based on posterior normalization
    if isNormalize
        std_norm = model.uncertainty/(max(model.mean)-min(model.mean));
    else
        std_norm = model.uncertainty;
    end
    
    fill([numpoints;flipud(numpoints)], ...
        [post_mean+std_norm; flipud(post_mean-std_norm)], ...
        'b','FaceAlpha',0.2,'EdgeColor','none');
    
    % Plot Posterior Mean
    leg1 = plot(ax,numpoints,post_mean,'k','LineWidth',2);
    legstr1 = 'Posterior Mean';
    
    % Plot History Sampled Actions
    leg2 = scatter(ax,sampledInds,post_mean(sampledInds),300,'ko','filled','MarkerFaceAlpha',0.1);
    legstr2 = 'Previously Sampled Point';
    
    % Plot iteration sampled reward functions
    if strcmp(model.which,'full') && obj.settings.sampling.type == 1 && plotSamples
        R = obj.iteration(iteration).samples.rewards;
        if ~isempty(R)
            R_norm = R;
            for i = 1:obj.settings.n
                if isNormalize
                    R_norm(:,i) = (R(:,i)-min(model.mean))/(max(model.mean)-min(model.mean));
                end
                
                % Plot samples according to sampled reward functions
                leg3 = scatter(ax,curind(i),R_norm(curind(i),i),50,'ko');
                legstr3 = 'Action Maximizing Posterior Sample';
            end
            leg4 = plot(ax,repmat(numpoints,1,obj.settings.n), R_norm,'r--');
            legstr4 = 'Posterior Sample';
        else
            leg3 = []; leg4 = [];
            legstr3 = []; legstr4 = [];
        end
    else
        leg3 = []; leg4 = [];
        legstr3 = []; legstr4 = [];
    end
        
    % Plot Current samples:
    leg5 = scatter(ax,curind,post_mean(curind,:),100,'bo','filled');
    legstr5 = 'Executed Actions';
    
    % Plot Current Buffer Actions
    if ~isempty(obj.iteration(iteration).buffer)
        if ~isempty(obj.iteration(iteration).buffer.actions)
        leg6 = scatter(ax,bufind,post_mean(bufind,:),100,'mo','filled');
        legstr6 = 'Actions in Buffer';
        else
            leg6 = []; legstr6 = []; 
        end
    else
        leg6 = []; legstr6 = []; 
    end
    
    % Plot Coactive Point
    if any(obj.settings.feedback.types == 2)
        if obj.settings.useSubset
            if ~isempty(obj.iteration(iteration).feedback.c_x_subset)
                scatter(ax,obj.iteration(iteration).feedback.c_x_subset(1),...
                    post_mean(obj.iteration(iteration).feedback.c_x_subset(1)),100,'r','filled');
                scatter(ax,obj.iteration(iteration).feedback.c_x_subset(2),...
                    post_mean(obj.iteration(iteration).feedback.c_x_subset(2)),100,'g','filled');
            end
        else
            if ~isempty(obj.iteration(iteration).feedback.c_x_full)
                scatter(ax,obj.iteration(iteration).feedback.c_x_full(1),...
                    post_mean(obj.iteration(iteration).feedback.c_x_full(1)),100,'r','filled');
                scatter(ax,obj.iteration(iteration).feedback.c_x_full(2),...
                    post_mean(obj.iteration(iteration).feedback.c_x_full(2)),100,'g','filled');
            end
        end
    end
    
    % Plot best point
    leg7 = scatter(ax,bestInd,post_mean(bestInd),300,'gp','LineWidth',2);
    legstr7 = 'Believed Best Action';
    
    % Plot true objective function if exists
    if ~isempty(obj.settings.simulation.true_objectives)
        objectives = ObjectiveFunction(obj.settings.simulation.objective_settings,points);
        if isNormalize
            norm_objs = (objectives - min(objectives))/(max(objectives) - min(objectives));
            leg8 = plot(ax,numpoints,norm_objs,'k--','LineWidth',2);
        else 
            leg8 = plot(ax,numpoints,objectives,'k--','LineWidth',2);
        end
        legstr8 = 'True Objective Function';
    else
        leg8 = []; legstr8 = [];
    end
    
    % formatting
    xlabel(ax,'Flattened Points');
%     xticks(numpoints);
%     xlim([1,length(numpoints)]);
    ylabel(ax,'Posterior Mean');
    if isNormalize 
        ylim(ax,[-2,3]);
    end
    title(ax,sprintf('Iteration %i',iteration));
    legend_strings = {legstr1,legstr2,legstr3,legstr4,legstr5,legstr6,legstr7,legstr8};
    legend_strings = legend_strings(find(~cellfun(@isempty,legend_strings)));
    if ~isempty(leg4)
        leg4 = leg4(1);
    end
    l = legend([leg1, leg2, leg3, leg4,leg5,leg6,leg7,leg8],legend_strings);
    l.Location = 'southeast';
%%% ------------------------ PLOT AND SAVE --------------------------------
    drawnow
    
    if isSave
        if iteration < 10
            imageName = sprintf('Flattened_iter0%i',iteration);
        else
            imageName = sprintf('Flattened_iter%i',iteration);
        end
        imageLocation = fullfile(obj.settings.save_folder,'FlattenedPoints');
        
        % Check if dir exists
        if ~isdir(imageLocation)
            mkdir(imageLocation);
        end
        print(f,fullfile(imageLocation,imageName),'-dpng');
    end
    
end
end

