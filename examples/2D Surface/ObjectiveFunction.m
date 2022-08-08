function obj = ObjectiveFunction(settings,action)

actionIds = find(ismember(action,settings.allactions,'row'));
obj = settings.allobjectives(actionIds);

end
