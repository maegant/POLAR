function linear_subspace = getLinearSubspace(obj,iteration)

disc = [obj.settings.parameters(:).discretization];
state_dim = length(disc);

if nargin < 2
    iteration = length(obj.iteration);
end

current_best = obj.iteration(max(iteration-1,1)).best.action;

%%% Coordinate Aligned:
if obj.settings.sampling.isCoordinateAligned
    
    % Choose random dimension
    direction = zeros(1,state_dim);
    rand_coordinate = randi([1,state_dim],1);
    direction(rand_coordinate) = 1;
    
    % get points along line in positive direction
    linear_subspace = current_best;
    n = 1;
    new_point = current_best + n.*disc(rand_coordinate).*direction;
    while isValidPoint(obj,new_point)
        % append new_point
        linear_subspace = cat(1,linear_subspace,new_point);
        
        % get next new_point
        n = n+1;
        new_point = current_best + n.*disc(rand_coordinate).*direction;
        
    end
    
    % get points along line in negative direction
    n = 1;
    new_point = current_best - n.*disc(rand_coordinate).*direction;
    while isValidPoint(obj,new_point)
        % append new_point
        linear_subspace = cat(1,new_point,linear_subspace);
        
        % get next new_point
        n = n+1;
        new_point = current_best - n.*disc(rand_coordinate).*direction;
        
    end
    
else %not coordinate aligned
    
    % Get random point in space
    randAction = current_best;
    while (randAction == current_best)
        randAction = Sampling.getRandAction(obj,1);
    end
    
    direction = (randAction - current_best)/norm(randAction - current_best);
    
    % get points along line in positive direction
    linear_subspace = current_best;
    n = 1;
    %     uniformdisc = 1/100;
    new_point = current_best + n.*disc.*direction;
    new_point_in_A = findNearestAction(obj,new_point);
    while isValidPoint(obj,new_point)
        % append new_point
        linear_subspace = cat(1,linear_subspace,new_point_in_A);
        
        % get next new_point
        n = n+1;
        new_point = current_best + n.*disc.*direction;
        new_point_in_A = findNearestAction(obj,new_point);
    end
    
    % get points along line in negative direction
    n = 1;
    new_point = current_best - n.*disc.*direction;
    new_point_in_A = findNearestAction(obj,new_point);
    while isValidPoint(obj,new_point)
        % append new_point
        linear_subspace = cat(1,new_point_in_A,linear_subspace);
        
        % get next new_point
        n = n+1;
        new_point = current_best - n.*disc.*direction;
        new_point_in_A = findNearestAction(obj,new_point);
    end
end

end

%% ----------------------- HELPER FUNCTIONS -------------------------------
function isValid = isValidPoint(obj,point)
if any(point < obj.settings.lower_bounds)
    isValid = false;
elseif any(point > obj.settings.upper_bounds)
    isValid = false;
else
    isValid = true;
end
end

function nearestPoint = findNearestAction(obj,point)

nearestPoint = point;

% round to nearest in each dimension
for i = 1:length(obj.settings.bin_sizes)
    [~,closestInd] = min(abs(point(i) - obj.settings.parameters(i).actions));
    nearestPoint(i) = obj.settings.parameters(i).actions(closestInd);
end

end
