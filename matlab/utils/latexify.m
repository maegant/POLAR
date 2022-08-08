function latexify(figHandle) %#ok<*AGROW>
narginchk(0,1);

if(nargin<1)   
    allAxes = [];
    allColorbar = [];
    allTiledLayouts = [];
    figHandle = findall(groot, 'Type', 'figure');
    if(isempty(figHandle))
        warning("No valid figure found");
        return;
    end
    
    for i=1:length(figHandle)
        fh = figHandle(i);
        if(isvalid(fh))
            allAxes = [allAxes;findall(fh,'type','axes')];
            allColorbar = [allColorbar;findall(fh,'type','colorbar')];
            allTiledLayouts = [allTiledLayouts;findall(fh.Children,'type','tiled')];
        end
    end
    
    if(isempty(allAxes) && isempty(allColorbar))
        warning("No valid axes or colorbars found");
       return; 
    end
else
    assert(~isemtpy(figHandle),"Input is empty.")
    if(isgraphics(figHandle,'figure'))
        if(length(figHandle)==1)
            assert(isvalid(figHandle),"Input is not a valid figure handle.")
            allAxes = findall(figHandle,'type','axes');
            allColorbar = findall(figHandle,'type','colorbar');
        else
            allAxes = [];
            allColorbar = [];
            figHandle = figHandle(:);
            for i=1:length(figHandle)
                fh = figHandle(i);
                if(~isvalid(fh))
                    warning("Figure handle #%i is not valid and will be ignored.",i);
                    continue;
                end
                allAxes = [allAxes;findall(fh,'type','axes')];
                allColorbar = [allColorbar;findall(fh,'type','colorbar')];
            end
        end
    elseif(isgraphics(figHandle,'axes'))
        allAxes = figHandle(:);
    else
        error("Input must be a valid figure/axes handle (or array of figure/axes handles).")
    end
end

for i=1:length(allAxes)
    h = allAxes(i);
    if(isvalid(h))       
        h.Title.Interpreter = 'latex';
        h.XLabel.Interpreter = 'latex';
        h.YLabel.Interpreter = 'latex';
        h.ZLabel.Interpreter = 'latex';
        if(~isempty(h.Legend))
            h.Legend.Interpreter = 'latex';
        end
        h.TickLabelInterpreter = 'latex';
    else
        warning("Invalid axes handle, will be ignored.")
    end
end

for i=1:length(allColorbar)
    h = allColorbar(i);
    if(isvalid(h))       
        h.Title.Interpreter = 'latex';
        h.TickLabelInterpreter = 'latex';
    else
        warning("Invalid colorbar handle, will be ignored.")
    end
end

for i = 1:length(allTiledLayouts)
    h = allTiledLayouts(i);
    if isvalid(h)
        h.Title.Interpreter = 'latex';
    else
        warning("Invalid tiled layout handle, will be ignored.")
    end
end

end
