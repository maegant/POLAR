function plotColor(ax,color)
% Function used for PreferredColor example

rectangle(ax,'Position',[1,2,1,2],'FaceColor',color,'EdgeColor','none')

% Remove x and y axes
xticks(ax,[]);
yticks(ax,[]);
end