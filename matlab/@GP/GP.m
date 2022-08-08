classdef GP < handle
    %Description: This class uses preference, coac, and ordinal feedback to
    % maintain a Bayesian posterior via a Gaussian process.
    %
    % Date: June 25, 2021
    % Authors: Maegan Tucker, Kejun (Amy) Li
    %
    
    properties (Access = public)
        % option to normalize posterior to 0 to 1
        % 
        % type: @boolean
        isNormalize
        
        % hyperparameter for noise variance of the GP
        %
        % type: @scalar
        GP_noise_var
        
        % hyperparameter for mean variance of the GP
        %
        % type: @scalar
        signal_variance
        
        % hyperparameter for lengthscale of each action space dimension
        %
        % type: 1xm vector
        lengthscales
        
        % posterior noise hyperparameter for:
        %   - pairwise preferences
        %   - coactive actions
        %   - ord_noise
        %
        % type: @scalar
        pref_noise
        coac_noise
        ord_noise
        
        linkfunction
        ordinal_thresholds
        
        % actions over which to evaluate posterior
        %
        % type: nxm matrix (n actions of dimensionality m)
        actions
        action_names
        % grid size corresponding to continuous action space
        %
        % type: 1xm row vector
        grid_size
        
        pref_data
        pref_labels
        coac_data
        coac_labels
        ord_data
        ord_labels
        
        initial_guess
        
        prior_cov
        prior_cov_inv
        
        mean
        sigma
        uncertainty
    end
    
    properties ( Access = private)
        % vector of preferred and non-preferred indices
        pref_pos_ind
        pref_neg_ind
        coac_pos_ind
        coac_neg_ind
        
        % unique and repeating indices for vectorization
        pref_pos_unique_inds
        pref_neg_unique_inds
        pref_pos_repeating_inds
        pref_neg_repeating_inds
        coac_pos_unique_inds
        coac_neg_unique_inds
        coac_pos_repeating_inds
        coac_neg_repeating_inds
        
        % unique and repeating indices of hessian for vectorization
        pref_pospos_unique_inds
        pref_pospos_repeating_inds
        pref_negneg_unique_inds
        pref_negneg_repeating_inds
        pref_posneg_unique_inds
        pref_posneg_repeating_inds
        pref_negpos_unique_inds
        pref_negpos_repeating_inds
        coac_pospos_unique_inds
        coac_pospos_repeating_inds
        coac_negneg_unique_inds
        coac_negneg_repeating_inds
        coac_posneg_unique_inds
        coac_posneg_repeating_inds
        coac_negpos_unique_inds
        coac_negpos_repeating_inds
        
        % unique and repeating inds of ordinal feedback
        ord_data_unique_inds
        ord_data_repeating_inds;
    end
    
    methods
        function obj = GP(settings,...
                actions, ...
                grid_size,...
                pref_data, pref_labels,...
                coac_data, coac_labels,...
                ord_data, ord_labels,...
                initial_guess, prior_cov, prior_cov_inv,...
                isVectorized)
            %GP Construct an instance of this class
            
            % Store algorithm hyperparameters:
            obj.isNormalize = settings.isNormalize;
            obj.pref_noise = settings.pref_noise;
            obj.coac_noise = settings.coac_noise; %posterior noise hyperparameter for coactive actions
            obj.ord_noise = settings.ord_noise; %posterior noise hyperparameter for ordinal labels
            obj.linkfunction = settings.linkfunction; %choice of linkfunction
            obj.GP_noise_var = settings.GP_noise_var; %noise variance for the GP
            obj.signal_variance = settings.signal_variance; %variance for mean of the GP
            obj.lengthscales = settings.lengthscales; %lengthscales for each dimension of the action space
            obj.ordinal_thresholds = reshape(settings.ordinal_thresholds,[],1); %posterior values used to separate ordinal categories
            
            % store actions
            obj.actions = actions;
            obj.action_names = settings.action_names;
            % if actions are a continuous action space, then grid_size is
            % the corresponding number of actions in each dimension (used
            % for plotting purposes)
            obj.grid_size = grid_size;
            
            % store initial guess if given
            if nargin < 10
                % start with uniform prior:
                obj.initial_guess = zeros(size(actions,1),1);
            else
                if isempty(obj.initial_guess)
                    obj.initial_guess = zeros(size(actions,1),1);
                else
                    obj.initial_guess = initial_guess;
                end
            end
            
            % calculate prior covariance (and prior covariance inverse) if
            % not given
            if nargin < 11
                obj.calculatePrior;
            else
                if isempty(prior_cov)
                    obj.calculatePrior;
                else
                    obj.prior_cov = prior_cov;
                    obj.prior_cov_inv = prior_cov_inv;
                end
            end
            
            if nargin < 13
                % option to vectorize minimization problem
                isVectorized = true; 
            end
            
            % use data to infer GP over actions
            obj.pref_data = pref_data; obj.pref_labels = pref_labels;
            obj.coac_data = coac_data; obj.coac_labels = coac_labels;
            obj.ord_data = ord_data; obj.ord_labels = ord_labels;
            
            % Infer Bayesian posterior:
            if isempty([obj.pref_labels;obj.coac_labels;obj.ord_labels])
                % if no data - use nonvectorized update
                obj.post_update;
            else
                switch isVectorized
                    case true
                        % update the GP (vectorized)
                        obj.post_update_vec;
                    case false
                        % update the GP (non-vectorized)
                        obj.post_update;
                end
            end
                        
        end
        
    end
    
    methods (Access = public)
        f = plotGP(obj,dim_type, combinations);
    end
    
    methods (Access = private)
        obj = calculatePrior(obj);
        obj = vectorizeFeedback(obj);
        obj = post_update_vec(obj);
        obj = post_update(obj);
        
        % Plotting help
        [X, Y, Z] = getSurfaces(obj,plotting_type)
        
    end
    
    methods (Static)
        
        % sigmoid link function functions:
        out = sigmoid(x);
        out = sigmoid_der(x);
        out = sigmoid_der2(x);
    end
end

