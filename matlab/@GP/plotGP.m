function f = plotGP(gp, dim_type, combinations)
% Description: Plots the posterior mean
%
% Inputs: 1) gp: gp object from GP class
%         2) dim_type: either 2 or 3 to represent 2D or 3D view (optional)
%         3) combinations: list of combination of parameters to plot (optional)
% Output: 1) f: figure handle

if nargin < 2
    dim_type = 3;
else
    assert(dim_type == 2 || dim_type == 3,'second input (dim_type) must be 2 or 3 for 2D or 3D plot');
end

%% Setup figure:
f = figure(); clf;
t = tiledlayout('flow');
% title(t,sprintf('Iteration %i',iteration));

%% Normalize if isNormalize = 1
if ~all(gp.mean == 0) && gp.isNormalize
    norm_mean = (gp.mean-min(gp.mean))/(max(gp.mean)-min(gp.mean));
elseif all(gp.mean == 0) && gp.isNormalize
    norm_mean = (gp.mean-min(gp.mean))/(max(gp.mean)-min(gp.mean));
else
    norm_mean = gp.mean;
end

[~,state_dim] = size(gp.actions);

% get either all combinations of parameters, or provided combinations
if nargin < 3
    C = nchoosek(1:state_dim,2);
else
    C = combinations;
end

%% get plotting type based on grid_size
if isempty(gp.grid_size)
    plotting_type = 'subset';
else
    plotting_type = 'full';
end

% get surface to plot later
[X, Y, Z] = gp.getSurfaces(plotting_type);

%% Plot based on if posterior over all points or subset of points
if state_dim == 1
    
    ax = nexttile; hold(ax,'on');
    
    % Plot posterior
    switch plotting_type
        case 'full'
            plot(ax,X,Z,'k','LineWidth',2);
        case 'subset'
            scatter(ax,gp.actions,norm_mean,100,norm_mean,'filled');
    end
    
    %         xlabel(ax,obj.settings.parameters(1).name);
%     xlim(ax,[gp.settings.lower_bounds(1) gp.settings.upper_bounds(1)]);
    ylabel(ax,'Posterior Mean');
    if gp.isNormalize
        ylim(ax,[0,1]);
    end
    
else
        
    % For cases where not all combinations are plotted, index of
    % combination in list of surfaces is needed:
    if nargin < 3
        surfInds = 1:length(X);
    else
        allcombinations = nchoosek(1:state_dim,2);
        surfInds = zeros(size(C,1),1);
        for i = 1:length(surfInds)
            surfInds(i) = find(ismember(allcombinations,C(i,:),'rows'));
        end
        
    end
    
    % Plot posterior mean for each combination
    for c = 1:size(C,1)
        currentComb = surfInds(c);
        tempX = X{currentComb}; tempY = Y{currentComb}; tempZ = Z{currentComb};
        
        ax = nexttile; hold(ax,'on');
        
        switch plotting_type
            case 'full'
                surf(ax,tempX,tempY,tempZ,'FaceAlpha',0.5,'FaceColor','interp');
                
                % plot contour
                [~,h] = contourf(ax,tempX,tempY,tempZ);
                hh = get(h,'Children');
                for i=1:numel(hh)
                    zdata = ones(size( get(hh(i),'XData') ));
                    set(hh(i), 'ZData',-10*zdata)
                end
                
            case 'subset'
                scatter3(ax,X{currentComb},Y{currentComb},Z{currentComb},100,Z{currentComb},'filled');
        end
        view(ax,dim_type);
        grid(ax,'on');
        %             xlabel(ax,obj.settings.parameters(C(c,1)).name);
%         xlim(ax,[gp.settings.lower_bounds(C(c,1)) gp.settings.upper_bounds(C(c,1))]);
        %             ylabel(ax,obj.settings.parameters(C(c,2)).name);
%         ylim(ax,round([min(gp.settings.parameters(C(c,2)).actions), max(gp.settings.parameters(C(c,2)).actions)],1));
%         yticks(ax,round(linspace(min(gp.settings.parameters(C(c,2)).actions), max(gp.settings.parameters(C(c,2)).actions),3),1));
        if gp.isNormalize 
            zlim(ax,[0,1]);
        end
        if dim_type == 3
            zlabel(ax,'Posterior Mean');
        else
            cb = colorbar;
        end
        xlabel(ax,gp.action_names{C(c,1)}); 
        ylabel(ax,gp.action_names{C(c,2)}); 
    end
end

latexify
fontsize(10)
drawnow


