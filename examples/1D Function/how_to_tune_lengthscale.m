%% Description:
%   Example showing the influence of lengthscales on the learning
%   performance

%% Setup:
toolbox_addpath
settings = setupLearning;
settings.sampling.type = 1; %regret minimization
%% Visualize three different lengthscales
l_choices = [0.05 0.4 3];

for i = 1:length(l_choices)
   settings.parameters.lengthscale = l_choices(i);
   alg = PBL(settings);
   f = figure(i);
   alg.testLengthscales(f);
   f.Children.Children.Title.String = sprintf('lengthscale = %2.1f',l_choices(i));
end

%% Run learning for three different lengthscales:
n_iters = 50;
n_runs = 50;

settings.save_folder = 'compare_lengthscales';
compObj = Compare( settings,n_runs,...
                  'iters',n_iters,...
                  'lengthscales',num2cell(l_choices));
