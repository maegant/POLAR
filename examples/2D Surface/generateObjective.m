function [obj,actions] = generateObjective(settings)
% Generate objective function by drawing a sample from prior

%% Draw samples from prior

signal_variance = settings.gp_settings.signal_variance;
lengthscales = [settings.parameters(:).lengthscale];
GP_noise_var = settings.gp_settings.GP_noise_var;

lower = [settings.parameters(:).lower];
upper = [settings.parameters(:).upper];
discs = [settings.parameters(:).discretization];

for i = 1:length(settings.parameters)
    actionCells{i} = lower(i):discs(i):upper(i);
end
actions = combvec(actionCells{:})';
dim = size(actions,2);

GP_prior_cov = squared_exp_kernel(actions, ...
                signal_variance, ...
                GP_noise_var, ...
                lengthscales);

num_actions = size(actions,1);
mean = 0.5 * ones(num_actions,1);

GP_sample = mvnrnd(mean, GP_prior_cov);
obj = (GP_sample - min(GP_sample,[],'all'))/(max(GP_sample,[],'all')-min(GP_sample,[],'all'));


end

%% squared exponential kernel
    function cov = squared_exp_kernel(X, variance, GP_noise_var, lengthscales)
        % Function: calculate the covariance matrix using the squared exponential kernel
        
        % normalize X by lengthscales in each dimension
        Xs = X./lengthscales;
        
        % Calculate (x-x')^2 as x^2 - 2xx' + x'^2
        Xsq = sum(Xs.^2,2);
        r2 = -2*(Xs*Xs') + (Xsq + Xsq');
        r2 = max(r2,0); % make sure all elements are positive
        
        % RBF
        cov = variance * exp(-0.5 * r2);
        
        % Add GP noise variance
        cov = cov + GP_noise_var * eye(size(X,1));
        
    end

