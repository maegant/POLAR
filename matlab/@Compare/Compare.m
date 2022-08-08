classdef Compare < handle
    %Description: This class runs multiple PBL simulations to compare
    %   various learning parameters
    
    properties
        fhs % figure handles
        new_runs
        total_runs
        num_iters
        results
        metrics
        settings
        setting_labels
    end
    
    methods
        function obj = Compare(varargin)
            
            % Start total run count
            obj.total_runs = 0;
                        
            % Filter through all inputs:
            obj.initializeComparisons(varargin{:});
            
            % Run PBL for number of new_runs
            obj.runPBL;
            
            % Compile mean and stds of PBL metrics
            obj.compileMetrics;
            
            % Plot results
            obj.plotComparisons;
            
        end
    end
    
    methods (Access = 'private')
        initializeComparisons(obj,varargin);
        runPBL(obj);
        compileMetrics(obj);
        saveFigures(obj);
        getSettings(obj,default_settings, varargin);
    end
    
    methods (Access = 'public')
        plotComparisons(obj);
        addRuns(obj,new_runs);
    end
end

