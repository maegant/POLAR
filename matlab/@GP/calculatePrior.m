function obj = calculatePrior(obj)
% Description: calculate the prior covariance matrix and prior covariance
%              matrix inverse for the given actions with given hyperparams

obj.prior_cov = squared_exp_kernel(obj.actions, ...
                                   obj.signal_variance, ...
                                   obj.GP_noise_var, ...
                                   obj.lengthscales);
obj.prior_cov_inv = inv(obj.prior_cov);

end

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