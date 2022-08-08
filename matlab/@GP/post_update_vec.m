function obj = post_update_vec(obj)
% Description: Vectorized version of post_update

% Get vectorized feedback inputs
obj.vectorizeFeedback;

% Setup Minimization Problem:
options = optimoptions(@fminunc,'Algorithm','trust-region',...
    'SpecifyObjectiveGradient',true,...
    'HessianFcn','objective',...
    'Display','off');

% Solve minimization problem to get post_mean
obj.mean = fminunc(@(f) preference_GP_objective(f,obj),...
    obj.initial_guess,...
    options);

% Hessian evaluated at post mean
post_cov_inverse = preference_GP_hessian(obj.mean,obj);
obj.sigma = inv(post_cov_inverse);

% Calculate uncertainty of distribution
obj.uncertainty = sqrt(diag(obj.sigma));
end

%%
function [objective, gradient, hessian] = preference_GP_objective(f,obj)
%%%
% Evaluate the optimization objective function for finding the posterior
% mean of the GP preference model (at a given point); the posterior mean is
% the minimum of this (convex) objective function.
%
% Inputs:
%     1) f: the "point" at which to evaluate the objective function. This
%           is a length-n vector (n x 1) , where n is the number of points
%           over which the posterior is to be sampled.
%     2) obj: @GP insteance
%
% Output:
%     1) objective: the objective function evaluated at the given point (f)
%     2) gradient: gradient of the functional S
%     3) hessian: hessian of the functional S
%%%

% make sure f is column vector
reshape(f,[],1);

% initialize objective with constant term:
objective = 0.5*f'*obj.prior_cov_inv*f;

% Preference Feedback
if ~isempty(obj.pref_data)
    % calculate feedback likelihood
    z = (f(obj.pref_pos_ind) - f(obj.pref_neg_ind)) ./ obj.pref_noise; %link function input
    switch obj.linkfunction
        case 'sigmoid'
            objective = objective - sum(log(obj.sigmoid(z)));
        case 'gaussian'
            objective = objective - sum(log(normcdf(z)));
    end
end

% Coactive Feedback
if ~isempty(obj.coac_data)
    % calculate feedback likelihood
    z = (f(obj.coac_pos_ind) - f(obj.coac_neg_ind)) ./ obj.coac_noise; %link function input
    switch obj.linkfunction
        case 'sigmoid'
            objective = objective - sum(log(obj.sigmoid(z)));
        case 'gaussian'
            objective = objective - sum(log(normcdf(z)));
    end
end

% Ordinal Feedback
if ~isempty(obj.ord_data)
    % evaluated at upper threshold
    z_ord1 = (obj.ordinal_thresholds(obj.ord_labels +1) -  f(obj.ord_data))./ obj.ord_noise;
    
    % evaluated at lower threshold
    z_ord2 = (obj.ordinal_thresholds(obj.ord_labels) -  f(obj.ord_data))./ obj.ord_noise;
    
    switch obj.linkfunction
        case 'sigmoid'
            objective = objective - sum(log(obj.sigmoid(z_ord1) - obj.sigmoid(z_ord2)));
        case 'gaussian'
            objective = objective - sum(log(normcdf(z_ord1) - normcdf(z_ord2)));
    end
end

% Calculate gradient
gradient = preference_GP_gradient(f,obj);

% Calculate hessian
hessian = preference_GP_hessian(f,obj);
end

%% %%%%%%%%%%%%%%%%%%% Evaluate gradient of S(U) %%%%%%%%%%%%%%%%%%%%%%%%%%
function grad = preference_GP_gradient(f,obj)
%%%
%     Evaluate the gradient of the optimization objective function for finding
%     the posterior mean of the GP preference model (at a given point).
%
%     Inputs:
%         1) f: the "point" at which to evaluate the gradient. This is a length-n
%            vector, where n is the number of points over which the posterior
%            is to be sampled.
%         2) obj: @GP insteance
%
%     Output: the objective function's gradient evaluated at the given point (f).
%%%


grad = obj.prior_cov_inv * f;    % Initialize to 1st term of gradient

% Preference Feedback
if ~isempty(obj.pref_data)
    z = (f(obj.pref_pos_ind) - f(obj.pref_neg_ind)) ./ obj.pref_noise;
    switch obj.linkfunction
        case 'sigmoid'
            grad_i_terms = 1./obj.pref_noise .* (obj.sigmoid_der(z) ./ obj.sigmoid(z) );
        case 'gaussian'
            grad_i_terms = 1./obj.pref_noise .* (normpdf(z) ./ normcdf(z) );
    end
    
    % vectorized addition/subtraction of terms
    grad(obj.pref_pos_unique_inds) = grad(obj.pref_pos_unique_inds) - obj.pref_pos_repeating_inds'*grad_i_terms;
    grad(obj.pref_neg_unique_inds) = grad(obj.pref_neg_unique_inds) + obj.pref_neg_repeating_inds'*grad_i_terms;
end

% Coactive Feedback
if ~isempty(obj.coac_data)
    z = (f(obj.coac_pos_ind) - f(obj.coac_neg_ind)) ./ obj.coac_noise;
    switch obj.linkfunction
        case 'sigmoid'
            grad_i_terms = 1./obj.coac_noise .* (obj.sigmoid_der(z) ./ obj.sigmoid(z) );
        case 'gaussian'
            grad_i_terms = 1./obj.coac_noise .* (normpdf(z) ./ normcdf(z) );
    end
    
    % vectorized addition/subtraction of terms
    grad(obj.coac_pos_unique_inds) = grad(obj.coac_pos_unique_inds) - obj.coac_pos_repeating_inds'*grad_i_terms;
    grad(obj.coac_neg_unique_inds) = grad(obj.coac_neg_unique_inds) + obj.coac_neg_repeating_inds'*grad_i_terms;
end

% Ordinal Feedback
if ~isempty(obj.ord_data)
    z1 = (obj.ordinal_thresholds(obj.ord_labels+1) -  f(obj.ord_data))./ obj.ord_noise;
    z2 = (obj.ordinal_thresholds(obj.ord_labels) -  f(obj.ord_data))./ obj.ord_noise;
    
    switch obj.linkfunction
        case 'sigmoid'
            grad_i_terms = 1./obj.ord_noise .* (obj.sigmoid_der(z1) - obj.sigmoid_der(z2)) ./ (obj.sigmoid(z1) - obj.sigmoid(z2));
        case 'gaussian'
            grad_i_terms = 1./obj.ord_noise .* (normpdf(z1) -normpdf(z2)) ./(normcdf(z1) -normcdf(z2));
            
    end
    
    % vectorized addition/subtraction of terms
    grad_i_terms_vec = obj.ord_data_repeating_inds'*grad_i_terms;
    grad(obj.ord_data_unique_inds) = grad(obj.ord_data_unique_inds) + grad_i_terms_vec;
end

end

%% %%%%%%%%%%%%%%%%%%%% Evaluate Hessian of S(U) %%%%%%%%%%%%%%%%%%%%%%%%%%
function hessian = preference_GP_hessian(f,obj)
%%%%%
%     Evaluate the Hessian matrix of the optimization objective function for
%     finding the posterior mean of the GP preference model (at a given point).
%
%     Inputs:
%         1) f: the "point" at which to evaluate the Hessian. This is
%            a length-n vector, where n is the number of points over which the
%            posterior is to be sampled.
%         2) obj: @GP insteance
%
%     Output: the objective function's Hessian matrix evaluated at the given
%             point (f).
%%%%%


sz = size(obj.prior_cov_inv);
Lambda = zeros(sz);

% Preference Feedback
if ~isempty(obj.pref_data)
    z = (f(obj.pref_pos_ind) - f(obj.pref_neg_ind)) ./ obj.pref_noise;
    
    switch obj.linkfunction
        case 'sigmoid'
            sigmz = obj.sigmoid(z);
            sigmz(sigmz == 0) = 10^(-100);
            first_i_terms = (obj.sigmoid_der2(z) ./ obj.pref_noise^2 )./sigmz;
            second_i_terms = ( (obj.sigmoid_der(z)./ obj.pref_noise) ./ sigmz ).^2;
            final_i_terms = -  (first_i_terms - second_i_terms);
        case 'gaussian'
            ratio = normpdf(z) ./ normcdf(z);
            final_i_terms = (ratio .* (z + ratio)) ./ (obj.pref_noise.^2);
    end
    
    % Vectorized addition of Hessian terms
    Lambda(obj.pref_pospos_unique_inds) = Lambda(obj.pref_pospos_unique_inds) + obj.pref_pospos_repeating_inds'*final_i_terms;
    Lambda(obj.pref_negneg_unique_inds) = Lambda(obj.pref_negneg_unique_inds) + obj.pref_negneg_repeating_inds'*final_i_terms;
    Lambda(obj.pref_posneg_unique_inds) = Lambda(obj.pref_posneg_unique_inds) - obj.pref_posneg_repeating_inds'*final_i_terms;
    Lambda(obj.pref_negpos_unique_inds) = Lambda(obj.pref_negpos_unique_inds) - obj.pref_negpos_repeating_inds'*final_i_terms;
end

% Coactive Feedback
if ~isempty(obj.coac_data)
    z = (f(obj.coac_pos_ind) - f(obj.coac_neg_ind)) ./ obj.coac_noise;
    
    switch obj.linkfunction
        case 'sigmoid'
            sigmz = obj.sigmoid(z);
            sigmz(sigmz == 0) = 10^(-100);
            first_i_terms = (obj.sigmoid_der2(z) ./ obj.coac_noise^2 )./sigmz;
            second_i_terms = ( (obj.sigmoid_der(z)./ obj.coac_noise) ./ sigmz ).^2;
            final_i_terms = -  (first_i_terms - second_i_terms);
        case 'gaussian'
            ratio = normpdf(z) ./ normcdf(z);
            final_i_terms = (ratio .* (z + ratio)) ./ (obj.coac_noise.^2);
    end
    
    % Vectorized addition of Hessian terms
    Lambda(obj.coac_pospos_unique_inds) = Lambda(obj.coac_pospos_unique_inds) + obj.coac_pospos_repeating_inds'*final_i_terms;
    Lambda(obj.coac_negneg_unique_inds) = Lambda(obj.coac_negneg_unique_inds) + obj.coac_negneg_repeating_inds'*final_i_terms;
    Lambda(obj.coac_posneg_unique_inds) = Lambda(obj.coac_posneg_unique_inds) - obj.coac_posneg_repeating_inds'*final_i_terms;
    Lambda(obj.coac_negpos_unique_inds) = Lambda(obj.coac_negpos_unique_inds) - obj.coac_negpos_repeating_inds'*final_i_terms;
end


% Ordinal Feedback

if ~isempty(obj.ord_data)
    switch obj.linkfunction
        case 'sigmoid'
            z1 = (obj.ordinal_thresholds(obj.ord_labels+1) -  f(obj.ord_data))/ obj.ord_noise;
            z2 = (obj.ordinal_thresholds(obj.ord_labels) -  f(obj.ord_data))/ obj.ord_noise;
            sigmz = obj.sigmoid(z1) - obj.sigmoid(z2);
            sigmz(sigmz == 0) = 10^(-100);
            first_i_terms = (obj.sigmoid_der2(z1)./obj.ord_noise^2 -obj.sigmoid_der2(z2)./obj.ord_noise^2)./sigmz;
            second_i_terms = ((obj.sigmoid_der(z1)./obj.ord_noise - obj.sigmoid_der(z2)./obj.ord_noise) ./ sigmz).^2;
            final_i_terms = -  (first_i_terms - second_i_terms);
        case 'gaussian'
            obj.ordinal_thresholds(obj.ordinal_thresholds == -Inf) = -10^(100);
            obj.ordinal_thresholds(obj.ordinal_thresholds == Inf) = 10^(100);
            z1 = (obj.ordinal_thresholds(obj.ord_labels+1) -  f(obj.ord_data))/ obj.ord_noise;
            z2 = (obj.ordinal_thresholds(obj.ord_labels) -  f(obj.ord_data))/ obj.ord_noise;
            first_i_terms = (z1.* normpdf(z1)  - z2.*normpdf(z2)) ./ (normcdf(z1) - normcdf(z2));
            second_i_terms = (normpdf(z1) - normpdf(z2)).^2 ./ (normcdf(z1) - normcdf(z2)).^2 ;
            final_i_terms = first_i_terms + second_i_terms;
    end
    
    % Vectorized addition of Hessian terms
    final_i_terms_vec = obj.ord_data_repeating_inds'*final_i_terms;
    lamb_i_terms = diag(Lambda);
    lamb_i_terms(obj.ord_data_unique_inds) = lamb_i_terms(obj.ord_data_unique_inds) + final_i_terms_vec;
    Lambda = Lambda + diag(lamb_i_terms - diag(Lambda));
end

hessian = obj.prior_cov_inv + Lambda;
end





