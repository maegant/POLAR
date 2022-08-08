%% Function: setupLearning
%
% Description: This script establishes the parameters and settings of the
%   learning problem.
%
% Author: Maegan Tucker, mtucker@caltech.edu
% ________________________________________

function [ settings ] = setupLearning()

% --------------------- General Settings ----------------------------------
% save folder path (either manually set or use automatic choice below)
settings.save_folder = 'saved_results';

% choose size of buffer
settings.b = 0;

% choose number of samples to query each iteration
settings.n = 2;

% -------------------- Posterior Sampling Settings  -----------------------

% choose regret minimization (1) or active learning (2)
settings.sampling.type = 1;
settings.useSubset = 1; %true or false

% ------------------------ Feedback Settings  -----------------------------

% choose types of feedback (list choices in vector)
% 1 - preferences
% 2 - coactive
% 3 - ordinal
settings.feedback.types = 1;
        
% -------------- Action Space Properties (need to be selected) ------------
settings.parameters(1).name = 'red';
settings.parameters(2).name = 'blue';
settings.parameters(3).name = 'green';
for i = 1:3
    settings.parameters(i).discretization = 0.2;
    settings.parameters(i).lower = 0;
    settings.parameters(i).upper = 1;
    settings.parameters(i).lengthscale = 0.5;
end

% --------------------- Learning Hyperparameters --------------------------
settings.gp_settings.signal_variance = 1;   % Gaussian process amplitude parameter
settings.gp_settings.pref_noise = 0.02;    % Variance of modeled preference noise (Gaussian noise)
settings.gp_settings.GP_noise_var = 1e-5;        % GP model noise--need at least a very small


end