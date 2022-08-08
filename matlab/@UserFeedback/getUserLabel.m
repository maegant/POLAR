function ord_label = getUserLabel(feedback, alg, iteration)
% Query human for ordinal label

if nargin < 2
    iteration = length(alg.iteration);
end

%--------------------- query user for ordinal label -----------------------

if ~any(alg.settings.feedback.types == 3)
    ord_label = [];
else  
    num_cat = alg.settings.feedback.num_ord_categories;
    num_actions = length(alg.iteration(iteration).samples.visitedInds);
    ord_label = zeros(num_actions,1);
    for n = 1:num_actions
        ord_label(n) = input(sprintf('Label for Sampled Action %i (0:%i where 0 is no label): ',n,num_cat));
        while floor(ord_label(n)) ~= ord_label(n) || ~any(ord_label(n) == 0:num_cat)
            if floor(ord_label(n)) ~= ord_label(n)
                ord_label(n) = input('Error - Label must be an integer: ');
            end
            if ~any(ord_label(n) == 0:num_cat)
                ord_label(n) = input(sprintf('Error - Label must be between 0 and %i: ',num_cat));
            end
        end
    end
end

end
