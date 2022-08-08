function settings = setupLearning

settings.save_folder = 'saved_results';
settings.maxIter = 20;

settings.b = 1;
settings.n = 1;

settings.sampling.type = 2;
settings.useSubset = 0;

settings.feedback.types = [1,2,3];
settings.feedback.num_ord_categories = 5;

settings.roa.use_roa = 1;
settings.roa.ord_label_to_avoid = 1;
settings.roa.lambda = 0.1;

% -------------- Action Space Properties (need to be selected) ------------
settings.parameters(1).name = 'action';
settings.parameters(1).discretization = 0.05;
settings.parameters(1).lower = 0;
settings.parameters(1).upper = 4;
settings.parameters(1).lengthscale = 0.4;

% --------------------- Learning Hyperparameters --------------------------
settings.gp_settings.linkfunction = 'sigmoid';
settings.gp_settings.signal_variance = 1;   % Gaussian process amplitude parameter
settings.gp_settings.pref_noise = 0.02;    % How noisy are the user's preferences?
settings.gp_settings.coac_noise = 0.04;    % How noisy are the user's suggestions?
settings.gp_settings.ord_noise = 0.15;     % How noisy are the user's labels?
settings.gp_settings.GP_noise_var = 1e-5;        % GP model noise--need at least a very small

% --------------------- Simulation Settings ----------------------------------
settings.useSyntheticObjective = 1;
settings.simulation.simulated_pref_noise = 0; % percent likelihood of incorrect simulated pref
settings.simulation.simulated_coac_noise = 0; % percent likelihood of incorrect simulated suggestions
settings.simulation.simulated_ord_noise = 0; % percent likelihood of incorrect simulated ord labels
