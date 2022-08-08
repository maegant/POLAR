function getFinePosterior(obj,alg)

% get grid size of original points in setup
current_gridsize = cellfun(@length,{alg.settings.parameters(:).actions});
    
% get points to include in final posterior
if obj.grid_size == cellfun(@length,{alg.settings.parameters(:).actions})
    points_to_include = alg.settings.points_to_sample;
    newGlobalIndMapping = [];
else
    
    if length(current_gridsize) ~= length(obj.grid_size)
        error('Second Input (obj.grid_size) must be 1xd row vector for d-dimensional action space');
    end
    
    % construct new action space
    for i = 1:length(current_gridsize)
        actions{i} = linspace(alg.settings.parameters(i).lower, ...
                              alg.settings.parameters(i).upper, ...
                              obj.grid_size(i));
    end
    points_to_include = combvec(actions{:})';
    
    % mapping from new finer action space to original action space
    newGlobalIndMapping = obj.getMapping(alg,points_to_include);
end
globalInds = reshape(1:size(points_to_include,1),[],1);

% Compile feedback
if ~isempty(alg.previous_data)
    pref_data = alg.previous_data.preference.x_full;
    coac_data = alg.previous_data.coactive.x_full;
    ord_data = alg.previous_data.ordinal.x_full;
    pref_labels = alg.previous_data.preference.y;
    coac_labels = alg.previous_data.coactive.y;
    ord_labels = alg.previous_data.ordinal.y;
else
   pref_data = []; pref_labels = [] ;
   coac_data = []; coac_labels = [] ;
   ord_data = []; ord_labels = [] ;
end
if any(alg.settings.feedback.types == 1)
    pref_data = cat(1,pref_data,alg.feedback.preference.x_full);
    pref_labels = cat(1,pref_labels,alg.feedback.preference.y);
end
if any(alg.settings.feedback.types == 2)
    coac_data = cat(1,coac_data,alg.feedback.coactive.x_full);
    coac_labels = cat(1,coac_labels,alg.feedback.coactive.y);
end
if any(alg.settings.feedback.types == 3)
    ord_data = cat(1,ord_data,alg.feedback.ordinal.x_full);
    ord_labels = cat(1,ord_labels,alg.feedback.ordinal.y);
end

% Convert global indices to new finer discretization action space
if ~isempty(newGlobalIndMapping)
   pref_data = newGlobalIndMapping(pref_data);
   coac_data = newGlobalIndMapping(coac_data);
   ord_data = newGlobalIndMapping(ord_data);
end

% Update posterior over larger action space
obj.gp = GP(alg.settings.gp_settings,...
    points_to_include, ...
    obj.grid_size,...
    pref_data, pref_labels,...
    coac_data, coac_labels,...
    ord_data, ord_labels);

% populate settings
obj.settings = alg.settings;

end