function f = plotObjectives(obj)
% Plots the true objective function (obj.settings.true_objectives)

isNormalize = obj.settings.gp_settings.isNormalize;
isFine = 0;

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
    
    % Plot Pref Opt and pref char separately
    
    for i = 1:3
        f(i) = figure(i); % generates a new figure
        t = tiledlayout('flow');
        
        C = nchoosek(1:length(obj.settings.parameters),2);
        for c = 1:length(X)
            ax = nexttile; hold(ax,'on');
            surf(ax, X{c},Y{c},Z{c},'FaceAlpha',0.4,'EdgeAlpha',0,'FaceColor','interp');
            
            % plot contour
            [~,h] = contourf(ax,X{c},Y{c},Z{c});
            hh = get(h,'Children');
            for j=1:numel(hh)
                zdata = ones(size( get(hh(j),'XData') ));
                set(hh(j), 'ZData',-10*zdata)
            end
            
            xlabel(ax,obj.settings.parameters(C(c,1)).name);
            ylabel(ax,obj.settings.parameters(C(c,2)).name);
            if length(obj.settings.parameters) > 2
                zlabel(ax,'Averaged Utility Value');
            else
                zlabel(ax,'Normalized True Reward');
            end
            
            % limits
            xlim([obj.settings.lower_bounds(C(c,1)) ...
                obj.settings.upper_bounds(C(c,1))])
            ylim([obj.settings.lower_bounds(C(c,2)) ...
                obj.settings.upper_bounds(C(c,2))])
            
        end
        
        graycolor = gray;
        parulacolor = parula;
        colorvals = linspace(0,1,256);
        divider1 = find(colorvals > 0.85,1,'first');
        newcolor1 = [graycolor(1:divider1,:);parulacolor(divider1+1:256,:)];
        
        % Color ROA as gray
        if obj.settings.roa.use_roa
            roa_divider = obj.settings.simulation.true_ord_threshold(obj.settings.roa.ord_label_to_avoid+1);
            divider2 = find(colorvals > roa_divider,1,'first');
            newcolor2 = [graycolor(1:divider2,:);parulacolor(divider2+1:256,:)];
        else
            newcolor2 = parulacolor;
        end
        
        % Plot Opt, Char, and True Landscape
        if i == 1
            colormap(newcolor1);
            view(ax,2);
            %             title(t,'Preference Optimization Objective','FontSize',20);
            %         contourf(ax, X{c},Y{c},Z{c},[0.9 0.9])%,'EdgeAlpha',0.2);
        elseif i == 2
            colormap(newcolor2);
            view(ax,2);
            %             title(t,'Preference Characterization Objective','FontSize',20);
        else
            colormap(parula);
            for j = 1:length(X)
                view(f(3).Children.Children(j),3);
                grid(f(3).Children.Children(j),'on');
                axis(f(3).Children.Children(j),'square')
            end
            %             title(t,'True Underlying Preference Landscape','FontSize',20);
        end
        
        %
    end
    
end

fontsize(20);
latexify;

end