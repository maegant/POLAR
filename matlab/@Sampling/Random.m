function [newSamples, rewards] = Random(obj,alg)

% Load number of samples to draw from settings
num_samples = alg.settings.n;
newSamples = obj.getRandAction(alg,num_samples);
rewards = [];

end