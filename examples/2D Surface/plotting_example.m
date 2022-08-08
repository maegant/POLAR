%% Script demonstrating the plotting capabilities of POLAR 

%% Run POLAR
settings = setupLearning;
alg = PBL(settings); 
alg.runSimulation; %run simulation

%% Plot  Visualization of Learning Objectives
plotting.plotObjectives(alg);

%% Plot Underlying Objective Function
plotting.plotTrueObjective(alg,3);

%% Plot Metrics of Learning Performance for Synthetic Results
plotting.plotMetrics(alg);

%% Plot Learned Underlying Landscape
plotting.plotPosterior(alg);

%% Plot posterior with coactive actions 
plotting.plotCoactive(alg);

%% Visualize actions sampled during learning procedure
plotting.plotSampledActions(alg);