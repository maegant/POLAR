%% Function: setupLearning
%
% Description: This script establishes the parameters and settings of the
%   learning problem.
%
% Author: Maegan Tucker, mtucker@caltech.edu
% ________________________________________

function [ settings ] = setupLearning()

% --------------------- General Settings ----------------------------------
settings.save_folder = 'saved_results';

% choose max number of iterations to run
settings.maxIter = 100;

% choose size of buffer
settings.b = 1;

% choose number of samples to query each iteration
settings.n = 1;

% choose if synthetic objective function is used to automatically dictate
% feedback
settings.useSyntheticObjective = 1;

% -------------------- Posterior Sampling Settings  -----------------------

% choose regret minimization (1) or active learning (2)
settings.sampling.type = 1;

% choose settings of regret minimization
switch settings.sampling.type
    case 1
        settings.useSubset = 1; %true or false
        settings.sampling.isCoordinateAligned = 0; %choose if random linear subspace is coordinate aligned
    case 2
        settings.useSubset = 1; %true or false
        settings.subsetSize = 500; %choose subset size
        
        % Region of Avoidance (ordinal categories to avoid)
        settings.roa.use_roa = 1; %true or false
        settings.roa.ord_label_to_avoid = 1; % ordinal categories to avoid
end

% ------------------------ Feedback Settings  -----------------------------

% choose types of feedback (list choices in vector)
% 1 - preferences
% 2 - coactive
% 3 - ordinal
settings.feedback.types = [1,2,3];
settings.feedback.num_ord_categories = 5;    
        
% -------------- Action Space Properties (need to be selected) ------------
for i = 1:6
    settings.parameters(i).name = sprintf('dim%i',i);
    settings.parameters(i).discretization = 0.2;
    settings.parameters(i).lower = 0;
    settings.parameters(i).upper = 1;
    settings.parameters(i).lengthscale = 0.1;
end

% --------------------- Learning Hyperparameters --------------------------
settings.gp_settings.signal_variance = 1;   % Gaussian process amplitude parameter
settings.gp_settings.pref_noise = 0.02;    % Variance of modeled preference noise (Gaussian noise)
settings.gp_settings.coac_noise = 0.04;    % Variance of modeled preference noise (Gaussian noise)
settings.gp_settings.ord_noise = 0.1;    % Variance of modeled preference noise (Gaussian noise)
settings.gp_settings.GP_noise_var = 1e-5;        % GP model noise--need at least a very small


end