function settings = setupLearning

% --------------------- General Settings ----------------------------------
clear settings
settings.save_folder = 'saved_results';
settings.b = 1;
settings.n = 1;
settings.maxIter = 30;

settings.sampling.type = 2;
settings.useSubset = 0;

settings.feedback.types = [1,2,3];
settings.feedback.num_ord_categories = 5;

settings.roa.use_roa = 1;
settings.roa.ord_label_to_avoid = 2;
settings.roa.lambda = 0.1;

% -------------- Action Space Properties (need to be selected) ------------
settings.parameters(1).name = '$a_1$';
settings.parameters(1).discretization = 0.5;
settings.parameters(1).lower = 11;
settings.parameters(1).upper = 21;
settings.parameters(1).lengthscale = 3.5;

settings.parameters(2).name = '$a_2$';
settings.parameters(2).discretization = 1;
settings.parameters(2).lower = 64;
settings.parameters(2).upper = 92;
settings.parameters(2).lengthscale = 6.5;

% --------------------- GP Hyperparameters --------------------------
settings.gp_settings.isNormalize = 1;
settings.gp_settings.pref_noise = 0.02;    % How noisy are the user's preferences?
settings.gp_settings.coac_noise = 0.04;    % How noisy are the user's suggestions?
settings.gp_settings.ord_noise = 0.15;     % How noisy are the user's labels?
settings.gp_settings.linkfunction = 'sigmoid';
settings.gp_settings.GP_noise_var = 1e-5;        % GP model noise--need at least a very small
settings.gp_settings.signal_variance = 1;   % Gaussian process amplitude parameter

% --------------------- Simulation Settings ----------------------------------
settings.useSyntheticObjective = 1;
settings.simulation.simulated_pref_noise = 0; % percent likelihood of incorrect simulated pref
settings.simulation.simulated_coac_noise = 0; % percent likelihood of incorrect simulated suggestions
settings.simulation.simulated_ord_noise = 0; % percent likelihood of incorrect simulated ord labels

% generate new objective function
gen_new_obj = 1; 
switch gen_new_obj
    case true
        [allobjectives,allactions] = generateObjective(settings);
        save('example_objective.mat','allobjectives','allactions')
    otherwise
        load('example_objective.mat','allobjectives','allactions');
end
settings.simulation.objective_settings.allobjectives = allobjectives;
settings.simulation.objective_settings.allactions = allactions;

end

