classdef PBL < handle
    % PBL (Preference-Based Learning) is the main class for the POLAR (Preference Optimization and
    % Learning Algorithm for Robotics) toolbox. This class includes the
    % posterior sampling algorithms for regret minimization and active 
    % learning
    %
    % @author Maegan Tucker @date 2020-11-27
    %
    % Copyright (c) 2020, AMBER Lab All right reserved.
    %
    % Redistribution and use in source and binary forms, with or without
    % modification, are permitted only in compliance with the BSD 3-Clause
    % license, see http://www.opensource.org/licenses/bsd-license.php
    
    %% Public Properties
    properties
        settings % structure of learning and action space settings
        
        unique_visited_actions % list of uniquely visited actions
        unique_visited_action_globalInds % global indices corresponding to unique_visited_actions
        unique_visited_isCoac %flags corresponding to if visited actions were sampled or coactive
        sample_table % history of number of sampled actions in terms of 
        
        iteration % structure with information specific to each iteration
        
        feedback % structure with compiled user/simulated feedback
        
        post_model % structure containing posterior model updated at each iteration
                
        comp_time % structure containing information regarding computation time
        
        previous_data % structure containing information loaded from previous experimental data
               
        metrics % evaluation metrics
    end
    
    %% Instantiation
    methods (Access = public)
        function obj = PBL(settings)
            % POLAR class constructor 
            
            % Initialize and setup algorithm settings
            obj.settings = settings;
            obj.algSetup;

            % initialize empty objects
            obj.unique_visited_actions = [];
            obj.unique_visited_isCoac = [];
            dim_values =  []; % column vector of corresponding dimensions
            action_bins = []; % column vector of bin sizes
            obj.sample_table = table(dim_values,action_bins);
            max_bins = max(obj.settings.bin_sizes);
            obj.sample_table = [obj.sample_table;[repmat({NaN},max_bins,1),num2cell(reshape(1:max_bins,[],1))]];            
            obj.iteration = struct('buffer',[],'samples',[],'best',[],...
                                    'subset',[],'feedback',[]);
            obj.post_model = struct('which',[], ...
                                    'actions',[],'action_globalInds',[],...
                                    'prior_cov',[], ...
                                    'prior_cov_inv',[], ...
                                    'mean',[],...
                                    'sigma',[],'uncertainty',[]);;
                                
            obj.feedback = struct('preference',[],'coactive',[],'ordinal',[]);
            obj.feedback.preference = struct('x_subset',[],'x_full',[],'y',[]);
            obj.feedback.coactive = struct('x_subset',[],'x_full',[],'y',[]);
            obj.feedback.ordinal = struct('x_subset',[],'x_full',[],'y',[]);
                                
            obj.comp_time = struct('acquisition',[],'posterior',[]);
        end
    end
    
    %%  Methods defined in external files
    methods (Access = public)
        
        % Reset
        reset(obj);
        
        % Delete large matrices stored in post_model
        removeLargeMatrices(obj);
        
        % Synthetic simulations
        runSimulation(obj,plottingFlag,saveFlag);
        
        % Experiment script
        runExperiment(obj,plottingFlag,saveFlag,exportFile);
        
        % Previous Experiment Prior
        addPreviousData(obj, action_list, pref_data, pref_labels, ...
                        coac_data, coac_labels, ord_data, ord_labels);
                                
        % get new actions
        getNewActions(obj,iteration);
        
        % Test lengthscales for tuning hyperparameters
        testLengthscales(obj,f); % reserves figure(301)
        
        % Post Processing Script
        postProcess(obj,gridsize);
        newSampleGlobalInds = getMapping(obj,samples)
        
        
        %% To remove!
        linear_subspace = getLinearSubspace(obj,iteration)
               
    end
    
    methods (Access = public)
        
        % Setup
        algSetup(obj); 
        
        % Action Indexing:
        newSampleVisitedInds = getVisitedInd(obj,samples);
        newSampleGlobalInds = getGlobalInd(obj,samples);
        newSampleVisitedInds = appendVisitedInd(obj,samples,isCoac)
        
        % Posterior Update
        updateBestAction(obj,iteration);
        updatePosterior(obj,which,points_to_include,globalInds,iteration);
        
    end
    
end

