%% Setup Learning

% Load settings
settings = setupLearning;

%instanteate toolbox class object
alg = PBL(settings); 

%% Run Simulations Preference Optimization 
alg.reset;
alg.settings.sampling.type = 1;
isPlotting = 0; isSave = 0;
alg.runSimulation(isPlotting,isSave); %run simulation

%% Run Validation for Preference Optimization 
num_validation_comparisons = 5;
validation = Validation(alg,num_validation_comparisons);

%% Run Simulations Preference Characterization 
alg.reset;
alg.settings.sampling.type = 2;
alg.settings.maxIter = 100;
alg.settings.subsetSize = 500;
isPlotting = 0; isSave = 0;
alg.runSimulation(isPlotting,isSave); %run simulation

%% Run Validation for Preference Characterization 
num_validation_trials = 10;
validation = Validation(alg,num_validation_trials);