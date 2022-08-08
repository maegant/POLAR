function obj = post_update(obj)
% Description: Approximate the Bayesian posterior as a Gaussian
%   distribution. The mean is solved as the minimizer of a functional S(a),
%   and the covariance is solved as the hessian evaluated at the post mean.

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
    % go through each pairwise preference
    for i = 1:size(obj.pref_data,1)
        label = obj.pref_labels(i,:); %preference label
        s_pos = obj.pref_data(i,label); %preferred index
        s_neg = obj.pref_data(i,3-label); %non-preferred index
        
        % calculate feedback likelihood
        z = (f(s_pos) - f(s_neg)) ./ obj.pref_noise; %link function input
        switch obj.linkfunction
            case 'sigmoid'
                objective = objective - sum(log(obj.sigmoid(z)));
            case 'gaussian'
                objective = objective - sum(log(normcdf(z)));
        end
    end
end

% Coactive Feedback
if ~isempty(obj.coac_data)
    % go through each coactive suggestion
    for i = 1:size(obj.coac_data,1)
        label = obj.coac_labels(i,:); %coactive action label
        s_pos = obj.coac_data(i,label); %preferred index
        s_neg = obj.coac_data(i,3-label); %non-preferred index
        
        % calculate feedback likelihood
        z = (f(s_pos) - f(s_neg)) ./ obj.coac_noise; %link function input
        switch obj.linkfunction
            case 'sigmoid'
                objective = objective - sum(log(obj.sigmoid(z)));
            case 'gaussian'
                objective = objective - sum(log(normcdf(z)));
        end
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
    for i = 1:size(obj.pref_data,1)
        label = obj.pref_labels(i,:);
        s_pos = obj.pref_data(i,label);
        s_neg = obj.pref_data(i,3-label);
        
        z = (f(s_pos) - f(s_neg)) ./ obj.pref_noise;
        switch obj.linkfunction
            case 'sigmoid'
                grad_i_terms = 1./obj.pref_noise .* (obj.sigmoid_der(z) ./ obj.sigmoid(z) );
            case 'gaussian'
                grad_i_terms = 1./obj.pref_noise .* (normpdf(z) ./ normcdf(z) );
        end
        
        grad(s_pos) = grad(s_pos) - grad_i_terms;
        grad(s_neg) = grad(s_neg) + grad_i_terms;
    end
end

% Coactive Feedback
if ~isempty(obj.coac_data)
    for i = 1:size(obj.coac_data,1)
        label = obj.coac_labels(i,:);
        s_pos = obj.coac_data(i,label);
        s_neg = obj.coac_data(i,3-label);
        z = (f(s_pos) - f(s_neg)) ./ obj.coac_noise;
        
        switch obj.linkfunction
            case 'sigmoid'
                grad_i_terms = 1./obj.coac_noise .* (obj.sigmoid_der(z) ./ obj.sigmoid(z) );
            case 'gaussian'
                grad_i_terms = 1./obj.coac_noise .* (normpdf(z) ./ normcdf(z) );
        end
        
        grad(s_pos) = grad(s_pos) - grad_i_terms;
        grad(s_neg) = grad(s_neg) + grad_i_terms;
    end
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
    
    for i = 1:size(obj.ord_data,1)
        grad(obj.ord_data(i)) = grad(obj.ord_data(i))+ grad_i_terms(i);
    end
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
    for i = 1:size(obj.pref_data,1)
        label = obj.pref_labels(i,:);
        s_pos = obj.pref_data(i,label);
        s_neg = obj.pref_data(i,3-label);
        z = (f(s_pos) - f(s_neg)) ./ obj.pref_noise;
        
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
        
        Lambda(s_pos, s_pos) = Lambda(s_pos, s_pos) + final_i_terms;
        Lambda(s_neg, s_neg) = Lambda(s_neg, s_neg) + final_i_terms;
        Lambda(s_pos, s_neg) = Lambda(s_pos, s_neg) - final_i_terms;
        Lambda(s_neg, s_pos) = Lambda(s_neg, s_pos) - final_i_terms;
    end
end

% Coactive Feedback
if ~isempty(obj.coac_data)
    for i = 1:size(obj.coac_data,1)
        label = obj.coac_labels(i,:);
        s_pos = obj.coac_data(i,label);
        s_neg = obj.coac_data(i,3-label);
        z = (f(s_pos) - f(s_neg)) ./ obj.coac_noise;
    
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
        
        Lambda(s_pos, s_pos) = Lambda(s_pos, s_pos) + final_i_terms;
        Lambda(s_neg, s_neg) = Lambda(s_neg, s_neg) + final_i_terms;
        Lambda(s_pos, s_neg) = Lambda(s_pos, s_neg) - final_i_terms;
        Lambda(s_neg, s_pos) = Lambda(s_neg, s_pos) - final_i_terms;
    end
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
    
    lamb_i_terms = diag(Lambda);
    for i = 1:size(obj.ord_data,1)
        lamb_i_terms(obj.ord_data(i)) = lamb_i_terms(obj.ord_data(i))+ final_i_terms(i);
    end
    Lambda = Lambda + diag(lamb_i_terms - diag(Lambda));
end

hessian = obj.prior_cov_inv + Lambda;
end





