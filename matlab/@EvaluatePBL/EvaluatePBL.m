classdef EvaluatePBL < handle
    % Description: This class computes various metrics used to evaluate the
    %   performance of the learning algorithm
    
    properties
        optimal_error
        inst_regret
        fit_error
        label_error
        pref_error
        post_update_time
        acq_time
    end
    
    methods
        function metrics = EvaluatePBL(alg,iteration)
            
            if nargin < 2
                iteration = length(alg.iteration);
            end
            
            % default number of points to include in posterior used to evaluate the accuracy of the framework
            evaluation_posterior_size = min(100,alg.settings.num_actions);

            % Get optimal error
            metrics.getOptimalError(alg,iteration);
            
            % Get instantaneous regret
            metrics.getRegret(alg,iteration);
            
            % Get errors associated with underlying GP
            metrics.getPredictionMetrics(evaluation_posterior_size,alg,iteration);

            % Get time metrics
            metrics.getTimeMetrics(alg,iteration);

        end
    end
    
    methods (Access = private)
       	getOptimalError(metrics,alg,iteration);
       	getRegret(metrics,alg,iteration);
        getPredictionMetrics(metrics,evaluation_posterior_size,alg,iteration);
        getTimeMetrics(metrics,alg,iteration);
    end
    
    methods (Static)
        predicted_labels = predictLabels(alg,gp_mean)
        [eval_gp_mean,eval_gp_inds] = getEvaluationPosterior(alg,evaluation_posterior_size)
    end
    
end

