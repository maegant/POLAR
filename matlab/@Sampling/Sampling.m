classdef Sampling < handle
    %SAMPLING
    % Description: Draw samples from the posterior distribution based on choice
    %   of aquisition function
    
    properties
        actions
        global_inds
        visited_inds
        rewards
    end
    
    methods
        function samples = Sampling(alg,iteration)
            
            if nargin < 2
                iteration = length(alg.iteration);
            end
            
            switch alg.settings.sampling.type
                
                case 1 %Regret minimization
                    
                    % Use full posterior model with Thompson sampling
                    [actions, rewards] = samples.ThompsonSampling(alg,iteration);
                    
                case 2 %Active learning
                    
                    % Use full posterior model with Information Gain
                    [actions, rewards] = samples.InformationGain(alg,iteration);
                    
                case 3 %Random Sampling
                    [actions, rewards] = samples.Random(alg);
                    
                otherwise
                    error('Unknown acquisiton type. obj.settings.acq_type must be 1 (regret minimization) or 2 (active learning)');
            end
            
            % Append sampled actions and rewards to object
            samples.actions = actions;
            samples.rewards = rewards;
            
            % Get visited indices (corresponding to unique sampled points)
            % and global indices (corresponding to all points in action space)
            samples.visited_inds = alg.getVisitedInd(samples.actions);
            samples.global_inds = alg.getGlobalInd(samples.actions);
            
        end
        
    end
    
    methods(Static)
        actions = getRandAction(alg,num_actions);
        
        % Static functions used for Information Gain:
        pref_prod = eval_pref_prod(s,y_pref,alg)
        ord_prod = eval_ord_prod(o,y,alg);
        
    end
    
    methods (Access = private)
        [actions, rewards] = ThompsonSampling(obj,alg,iteration);
        [actions, rewards] = InformationGain(obj,alg,iteration);
        [actions, rewards] = Random(obj,alg);
        
        % Helper functions
        [newSampleGlobalInd,newSamples] = eval_IG(obj,alg, R, select_idx,buffer_action_idx, iteration);
    end
    
end

