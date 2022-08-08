function initializeComparisons(obj, varargin)
% Populate the following properties based on class inputs:
%   - obj.settings
%   - obj.setting_labels
%   - obj.num_iters
%   - obj.new_runs

%% parse inputs:
p = inputParser;

%%%%% required inputs:
p.addRequired('default',@(x)isstruct(x));%'must provide default settings structure');
p.addRequired('runs',@(x)isscalar(x)&&(x>0));%'must provide desired number of new PBL runs');

p.addOptional('iters',varargin{1}.maxIter,@(x)isscalar(x)&&(x>0));%'must provide num iterations per PBL instance');

%%%%% optional inputs:
% requirements on options for feedback_types
validationFunc = @(c) validateattributes (c, {'double'},{'<=',3,'=>',1});
p.addOptional('feedback_types',[], ...
    @(x) cellfun(validationFunc, x));

% requirements on gp noise hyperparameters
validationFunc = @(c) validateattributes (c, {'double'},{'>',0});
p.addOptional('post_pref_noise',[], ...
    @(x) cellfun(validationFunc, x));
p.addOptional('post_coac_noise',[], ...
    @(x) cellfun(validationFunc, x));
p.addOptional('post_ord_noise',[], ...
    @(x) cellfun(validationFunc, x));

% requirements on simulated noise
validationFunc = @(c) validateattributes (c, {'double'},{'>=',0});
p.addOptional('simulated_pref_noise',[], ...
    @(x) cellfun(validationFunc, x));
p.addOptional('simulated_coac_noise',[], ...
    @(x) cellfun(validationFunc, x));
p.addOptional('simulated_ord_noise',[], ...
    @(x) cellfun(validationFunc, x));

% requirements on sampling settings
validationFunc = @(c) validateattributes (c, {'double'},{'>=',0});
p.addOptional('n',[], ...
    @(x) cellfun(validationFunc, x));
p.addOptional('b',[], ...
    @(x) cellfun(validationFunc, x));

% requirements on lengthscales
p.addOptional('lengthscales',[], ...
    @(x) cellfun(validationFunc, x));

%%%% parse inputs:
p.parse(varargin{:});

%% Update structure with comparison settings
obj.num_iters = p.Results.iters;
obj.new_runs =  p.Results.runs;

%% Get settings structure based on optional inputs:
setting_struct = rmfield(p.Results,p.UsingDefaults);
setting_struct = rmfield(setting_struct,{'default','iters','runs'});
default_settings = p.Results.default;
obj.getSettings(default_settings,setting_struct);

end

