function [comparisonInds, labels] = rankingToPreferences(ranking, prefnoise, trueObjectives)
% Ranking is ordered list of indices
% For example: [3 1 2] means that the third action is the best, the first
% action is ranked middle, and the second action is the worst

% get comparison inds
comparisonInds = nchoosek(1:length(ranking),2);

if nargin < 2
    labels = [];
else
    labels = zeros(size(comparisonInds,1),1);
    comparisonInds = nchoosek(1:length(ranking),2);
    labels = zeros(size(comparisonInds,1),1);
    for i = 1:size(comparisonInds,1)
        
        
        if prefnoise == 0
             % if the first action comes before in the list, prefer it
            if find(ranking == comparisonInds(i,1)) < find(ranking == comparisonInds(i,2))
                pref_prob = 1;

            % if the first action comes later in the list, prefer the other
            elseif find(ranking == comparisonInds(i,1)) > find(ranking == comparisonInds(i,2))
                pref_prob = 0;
            end
        else
            % assume sigmoid link function for preference feedback
            tempx = (trueObjectives(comparisonInds(i,1)) - trueObjectives(comparisonInds(i,2)))/prefnoise;
            pref_prob = GP.sigmoid(tempx);
            
        end
        
        labels(i) = randsample([1,2], ...
            1, 'true', [pref_prob,1-pref_prob]);
    end
end

end
