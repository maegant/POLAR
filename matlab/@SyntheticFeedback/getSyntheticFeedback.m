function feedback = getSyntheticFeedback(feedback,alg,iteration)
% Generates automatic synthetic feedback based on predefined objective
% function in ObjectiveFunction.m

% print feedback:
if alg.settings.printInfo
    feedback.printActionInformation(alg,iteration);
end

% Get preferences
if any(alg.settings.feedback.types == 1)
    preference_feedback = feedback.getSyntheticPreference(alg,iteration);
else
    preference_feedback = [];
end

% Get user suggestions
if any(alg.settings.feedback.types == 2)
    coac_data = feedback.getSyntheticSuggestion(alg,iteration);
else
    coac_data = [];
end

% Get user labels
if any(alg.settings.feedback.types == 3)
    ordinal_feedback = feedback.getSyntheticLabel(alg,iteration);
else
    ordinal_feedback = [];
end

feedback.preference = preference_feedback;
feedback.coactive = coac_data;
feedback.ordinal = ordinal_feedback;

end

