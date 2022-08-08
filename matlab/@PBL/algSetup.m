function algSetup(obj)
% Constructs obj.settings

settings = obj.settings;

% --------------------- General Settings ----------------------------------

% Assign folder to save results in
if ~isfield(settings,'save_folder')
    t = datetime;
    t.Format = 'MMM_dd_yy_HH_mm_ss';
    timestamp = sprintf('%s',t);
    settings.save_folder = ['saved_results_',timestamp];
end

% default to not saving automatically
if ~isfield(obj.settings,'isSave')
    settings.isSave = 0;
end
    
% Create save folder if it doesn't already exist
if ~isfolder(settings.save_folder)
    mkdir(settings.save_folder);
end

% max number of iterations to run
if ~isfield(settings,'maxIter')
    settings.maxIter = 30;
end

% default is to normalize objective function to between 0 and 1
if ~isfield(settings.gp_settings,'isNormalize')
    settings.gp_settings.isNormalize = 1;
end

% flag to print sampling and feedback information
if ~isfield(settings,'printInfo')
    settings.printInfo = 1;
end

% ----------------------- Configure Action Space  -------------------------

% Actions in each dimension
for i = 1:length(settings.parameters)
    settings.parameters(i).actions = settings.parameters(i).lower:settings.parameters(i).discretization:settings.parameters(i).upper;
    settings.parameters(i).num_actions = length(settings.parameters(i).actions);
end

% Upper and lower bounds of action space
settings.lower_bounds = [settings.parameters(:).lower];
settings.upper_bounds = [settings.parameters(:).upper];

% Total number of actions in action space
settings.bin_sizes = [settings.parameters(:).num_actions];
settings.num_actions = prod(settings.bin_sizes);

% Compute action space as combinations of all dimensions
if ~isfield(settings,'useSyntheticObjective')
    tempUseSynthetic = 0;
else
    tempUseSynthetic = settings.useSyntheticObjective;
end
if ~isfield(settings,'defineEntireActionSpace')
    settings.defineEntireActionSpace = 1;
end
if settings.defineEntireActionSpace
    actions = {settings.parameters(:).actions};
    points_to_sample = combvec(actions{:});
    settings.points_to_sample = points_to_sample';
else
    settings.points_to_sample = [];
end

% --------------------- Learning Hyperparameters --------------------------

% covariance scale
if ~isfield(settings.gp_settings,'cov_scale')
    settings.gp_settings.cov_scale = 1;
end

% Posterior modeling defaults
if ~isfield(settings.gp_settings,'linkfunction')
    settings.gp_settings.linkfunction = 'sigmoid';
end
if ~isfield(settings.gp_settings,'coac_noise')
    settings.gp_settings.coac_noise = settings.gp_settings.pref_noise;
end

% -------------------- Posterior Sampling Settings  -----------------------

% Aquisition Settings
if settings.sampling.type == 1
    if ~isfield(settings,'useSubset')
        settings.useSubset = 0; % Corresponds to CoSpar. Else is LineCoSpar
    end
    if settings.useSubset == 1
        if ~isfield(settings.sampling,'isCoordinateAligned')
            settings.sampling.isCoordinateAligned = 0;
        end
    end
elseif settings.sampling.type == 2
    % Default number of samples to draw to approximate uncertainty
    if ~isfield(settings.sampling,'IG_samp')
        settings.sampling.IG_samp = 1000;
    end
    
    if ~isfield(settings,'useSubset')
        settings.useSubset = 0; % Corresponds to full ROIAL
    else
        if ~isfield(settings,'subsetSize')
            settings.subsetSize =  floor(0.2* settings.num_actions); %20 of num_actions
        end
    end
end

% ------------------------ Feedback Settings  -----------------------------

if ~isfield(settings,'simulation')
    settings.simulation = [];
end

% Synthetic feedback noise:
if ~isfield(settings.simulation,'simulated_pref_noise')
    settings.simulation.simulated_pref_noise = 0; % Default is no noise
end
if ~isfield(settings.simulation,'simulated_coac_noise')
    settings.simulation.simulated_coac_noise = 0; % Default is no noise
end
if ~isfield(settings.simulation,'simulated_ord_noise')
    settings.simulation.simulated_ord_noise = 0; % Default is no noise
end

% Posterior Feedback Noise:
if ~isfield(settings.gp_settings,'pref_noise')
    settings.gp_settings.pref_noise
end
if ~isfield(settings.gp_settings,'coac_noise')
    settings.gp_settings.coac_noise = [];
end
if ~isfield(settings.gp_settings,'ord_noise')
    settings.gp_settings.ord_noise = [];
end

% Default Coactive Feedback Settings
if any(settings.feedback.types == 2)
    if ~isfield(settings.feedback,'coac_smallThresh')
        settings.feedback.coac_smallThresh = 0.3;
    end
    if ~isfield(settings.feedback,'coac_largeThresh')
        settings.feedback.coac_largeThresh = 0.6;
    end
end

% Default Ordinal Feedback Settings
if ~isfield(settings.feedback,'num_ord_categories')
    settings.feedback.num_ord_categories = 1;
end

% Setup thresholds even if ordinal labels are not used (for predictLabels)
if ~isfield(settings.simulation,'true_ord_threshold')
    % default to uniformly spaced thresholds for functions normalized
    % between 0 and 1
    settings.simulation.true_ord_threshold = linspace(0,1,settings.feedback.num_ord_categories+1);
end
if ~isfield(settings.gp_settings,'ordinal_thresholds') || isempty(obj.settings.gp_settings.ordinal_thresholds)
    % default to uniformly spaced thresholds for functions normalized
    % between -1 and 1 (centered around 0)
    settings.gp_settings.ordinal_thresholds = linspace(-1,1,settings.feedback.num_ord_categories+1);
    settings.gp_settings.ordinal_thresholds(1) = -inf;
    settings.gp_settings.ordinal_thresholds(end) = inf;
end


% Region of avoidance (ROA) settings
if ~isfield(settings,'roa')
    settings.roa = [];
end
if ~isfield(settings.roa,'use_roa')
    settings.roa.use_roa = 0;
else
    if settings.roa.use_roa
        % default region of avoidance to first ordinal threshold
        if ~isfield(settings.roa,'ord_label_to_avoid')
            settings.roa.ord_label_to_avoid = 1;
        end
        if ~isfield(settings.roa,'roa_thresh')
            settings.roa.roa_thresh = settings.gp_settings.ordinal_thresholds(settings.roa.ord_label_to_avoid + 1); % the corresponding ordinal threshold for ROA
        end
    end
end

% If no synthetic true objective is giving, set to zero
if ~isfield(settings,'useSyntheticObjective') || ~settings.useSyntheticObjective
    settings.useSyntheticObjective = 0;
    settings.simulation.true_objectives = [];
    settings.simulation.true_bestObjective = [];
    settings.simulation.true_best_action_globalind = [];
    settings.simulation.true_best_action = [];
    settings.simulation.true_ord_labels = [];
elseif settings.useSyntheticObjective
    
    if ~isfield(settings.simulation,'objective_settings')
        settings.simulation.objective_settings = [];
    end
    
    % get true objectives based on function in ObjectiveFunction.m
    allvals = ObjectiveFunction(settings.simulation.objective_settings,settings.points_to_sample);
    settings.simulation.true_objective_range = (max(allvals)-min(allvals));
    settings.simulation.true_objective_min = min(allvals);
    if settings.gp_settings.isNormalize
        settings.simulation.true_objectives = (allvals - min(allvals))/(max(allvals)-min(allvals));
    else
        settings.simulation.true_objectives = allvals;
    end
    
    % get true ordinal labels;
    labels = zeros(settings.num_actions,1);
    for i = 1:settings.num_actions
        temp = find(settings.simulation.true_objectives(i) >= settings.simulation.true_ord_threshold);
        labels(i) = temp(end);
    end
    settings.simulation.true_ordinal_labels = labels;
    
    % get true best action and corresponding objective value
    [settings.simulation.true_bestObjective,settings.simulation.true_best_action_globalind] = max(settings.simulation.true_objectives);
    settings.simulation.true_best_action = settings.points_to_sample(settings.simulation.true_best_action_globalind,:);
    
    % synthetic coactive settings
    if any(settings.feedback.types == 2)
        if ~isfield(settings.simulation,'synth_coac')
            settings.simulation.synth_coac = [];
        end
        if ~isfield(settings.simulation.synth_coac,'sightRanges')
            % maximum sight range for 'large suggestions'
            % small suggestions will be half of the large sight range
            settings.simulation.synth_coac.sightRanges = zeros(1,length(settings.parameters));
            for i = 1:length(settings.parameters)
                settings.simulation.synth_coac.sightRanges(i) = 0.2*range(settings.parameters(i).actions,2)';
            end
        end
        if ~isfield(settings.simulation.synth_coac,'smallTrigger')
            settings.simulation.synth_coac.smallTrigger = 0.6;
        end
        if ~isfield(settings.simulation.synth_coac,'largeTrigger')
            settings.simulation.synth_coac.largeTrigger = 0.3;
        end
    end
end

% Put GP_settings into the correct form
settings.gp_settings.lengthscales = [settings.parameters(:).lengthscale];
settings.gp_settings.action_names = {settings.parameters(:).name};
obj.settings = settings;

end