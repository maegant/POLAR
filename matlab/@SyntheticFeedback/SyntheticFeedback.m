classdef SyntheticFeedback < handle
    %FEEDBACK This class generates synthetic feedback
    %   
    
    properties
        preference
        coactive
        ordinal
    end
    
    methods
        function feedback = SyntheticFeedback(alg,iteration)
               
            if nargin < 2
                iteration = length(alg.iteration);
            end
            
             % Get Synthetic Feedback
            feedback = feedback.getSyntheticFeedback(alg,iteration);

        end
    end
    
    methods (Access = public) 
        feedback = getSyntheticFeedback(feedback,alg,iteration);
    end
    
    methods (Access = private)
        pref_label = getSyntheticPreference(feedback,obj, iteration);
        coac_data = getSyntheticSuggestion(feedback, obj, iteration);
        ord_label = getSyntheticLabel(feedback, obj, iteration); 
    end
    
    methods (Static)
        printActionInformation(alg,iteration)
    end
    
end

