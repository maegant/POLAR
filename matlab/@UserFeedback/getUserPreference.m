function pref_label = getUserPreference(feedback, alg, iteration)
% Query human for pairwise preference

if nargin < 2
    iteration = length(alg.iteration);
end


%------------------------ query user for feedback -------------------------

% query for preference feedback
if isempty(alg.iteration(iteration).feedback.p_x_subset)
    pref_input = input('Ready to continue? (y/1):   ','s');
        while ~((strcmpi(pref_input,'y')) || (strcmpi(pref_input,'1')))
            pref_input = input('Incorrect input given. Please enter 1 or y:   ');
        end
    pref_label = [];
else
    if length(alg.iteration(iteration).feedback.visitedInds) == 2
        
        % send question to user
        pref_input = input('Which gait do you prefer? (1,2 or 0 for no preference):   ');
        while ~any([pref_input == 0, pref_input == 1, pref_input == 2, pref_input == -1])
            pref_input = input('Incorrect input given. Please enter 0, 1 or 2:   ');
        end
        pref_label = pref_input;
    else
        
        % send question to user
        ranking = input('Give ranking of samples (first index given is most preferred):   ');
        while length(ranking) ~= length(alg.iteration(iteration).feedback.visitedInds) || ~ismember(ranking,perms(ranking),'row')
            if length(ranking) ~= length(alg.iteration(iteration).feedback.visitedInds)
                ranking = input(sprintf('Wrong number of rankings given. Please give %i rankings. (Actions 1 through %s)', length(alg.iteration(iteration).feedback.visitedInds)));
            elseif ~ismember(ranking,perms(ranking),'row')
                sformat = ['[ ',repmat('%i, ',1,length(alg.iteration(iteration).feedback.visitedInds)-1), '%i]'];
                ranking = input(sprintf(['Inputs must be a permutation of ',sformat],1:length(alg.iteration(iteration).feedback.visitedInds)-1));
            end
        end
        
        % convert ranking to pairwise preferences
        [~, pref_label] = rankingToPreferences(ranking, 0);
        
    end
end

end