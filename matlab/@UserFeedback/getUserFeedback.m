function feedback = getUserFeedback(feedback,alg,iteration)

% Queries the user for feedback

% print feedback:
feedback.printActionInformation(alg, iteration);

% Get preferences
if any(alg.settings.feedback.types == 1)
    pref_feedback = feedback.getUserPreference(alg,iteration);
else
    pref_feedback = [];
end

% Get user suggestions
if any(alg.settings.feedback.types == 2)
    coac_data = feedback.getUserSuggestion(alg,iteration);
else
    coac_data = [];
end

% Get user labels
if any(alg.settings.feedback.types == 3)
    ordinal_feedback = feedback.getUserLabel(alg,iteration);
else
    ordinal_feedback = [];
end

feedback.preference = pref_feedback;
feedback.coactive = coac_data;
feedback.ordinal = ordinal_feedback;


end

