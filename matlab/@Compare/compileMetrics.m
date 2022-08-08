function compileMetrics(obj)
% Description: get mean and std metrics across all settings to compare and
%   all runs


% prepare empty structure which will get populated with array of all metrics
all_metrics = fields(obj.results);

for i = 1:length(all_metrics)
    obj.metrics.(all_metrics{i}).means = mean(obj.results.(all_metrics{i}),3);
    obj.metrics.(all_metrics{i}).stds  = std(obj.results.(all_metrics{i}),[],3);
end
            
end


