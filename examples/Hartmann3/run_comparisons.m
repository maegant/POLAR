
toolbox_addpath

% Get settings from separate script
settings = setupLearning;

% instanteate learning algorithm object
alg = PBL(settings);

%% Compare feedback types
settings.save_folder = 'compare_feedback_types_IG';
settings.sampling.type = 2;
settings.subsetSize = 500;
compObj = Compare( settings,50,...
                  'iters',100,... 
                  'feedback_types',{1,[1,2],[1,2,3],[1,3],3});