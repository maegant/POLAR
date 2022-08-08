function plotFrequency(obj)
figure(209); clf;

% get frequency of each dimension
h = heatmap(obj.sample_table,'action_bins','dim_values');
h.XDisplayData = num2cell(1:max(obj.settings.bin_sizes));
h.YDisplayLabels = {obj.settings.parameters(:).name};
h.YLabel = 'Dimension';
h.XLabel = 'Bin';
h.Title = 'Frequency of Sampled Actions';

drawnow

end
