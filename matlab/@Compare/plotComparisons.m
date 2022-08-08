function plotComparisons(obj)

%num iters
maxIter = obj.num_iters;

%% Plot all metrics
all_metrics = fields(obj.metrics);
num_comparisons = length(obj.setting_labels);
colors = parula(num_comparisons);
for i = 1:length(all_metrics)
    
    obj.fhs(i) = figure(i); clf; hold on; pAx = zeros(1,num_comparisons);
    curAx = gca(obj.fhs(i));
    
    for j = 1:num_comparisons
        result_means = obj.metrics.(all_metrics{i}).means(j,:);
        std_error = obj.metrics.(all_metrics{i}).stds(j,:)/(sqrt(obj.total_runs));
        
        fill([1:maxIter, fliplr(1:maxIter)], ...
            [result_means + std_error, ...
            fliplr(result_means - std_error)], ...
            colors(j,:),'FaceAlpha',0.2,'EdgeColor','none');
        
        pAx(j) = plot(result_means,'color',colors(j,:),'LineWidth',2);
        xlabel('Iteration');
    end
    hold off;
    
    %% Styling
    
    % x-axis limits
    xlim(curAx,[1,maxIter]);
    
    % Add title
    switch all_metrics{i}
        case 'optimal_error'
            ylabel(curAx,{'Optimal Action','Prediction Error'});
        case 'inst_regret'
            ylabel(curAx,{'Instantaneous Regret'});
        case 'fit_error'
            ylabel(curAx,{'Underlying Landscape','Fit Error'});
        case 'label_error'
            ylabel(curAx,{'Ordinal Label','Prediction Error'});
        case 'pref_error'
            ylabel(curAx,{'Preference','Prediction Error'});
        case 'post_update_time'
            ylabel(curAx,{'Post. Update Time(s)'});
        case 'acq_time'
            ylabel(curAx,{'Acquisition Time(s)'});
    end
    
    % Add legend
    l = legend(pAx,obj.setting_labels);
%     l.Location = 'northoutside';
%     l.NumColumns = 2;
    l.BoxFace.ColorType = 'truecoloralpha';
    l.BoxFace.ColorData = uint8(255*[1,1,1,0.5]');
    
end

latexify;
fontsize(20,'legend',14);

% Save Figures
obj.saveFigures;


