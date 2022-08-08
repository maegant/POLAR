%% Setup Learning

% Load settings
settings = setupLearning;

%instanteate toolbox class object
alg = PBL(settings); 

%% Run Simulations (Regret Minimization)
alg.reset;
isPlotting = 0; isSave = 0;
alg.runSimulation(isPlotting,isSave); %run simulation

%% Example post-process for coarse final posterior
coarse_posterior = PostProcess(alg,[5,5,5]);
coarse_posterior.plotFinal('coarse_posterior');

%% Example post-process for fine final posterior
% NOTE! Computing the finer posterior takes several minutes
fine_posterior = PostProcess(alg,[20,20,20]);
fine_posterior.plotFinal('fine_posterior');

%% Plot true posterior
plotting.plotTrueObjective(alg,3);