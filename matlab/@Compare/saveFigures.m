function saveFigures(obj)

imageLocation = fullfile(obj.settings{1}.save_folder,'figures');
if ~isfolder(imageLocation)
    mkdir(imageLocation);
end

all_metrics = fields(obj.metrics);
for i = 1:length(all_metrics)
    
    switch all_metrics{i}
        case 'optimal_error'
            imageName = 'compared_optimalerror.png';
        case 'inst_regret'
            imageName = 'compared_instregret.png';
        case 'fit_error'
            imageName = 'compared_fiterror.png';
        case 'label_error'
            imageName = 'compared_labelerror.png';
        case 'pref_error'
            imageName = 'compared_preferror.png';
        case 'post_update_time'
            imageName = 'compared_post_update_time.png';
        case 'acq_time'
            imageName = 'compared_acq_time.png';
            
    end
    
    saveas(obj.fhs(i), fullfile(imageLocation,imageName),'png');
end
 
% save object
compObj = obj;
save(fullfile(imageLocation,'savedComparisons.mat'),'compObj');

end

