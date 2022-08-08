%% Script: run_simulation
%
% Description: demonstrate POLAR toolbox on a 2D function through
% simulations
%
% Author: Maegan Tucker, mtucker@caltech.edu
% Date: July 20, 2022
%
% ________________________________________

%% Add POLAR toolbox:
addpath(fullfile('..','..','..','POLAR')); % add main polar folder to path
toolbox_addpath;

%% Setup Learning
settings = setupLearning;

%instanteate toolbox class object
alg = PBL(settings); 

%% Plot Learning Objective Plots
f = plotting.plotObjectives(alg);
print(f(1), fullfile('objective_plots','pref_opt.png'),'-dpng');
print(f(2), fullfile('objective_plots','pref_char.png'),'-dpng');
print(f(3), fullfile('objective_plots','true_util.png'),'-dpng');

%% Run simulations (active learning)
alg.reset; %comment out to continue learning after 15 iterations
alg.settings.maxIter = 15; % number of iterations to run
alg.settings.sampling.type = 2;
alg.settings.save_folder = 'active_learning_simulation';
isPlotting = 0; isSave = 0; %flag options
alg.runSimulation(isPlotting,isSave); %run simulation

plotting.plotPosterior(alg,isSave);
plotting.plotMetrics(alg);
%% Run simulations (regret minimization)
alg.reset; %comment out to continue learning after 15 iterations
alg.settings.maxIter = 15; % number of iterations to run
alg.settings.sampling.type = 1;
alg.settings.save_folder = 'regret_min_simulation';
isPlotting = 0; isSave = 0; %flag options
alg.runSimulation(isPlotting,isSave); %run simulation

plotting.plotPosterior(alg,isSave);
plotting.plotMetrics(alg)

%% Run simulations (random)
alg.reset; %comment out to continue learning after 15 iterations
alg.settings.maxIter = 15; % number of iterations to run
alg.settings.sampling.type = 3;
alg.settings.save_folder = 'random_sampling';
isPlotting = 0; isSave = 0; %flag options
alg.runSimulation(isPlotting,isSave); %run simulation

plotting.plotPosterior(alg,isSave);
plotting.plotMetrics(alg)

%% Demonstrate IG for combinations of feedback types
settings.save_folder = 'compare_feedback_types_IG';
settings.sampling.type = 2;
compObj = Compare( settings,50,...
                  'iters',30,...
                  'feedback_types',{1,[1,2],[1,2,3],[1,3],3});
              
%% Demonstrate RM for combinations of feedback types
settings.save_folder = 'compare_feedback_types_RM';
settings.sampling.type = 1;
compObj = Compare( settings,50,...
                  'iters',30,...
                  'feedback_types',{1,[1,2],[1,2,3],[1,3],3});
