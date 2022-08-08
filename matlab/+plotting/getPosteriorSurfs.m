function [X, Y, Z] = getPosteriorSurfs(obj, iteration, isNormalize, isTrue,isFinal)
% iteration: which iteration to plot
% isNormalize: flag to normalize posterior between 0 and 1
% isTrue: flag for calculating subdimension surfaces for true objective function
% isFine: flag for claculating surfaces over a finer set of actions

if nargin < 5
    isTrue = 0;
end
if nargin < 6
    model = obj.post_model(iteration);
    isFine = 0;
    isFinal = 0;
else
    model = obj.final_posterior;
    isFine = 1;
end

% Unpack object
if isFine
    grid_shape = repmat(100,1,length(obj.settings.parameters));
else
    grid_shape = [obj.settings.parameters(:).num_actions]; 
end
            
if isTrue
    if isFine
        for i = 1:length(obj.settings.parameters)
            actions{i} = linspace(obj.settings.parameters(i).lower,obj.settings.parameters(i).upper);
        end
        points = combvec(actions{:})';
        post_mean = ObjectiveFunction(obj.settings.simulation.objective_settings,points);
        final_mean = post_mean;
    else
        points = obj.settings.points_to_sample;
        post_mean = obj.settings.simulation.true_objectives;
        final_mean = post_mean;
    end
    which = 'full';
else
    points = model.actions;
    post_mean = model.mean;
    if isFinal
        final_mean = post_mean;
    else
        final_mean = obj.post_model(end).mean;
    end
    which = model.which;    
end

% normalize posterior mean between 0 and 1
if isNormalize
    post_mean = (post_mean-min(final_mean))/(max(final_mean)-min(final_mean));
end

% get dimensionality of problem
[~, state_dim] = size(points);

% if only one dimension - return points and mean
if state_dim == 1
    X = points;
    Y = [];
    Z = post_mean;
    
    % if more than one dimension - return average surfaces over combinations of
    % two dimensions
else
    
    % all combinations of two dimensions
    C = nchoosek(1:state_dim,2);
    
    % preallocate outputs
    X = cell(1,size(C,1));
    Y = cell(1,size(C,1));
    Z = cell(1,size(C,1));
    % get average surface for each combination
    for c = 1:size(C,1)
        
        % current dimensions to use:
        dimInds = C(c,:);
        
        % reduced subset to plot (2 dimensions)
        reduced_subset = points(:,dimInds);
        [unique_subset,all2unique,unique2all] = unique(reduced_subset,'rows');
        
        % remove the plotted dimensions from the dimensions to mean over
        mean_unique = zeros(size(unique_subset,1),1);
        mean_inds = 1:state_dim;
        mean_inds(dimInds) = [];
        
        % go through all unique points
        for j = 1:length(all2unique)
            
            % take the mean over all repeating entries
            mean_inds = (unique2all == j);
            mean_unique(j) = mean(post_mean(mean_inds));
        end
        
        switch which
            case 'full'        
                X{c} = reshape(unique_subset(:,1),grid_shape(dimInds(2)),grid_shape(dimInds(1)));
                Y{c} = reshape(unique_subset(:,2),grid_shape(dimInds(2)),grid_shape(dimInds(1)));
                Z{c} = reshape(mean_unique,grid_shape(dimInds(2)),grid_shape(dimInds(1)));
            case 'subset'
                X{c} = unique_subset(:,1);
                Y{c} = unique_subset(:,2);
                Z{c} = mean_unique;
        end
    end
    
end
