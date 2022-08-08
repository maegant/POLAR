function actions = getRandAction(alg,num_actions)
% get non-unique random actions from action space

% get random action based on number of actions in each dimension
bins = alg.settings.bin_sizes;
actions = zeros(num_actions,length(bins));
for i = 1:length(bins)
    actions(:,i) = randsample(alg.settings.parameters(i).actions,num_actions,true);
end

end