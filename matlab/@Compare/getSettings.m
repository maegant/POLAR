function getSettings(obj,default_settings,setting_struct)
% Description: use optional inputs to get all comparisons:

% Run default settings through algSetup to fill in default settings
temp_alg = PBL(default_settings);
default_settings = temp_alg.settings;

%% Get all combinations of parameters to compare:
all_params = fieldnames(setting_struct);
assert(length(all_params) == 1,'Currently only works for 1 parameter');

settings = cell(length(setting_struct.(all_params{1})),1);
setting_labels = cell(length(setting_struct.(all_params{1})),1);

for i = 1:length(setting_struct.(all_params{1}))
    new_settings = default_settings;
    switch all_params{1}
        case 'feedback_types'
            new_settings.feedback.types = setting_struct.(all_params{1}){i};
            
            switch num2str(setting_struct.(all_params{1}){i})
                case '1'
                    setting_labels{i} = 'pref only';
                case '2'
                    setting_labels{i} = 'coac only';
                case '3'
                    setting_labels{i} = 'ord only';
                case num2str([1,2])
                    setting_labels{i} = 'pref + coac';
                case num2str([1,3])
                    setting_labels{i} = 'pref + ord';
                case num2str([1,2,3])
                    setting_labels{i} = 'pref + coac + ord';
            end
                
        case 'post_pref_noise'
            new_settings.gp_settings.pref_noise = setting_struct.(all_params{1}){i};
            setting_labels{i} = sprintf('%s = %1.2f',all_params{1},setting_struct.(all_params{1}){i});
        case 'post_coac_noise'
            new_settings.gp_settings.coac_noise = setting_struct.(all_params{1}){i};
            setting_labels{i} = sprintf('%s = %1.2f',all_params{1},setting_struct.(all_params{1}){i});
        case 'post_ord_noise'
            new_settings.gp_settings.ord_noise = setting_struct.(all_params{1}){i};
            setting_labels{i} = sprintf('%s = %1.2f',all_params{1},setting_struct.(all_params{1}){i});
        case 'simulated_pref_noise'
            new_settings.simulation.simulated_pref_noise = setting_struct.(all_params{1}){i};
            setting_labels{i} = sprintf('%s = %1.2f',all_params{1},setting_struct.(all_params{1}){i});
        case 'simulated_coac_noise'
            new_settings.simulation.simulated_coac_noise = setting_struct.(all_params{1}){i};
            setting_labels{i} = sprintf('%s = %1.2f',all_params{1},setting_struct.(all_params{1}){i});
        case 'simulated_ord_noise'
            new_settings.simulation.simulated_ord_noise = setting_struct.(all_params{1}){i};
            setting_labels{i} = sprintf('%s = %1.2f',all_params{1},setting_struct.(all_params{1}){i});
        case 'n'
            new_settings.n = setting_struct.(all_params{1}){i};
            setting_labels{i} = sprintf('%s = %i',all_params{1},setting_struct.(all_params{1}){i});
        case 'b'
            new_settings.b = setting_struct.(all_params{1}){i};
            setting_labels{i} = sprintf('%s = %i',all_params{1},setting_struct.(all_params{1}){i});
        case 'lengthscales'
            if length(setting_struct.(all_params{1}){i}) == length(default_settings.parameters)
                for j = 1:length(default_settings.parameters)
                    new_settings.parameters(j).lengthscale = setting_struct.(all_params{1}){i}(j);
                end
            elseif length(setting_struct.(all_params{1}){i}) == 1
                for j = 1:length(default_settings.parameters)
                    new_settings.parameters(j).lengthscale = setting_struct.(all_params{1}){i};
                end
                warning('using same lengthscale for all parameters');
            else
                error('length of lengthscales must either be equal to number of parameters or 1');
            end
            strform = repmat('%1.2f ',1,length(setting_struct.(all_params{1}){i}));
            setting_labels{i} = sprintf(['l = ',strform],setting_struct.(all_params{1}){i});

    end
    settings{i} = new_settings;
end

% add to structure
obj.settings = settings;
obj.setting_labels = setting_labels;

end

