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
