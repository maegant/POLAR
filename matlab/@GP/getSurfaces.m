function [X, Y, Z] = getSurfaces(obj,plotting_type)
% gp object to plot;
     
% normalize posterior mean between 0 and 1
if ~all(obj.mean == 0) && obj.isNormalize
    norm_mean = (obj.mean-min(obj.mean))/(max(obj.mean)-min(obj.mean));
elseif all(obj.mean == 0) && obj.isNormalize
    norm_mean = (obj.mean-min(obj.mean))/(max(obj.mean)-min(obj.mean));
else
    norm_mean = obj.mean;
end

% get dimensionality of problem
[~, state_dim] = size(obj.actions);

%% if only one dimension 
%   - return points and mean
if state_dim == 1
    X = obj.actions;
    Y = [];
    Z = norm_mean;
    
%% if more than one dimension 
%   - return average surfaces over combinations of two dimensions
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
        reduced_subset = obj.actions(:,dimInds);
        [unique_subset,all2unique,unique2all] = unique(reduced_subset,'rows');
        
        % remove the plotted dimensions from the dimensions to mean over
        mean_unique = zeros(size(unique_subset,1),1);
        mean_inds = 1:state_dim;
        mean_inds(dimInds) = [];
        
        % go through all unique points
        for j = 1:length(all2unique)
            
            % take the mean over all repeating entries
            mean_inds = (unique2all == j);
            mean_unique(j) = mean(norm_mean(mean_inds));
        end
        
        switch plotting_type
            case 'full'     
                X{c} = reshape(unique_subset(:,1),obj.grid_size(dimInds(2)),obj.grid_size(dimInds(1)));
                Y{c} = reshape(unique_subset(:,2),obj.grid_size(dimInds(2)),obj.grid_size(dimInds(1)));
                Z{c} = reshape(mean_unique,obj.grid_size(dimInds(2)),obj.grid_size(dimInds(1)));
            case 'subset'
                X{c} = unique_subset(:,1);
                Y{c} = unique_subset(:,2);
                Z{c} = mean_unique;
        end
    end
    
end
