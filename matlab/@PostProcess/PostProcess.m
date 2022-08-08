classdef PostProcess < handle
    %Description: obtain full posterior across entire action space
    %
    % Note: This is usually computationally expensive, so it is only done
    %   at the end of the learning procedure for visualization purposes
    
    properties
        gp  %final posterior updated over all actions or finer discretization of actions
        grid_size
        settings
    end
    
    methods
        function obj = PostProcess(alg,gridsize)
            
            % choose either original grid size or custom grid size
            if nargin < 2
                % get grid size of original points in setup
                obj.grid_size = cellfun(@length,{alg.settings.parameters(:).actions});
            else
                obj.grid_size = gridsize;
            end
                
            % get posterior corresponding to desired grid size
            obj.getFinePosterior(alg)
            
        end
    end
    
    methods (Access = 'private')
        newGlobalIndMapping = getMapping(obj,alg,points_to_include);
    end
end
