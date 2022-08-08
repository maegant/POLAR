function f = plotPosterior(obj, isSave, plotAll)
% Plots the posterior mean

% Option to normalize posterior or not:
isNormalize = obj.settings.gp_settings.isNormalize;

if nargin < 2
    isSave = 0;
end
if nargin < 3
    plotAll = 0;
end

plottype = 3; %2D or 3D plots

% Either plot all iterations or just a single iteration
if plotAll
    for i = 1:length(obj.post_model)
        f = plotIteration(obj,isSave,isNormalize,i,plottype);
    end
    if isSave
        makeGIF(fullfile(obj.settings.save_folder,'Posterior Mean Animation'))
    end
else
    iteration = length(obj.iteration);
    f = plotIteration(obj,isSave,isNormalize,iteration,plottype);
end

end

% Separate function to plot posterior mean for corresponding iteration
function f = plotIteration(obj,isSave,isNormalize,iteration,plottype)
f = figure(203); clf;

t = tiledlayout('flow');
% title(t,sprintf('Iteration %i',iteration));

% Load posterior model;
model = obj.post_model(iteration);

% Don't plot if posterior model has not been updated yet
if ~isempty(model.mean)
    points = model.actions;
    post_mean = model.mean;
    final_mean = obj.post_model(end).mean;
    if ~all(post_mean == 0) && isNormalize
        norm_mean = (post_mean-min(final_mean))/(max(final_mean)-min(final_mean));
    elseif all(post_mean == 0) && isNormalize
        norm_mean = (post_mean-min(final_mean))/(max(final_mean)-min(final_mean));
    end
    [~,state_dim] = size(points);
        
    % get surface to plot later
    [X, Y, Z] = plotting.getPosteriorSurfs(obj,iteration,isNormalize);
    
    % Plot based on if posterior over all points or subset of points
    if state_dim == 1
        
        ax = nexttile; hold(ax,'on');
        if ~isempty(obj.settings.true_objectives)
            plot(ax,obj.settings.points_to_sample,obj.settings.true_objectives,'k--','LineWidth',2);
        end
        
        % Plot posterior
        switch model.which
            case 'full'
                plot(ax,X,Z,'k','LineWidth',2);
%                 issampled = zeros(size(X,1),1);
%                 for i = 1:size(obj.unique_visited_actions,1)
%                     [~,ind] = min(abs(X - obj.unique_visited_actions(i,:)));
%                     issampled(ind) = 1;
%                 end
%                 issampled = logical(issampled);
%                 scatter(ax,X(issampled),Z(issampled),100,'ko','filled','MarkerFaceAlpha',0.5);
                allsamples = [obj.iteration(1:iteration).samples];
                allsamples_globalInds = [allsamples.globalInds];
                scatter(ax,X(allsamples_globalInds),Z(allsamples_globalInds),500,'ko','filled','MarkerFaceAlpha',0.5);
            case 'subset'
                scatter(ax,points,norm_mean,100,norm_mean,'filled');
        end
        
        
%         xlabel(ax,obj.settings.parameters(1).name);
        xlim(ax,[obj.settings.lower_bounds(1) obj.settings.upper_bounds(1)]);
        ylabel(ax,'Posterior Mean');
        if isNormalize
            ylim(ax,[0,1]);
        end
        
    else
        
%         if ~isempty(obj.settings.true_objectives)
%             [X_true, Y_true, Z_true] = plotting.getPosteriorSurfs(obj,iteration,isNormalize,true);
%             
%             %         plot(ax,obj.settings.points_to_sample,obj.settings.true_objectives,'k--','LineWidth',2);
%         end
        
        % Plot posterior mean for each combination
        C = nchoosek(1:state_dim,2);
        for c = 1:length(X)
            tempX = X{c}; tempY = Y{c}; tempZ = Z{c};
            
            ax = nexttile; hold(ax,'on');
            
%             if ~isempty(obj.settings.true_objectives)
%                 surf(ax,X_true{c},Y_true{c},Z_true{c},'FaceAlpha',0.5,'FaceColor',[0.5,0.5,0.5]);
%             end
            switch model.which
                case 'full'
                    if plottype == 3
                        surf(ax,tempX,tempY,tempZ,'FaceAlpha',0.5,'FaceColor','interp');
                    end
                    % plot contour
                    [~,h] = contourf(ax,tempX,tempY,tempZ);
                    hh = get(h,'Children');
                    for i=1:numel(hh)
                        zdata = ones(size( get(hh(i),'XData') ));
                        set(hh(i), 'ZData',-10*zdata)
                    end
                    % plot sampled actoins
                    temp = [obj.iteration(1:iteration).samples];
                    allsamples = cell2mat({temp(:).actions}');
                    issampled = zeros(0,1);
                    for i = 1:size(allsamples,1)
                        [~,indx] = min(abs(tempX(1,:) - allsamples(i,C(c,1))));
                        [~,indy] = min(abs(tempY(:,1) - allsamples(i,C(c,2))));
                        ind = sub2ind(size(tempX),indy,indx);
                        issampled = cat(1,issampled,ind);
                    end
                    scatter3(ax,tempX(issampled),tempY(issampled), 0.02+0*tempZ(issampled),200,'ko','filled','MarkerFaceAlpha',1);
                    
                case 'subset'
                    scatter3(ax,X{c},Y{c},Z{c},100,Z{c},'filled');
            end
            if plottype == 3
                view(ax,3);
            else
                view(ax,2);
                axis(ax,'square');
            end
            grid(ax,'on');
            axis(ax,'square')
            xlabel(ax,obj.settings.parameters(C(c,1)).name);
            xlim(ax,[obj.settings.lower_bounds(C(c,1)) obj.settings.upper_bounds(C(c,1))]);
            ylabel(ax,obj.settings.parameters(C(c,2)).name);
            ylim(ax,round([min(obj.settings.parameters(C(c,2)).actions), max(obj.settings.parameters(C(c,2)).actions)],1));
            yticks(ax,round(linspace(min(obj.settings.parameters(C(c,2)).actions), max(obj.settings.parameters(C(c,2)).actions),3),1));
            zlabel(ax,'Posterior Mean');
            if isNormalize
                zlim(ax,[0,1]);
            end
        end
    end
    
    latexify
    fontsize(20)
    drawnow
    
    if isSave
        if iteration < 10
            imageName = sprintf('post_mean_iter0%i',iteration);
        else
            imageName = sprintf('post_mean_iter%i',iteration);
        end
        imageLocation = fullfile(obj.settings.save_folder,'Posterior Mean Animation');
        
        % Check if dir exists
        if ~isfolder(imageLocation)
            mkdir(imageLocation);
        end
        print(f, fullfile(imageLocation,imageName),'-dpng');
    end
end
end

