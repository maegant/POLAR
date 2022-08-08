%% Script: run_experiment
%
% Description: demonstrate POLAR toolbox on a 1D function through
% simulations
%
% Author: Maegan Tucker, mtucker@caltech.edu
% Date: August 9, 2021
%
% ________________________________________

%% Setup learning
settings = setupLearning;
alg = PBL(settings);

%% Run experiment (with no plotting)
alg.runExperiment(1,0,'export_yamls')
scatter(1,1,1e10,'r','filled')

%% Run experiment (with plotting);
alg.reset;
continue_flag = 1;
while continue_flag
    
    % get new actions
    alg.getNewActions;
    
    % Plot New Sampled Colors
    f = figure(1); clf;
    for i = 1:alg.settings.n
        ax = subplot(1,alg.settings.n,i);
        plotColor(ax,alg.iteration(end).samples.actions(i,:));
        title(ax,sprintf('Action %i',i));
    end
    
    % Query the user for feedback
    feedback = UserFeedback(alg);
    
    % update posterior using feedback
    alg.addFeedback(feedback);
    
    % Ask to continue
    ui = input('Continue? (y/n):   ','s');
    while ~((strcmpi(ui,'y')) || (strcmpi(ui,'n')))
        ui = input('Incorrect input given. Please enter y or n:   ');
    end
    if strcmpi(ui,'n')
        continue_flag = 0;
    end
end

%% Plot predicted most and least preferred colors
f = figure(2); clf;
plotColor(gca,alg.iteration(end).best.action);
title('Most Preferred Color');
