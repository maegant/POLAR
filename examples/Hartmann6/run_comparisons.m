%% Add POLAR
toolbox_addpath;

%% Setup Learning
% Load settings
settings = setupLearning;

%instanteate toolbox class object
alg = PBL(settings); 

%% Run comparisons for feedback types (regret minimization)
settings.save_folder = 'compare_feedback_types_RM';
settings.sampling.type = 1;
compObj = Compare( settings,50,...
                  'iters',100,...
                  'feedback_types',{1,[1,2],[1,2,3],[1,3],3});