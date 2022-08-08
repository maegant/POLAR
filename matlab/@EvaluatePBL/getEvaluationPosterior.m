function [eval_gp_mean,eval_gp_inds] = getEvaluationPosterior(alg,evaluation_posterior_size)
% compute new posterior over more actions in order to evaluate the
%   metrics associated with the learned posterior

%% Get posterior over existing actions and new actions
num_new_points = min(evaluation_posterior_size,alg.settings.num_actions);
randInds = randsample(1:alg.settings.num_actions,num_new_points);
actions = [alg.unique_visited_actions; alg.settings.points_to_sample(randInds,:)];

% get feedback and get posterior
pref_data = alg.feedback.preference.x_subset;
pref_labels = alg.feedback.preference.y;
coac_data = alg.feedback.coactive.x_subset;
coac_labels = alg.feedback.coactive.y;
ord_data = alg.feedback.ordinal.x_subset;
ord_labels = alg.feedback.ordinal.y;

% Compute GP
gp = GP(alg.settings.gp_settings,...
    actions, ...
    [],...
    pref_data, pref_labels,...
    coac_data, coac_labels,...
    ord_data, ord_labels,...
    [], [], []);

%% Restrict GP to only the new actions
eval_gp_mean = gp.mean(end-num_new_points+1:end);
eval_gp_inds = randInds;

end

