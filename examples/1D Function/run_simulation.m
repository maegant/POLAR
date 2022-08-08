%% Script: run_simulation
%
% Description: demonstrate POLAR toolbox on a 1D function through
% simulations
%
% Author: Maegan Tucker, mtucker@caltech.edu
% Date: August 9, 2021
%
% ________________________________________

%% Add POLAR toolbox:
addpath(fullfile('..','..','..','POLAR')); % add main polar folder to path
toolbox_addpath;

%% Setup Learning

% load settings from setupLearning function
settings = setupLearning;

%instanteate toolbox class object
alg = PBL(settings); 

%% run simulations (active learning)
alg.settings.maxIter = 20; % number of iterations to run
alg.settings.sampling.type = 2;

isPlotting = 1; isSave = 1; %flag options
alg.runSimulation(isPlotting,isSave); %run simulation

%% run simulations (continue with regret minimization)
alg.settings.sampling.type = 1;

isPlotting = 1; isSave = 1; %flag options
alg.runSimulation(isPlotting,isSave); %run simulation