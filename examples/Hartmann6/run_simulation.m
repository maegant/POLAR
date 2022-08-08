%% Add POLAR
toolbox_addpath;

%% Setup Learning
% Load settings
settings = setupLearning;

%instanteate toolbox class object
alg = PBL(settings); 

%% Run Simulations (active learning)
alg.reset;
isPlotting = 0; isSave = 0;
alg.runSimulation(isPlotting,isSave); %run simulation

%% Plot Results
plotting.plotPosterior(alg,isSave,length(alg.iteration));
plotting.plotMetrics(alg);

%% Plot True Utility
plotting.plotTrueObjective(alg);

%% Run comparisons (regret minimization)
settings.save_folder = 'compare_feedback_types2';
compObj = Compare( settings,50,...
                  'iters',100,...
                  'feedback_types',{1,[1,2],[1,2,3],[1,3],3});
              
%% Continue comparisons
compObj.addRuns(48);
