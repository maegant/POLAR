classdef UserFeedback < handle
    %FEEDBACK This class queries either the user for feedback
    %   
    
    properties
        preference
        coactive
        ordinal
    end
    
    methods
        function feedback = UserFeedback(alg,iteration)
                   
            if nargin < 2
                iteration = length(alg.iteration);
            end
            
            % Get user feedback
            feedback = feedback.getUserFeedback(alg,iteration);

        end
    end
    
    methods (Access = private)
        
        % Feedback
        feedback = getUserFeedback(feedback,alg,iteration);
        
        % Types of user feedback;
        pref_label = getUserPreference(feedback, alg, iteration);
        coac_data = getUserSuggestion(feedback, alg, iteration);
        ord_label  = getUserLabel(feedback, alg, iteration);
    end
    
    methods (Static)
        printActionInformation(alg,iteration)
    end
end

