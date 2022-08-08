function plotTrueObjective(obj,axview)
% Plots the true objective function (obj.settings.true_objectives)

isNormalize = obj.settings.gp_settings.isNormalize;
isFine = 0;

figure(); % generates a new figure
t = tiledlayout('flow');

if nargin < 2
    axview = 2;
end

% get averaged surfaces for 3D or higher action spaces. Otherwise it
% returns the normal posterior
[X,Y,Z] = plotting.getPosteriorSurfs(obj,1,isNormalize,1,isFine);

if isempty(Y)
    ax = nexttile;
    plot(ax,X,Z,'k','LineWidth',2);
    xlabel(ax,'Action Value');
    ylabel(ax,'Utility Value');
    title(t,'True Unknown Utility Function');
else
    C = nchoosek(1:length(obj.settings.parameters),2);
    for c = 1:length(X)
        ax = nexttile;
        surf(ax, X{c},Y{c},Z{c},'EdgeAlpha',0.2);
        xlabel(ax,obj.settings.parameters(C(c,1)).name);
        ylabel(ax,obj.settings.parameters(C(c,2)).name);
        zlabel(ax,'Posterior Mean');
        
        % limites
        xlim([obj.settings.lower_bounds(C(c,1)) ...
              obj.settings.upper_bounds(C(c,1))])
        ylim([obj.settings.lower_bounds(C(c,2)) ...
              obj.settings.upper_bounds(C(c,2))])
          
        % set view
        view(ax,axview);
        grid(ax,'on');
        axis(ax,'square')
    end
    
    if length(X) == 1
        title(t,'True Unknown Utility Function');
    else
        title(t,'Averaged True Unknown Utility Function');
    end
end

latexify;
fontsize(22);

end