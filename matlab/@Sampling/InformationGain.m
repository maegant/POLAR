function [newSamples, R] = InformationGain(obj,alg,iteration)

if nargin < 2
    iteration = length(alg.iteration);
end

% Load posterior model updated from feedback during last iteration
model = alg.post_model(max(iteration-1,1));
    
% Load number of samples to draw from settings
num_samples = alg.settings.n;
M = alg.settings.sampling.IG_samp;

% If posterior_model is empty - then use random actions as samples
if isempty(model.actions) %first action
    randInds = randi(alg.settings.num_actions,1,num_samples);
    newSamples = alg.settings.points_to_sample(randInds,:);
    R = [];
    
    % Else - Use Information Gain as follows
else
    % Dimensionality of posterior
    [num_features, ~] = size(model.actions);
    
    % Unpack the model posterior
    post_mean = model.mean;
    sigma = model.sigma;
    uncertainty = model.uncertainty;
    
    % sample reward function from posterior
      try R = mvnrnd(post_mean, sigma,M)';
      catch ME
          warning('matrix is not symmetric positive semi-definite')
      end
    
     % get index of buffered action to compare IG with
    if ~isempty(alg.iteration(iteration).buffer)
        if alg.settings.useSubset
            buffer_action_idx = alg.iteration(iteration).buffer.visitedInds;
        else
            buffer_action_idx = alg.iteration(iteration).buffer.globalInds;
        end
    else 
        buffer_action_idx = [];
    end
    
    %  to avoid certain regions of the action space or not
    if alg.settings.roa.use_roa
        ucb = post_mean + alg.settings.roa.lambda * uncertainty;
        select_idx = setdiff(find(ucb > alg.settings.roa.roa_thresh),buffer_action_idx); % ignore buffered actions
    else
        select_idx = setdiff(1:num_features,buffer_action_idx);% ignore buffered actions
    end
    
    % Get indices to go through and compare for IG
    if numel(select_idx) == 0
        select_idx = 1:num_features;
    end
   
    [newSampleInd,newSamples] = obj.eval_IG(alg, R, select_idx,buffer_action_idx,iteration);

end
    


