function pref_label = getSyntheticPreference(feedback,alg, iteration)
% automatically prefer action with maximal value

if nargin < 2
    iteration = length(alg.iteration);
end

if isempty(alg.iteration(iteration).feedback.p_x_full)
    pref_label = [];
else
    compared_actions = alg.iteration(iteration).feedback.globalInds;
    trueObjectives = alg.settings.simulation.true_objectives(compared_actions);
    
    % case when all objectives are equal
    if all(trueObjectives == trueObjectives(1))
        if length(compared_actions) == 2
            pref_label = 0;
        else
            num_prefs = nchoosek(length(compared_actions),2);
            pref_label = zeros(num_prefs,1);
        end
        
    % if there is at least one different objective value
    else
        % if finding the maximum
        [~,ranking] = sort(trueObjectives','descend');
        % corrupt preferences with noise
        prefnoise = alg.settings.simulation.simulated_pref_noise;
        if length(compared_actions) == 2
            if prefnoise == 0 
                pref_prob = 1;
            else
                % assume sigmoid link function for preference feedback
                tempx = (trueObjectives(ranking(1)) - trueObjectives(ranking(2)))/prefnoise;
                pref_prob = sigmoid(tempx);
            end
            pref = ranking(1);
            pref_label = randsample([pref,3-pref],1,'true',[pref_prob,1-pref_prob]);
        elseif length(compared_actions) > 2
            [~, pref_label] = rankingToPreferences(ranking, prefnoise, trueObjectives);
        end
    end
end

end