function f = plotFinal(obj, imageName)
% Plots the posterior mean

% Use plotting code in GP class:
f = obj.gp.plotGP;

latexify;
fontsize(22);

% Save if desired
if nargin == 2
    imageLocation = obj.settings.save_folder;
    
    % Check if dir exists
    if ~isfolder(imageLocation)
        mkdir(imageLocation);
    end
    print(f, fullfile(imageLocation,imageName),'-dpng');
end

end
