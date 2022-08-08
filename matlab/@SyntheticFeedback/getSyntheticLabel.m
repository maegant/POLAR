function ord_label = getSyntheticLabel(feedback,alg, iteration)

noise = alg.settings.simulation.simulated_ord_noise;
ordinal_threshold = alg.settings.simulation.true_ord_threshold;
if nargin < 2
    iteration = length(alg.iteration);
end
 
if ~any(alg.settings.feedback.types == 3)
    ord_label = [];
else  
    queried_actions = alg.iteration(iteration).samples.globalInds;
    trueObj = alg.settings.simulation.true_objectives(queried_actions);
    ord_label = zeros(length(queried_actions),1);
    if noise
        for i = 1:length(queried_actions)
            z1 = (ordinal_threshold(2:end) - trueObj(i))/noise;
            z2 = (ordinal_threshold(1:end-1) - trueObj(i))/noise;
            switch alg.settings.linkfunction
                case 'sigmoid'
                    prob = sigmoid(z1) -sigmoid(z2);
                case 'gaussian'
                    prob = normcdf(z1) -normcdf(z2);
            end
%             norm_prob = prob./sum(prob);
            ord_label(i) = randsample(alg.settings.feedback.num_ord_categories,1,true,prob);
        end
    else
        for i = 1:length(queried_actions)
            lessThanCat = find(trueObj(i) <= ordinal_threshold);
            ord_label(i) = max(lessThanCat(1)-1,1);
        end
    end
    
end

end
