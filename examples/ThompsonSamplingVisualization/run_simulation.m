%% Script: run_simulation
%
% Description: demonstrate POLAR toolbox on a 1D function through
% simulations
%
% Author: Maegan Tucker, mtucker@caltech.edu
% Date: August 9, 2021
%
% ________________________________________

%% Add POLAR toolbox:
addpath(fullfile('..','..','..','POLAR')); % add main polar folder to path
toolbox_addpath;

%% Setup Learning
% --------------------- General Settings ----------------------------------
settings = [];
settings.save_folder = 'saved_results';
settings.b = 0;
settings.n = 2;

settings.sampling.type = 2;
settings.useSubset = 0;

settings.feedback.types = [1,2,3];
settings.feedback.num_ord_categories = 5;

settings.roa.use_roa = 1;
settings.roa.ord_label_to_avoid = 1;
settings.roa.lambda = 0.1;

% -------------- Action Space Properties (need to be selected) ------------
settings.parameters(1).name = 'action';
settings.parameters(1).discretization = 0.05;
settings.parameters(1).lower = 0;
settings.parameters(1).upper = 4;
settings.parameters(1).lengthscale = 0.6;

% --------------------- Learning Hyperparameters --------------------------
settings.gp_settings.linkfunction = 'sigmoid';
settings.gp_settings.pref_noise = 0.02;    % How noisy are the user's preferences?
settings.gp_settings.coac_noise = 0.04;    % How noisy are the user's suggestions?
settings.gp_settings.ord_noise = 0.2;     % How noisy are the user's labels?
settings.gp_settings.GP_noise_var = 1e-5;       % GP model noise--need at least a very small
settings.gp_settings.signal_variance = 1;   % Gaussian process amplitude parameter

% --------------------- Simulation Settings ----------------------------------
settings.useSyntheticObjective = 1;
settings.simulation.simulated_pref_noise = 0; % percent likelihood of incorrect simulated pref
settings.simulation.simulated_coac_noise = 0; % percent likelihood of incorrect simulated suggestions
settings.simulation.simulated_ord_noise = 0; % percent likelihood of incorrect simulated ord labels

%% Run Regret Minimization and Plot Thompson Sampling
alg = PBL(settings); iter = 1; img_count = 1;
alg.settings.sampling.type = 1;

alg.settings.gp_settings.isNormalize = 0;

isPlotting = 1; isSave = 1; %flag options

f = figure(1); clf;
imageLocation = fullfile(alg.settings.save_folder,'AnimatedPlots');
% Check if dir exists
if ~isdir(imageLocation)
    mkdir(imageLocation);
end
ax = gca; actions = alg.settings.points_to_sample;

while iter <= alg.settings.maxIter
    
    % get new actions
    alg.getNewActions;
    
    % Get synthetic feedback
    if isempty(alg.settings.simulation.true_objectives)
        alg = PBL(alg.settings);
        error('Cannot find "ObjectiveFunction.m" within Example Folder or settings.useObjectiveFunction set to 0')
    else
        feedback = SyntheticFeedback(alg,iter);
    end
    
    % update posterior using feedback
    alg.addFeedback(feedback);
    
    % plot actual
    cla;
    plot(ax,alg.settings.simulation.true_objectives,'k','LineWidth',2); hold(ax,'on');
    
    % update plot before update
    if iter == 1
        temp_mean = zeros(size(alg.post_model(iter).mean));
        temp_sigma = inv(alg.post_model(iter).prior_cov_inv);
        temp_uncertainty = sqrt(diag(temp_sigma))*3;
        plotUpdate(ax,actions,temp_mean,temp_uncertainty);
    else
        temp_mean = alg.post_model(iter-1).mean;
        temp_uncertainty = alg.post_model(iter-1).uncertainty*3;
        plotUpdate(ax,actions,temp_mean,temp_uncertainty);
    end
    
    if img_count < 10
        imageName = sprintf('Img0%i',img_count);
    else
        imageName = sprintf('Img%i',img_count);
    end
    print(f,fullfile(imageLocation,imageName),'-dpng'); img_count = img_count + 1;
    
    % Add sampled reward function and actions
    if iter == 1
        sampledmean = zeros(length(alg.settings.points_to_sample),2);
        sampledActionIndices = alg.iteration(iter).samples.globalInds;
        addSamples(ax,alg,sampledmean,sampledActionIndices,zeros(length(alg.settings.points_to_sample),1));
    else
        sampledmean = alg.iteration(iter).samples.rewards;
        sampledActionIndices = alg.iteration(iter).samples.globalInds;
        addSamples(ax,alg,sampledmean,sampledActionIndices,alg.post_model(iter-1).mean);
    end
    
    if img_count < 10
        imageName = sprintf('Img0%i',img_count);
    else
        imageName = sprintf('Img%i',img_count);
    end
    print(f,fullfile(imageLocation,imageName),'-dpng'); img_count = img_count + 1;
    
    iter = iter + 1;
    
end

%% Plotting function
function plotUpdate(ax,actions,mean,uncertainty)

hold(ax,'on');


isNormalize = 0; %hard coded option to normalize posterior

if ~all(mean == 0) && isNormalize
    norm_mean = (mean-min(mean))/(max(mean)-min(mean));
    std_norm = uncertainty/(max(mean)-min(mean));
else
    norm_mean = mean;
    std_norm = uncertainty;
end

% plot mean and uncertainty
numpoints = reshape(1:size(actions,1),[],1);

fill([numpoints;flipud(numpoints)], ...
    [norm_mean+std_norm; flipud(norm_mean-std_norm)], ...
    'b','FaceAlpha',0.2,'EdgeColor','none');

leg1 = plot(ax,numpoints,norm_mean,'b','LineWidth',2);
legstr1 = 'Posterior Mean';

hold(ax,'off');

% formatting
xlabel(ax,'Actions');
% xticks(linspace(alg.settings.lower_bounds,alg.settings.upper_bounds,5));
% xticklabels(inspace(alg.settings.lower_bounds,alg.settings.upper_bounds,5));
xlim([1,length(actions)]);
ylabel(ax,'Posterior Mean');
ylim([-2,2]);
% legend_strings = {legstr1}%,legstr2,legstr3,legstr4,legstr5,legstr6,legstr7,legstr8};
% legend_strings = legend_strings(find(~cellfun(@isempty,legend_strings)));
% if ~isempty(leg4)
%     leg4 = leg4(1);
% end
% l = legend([leg1, leg2, leg3, leg4,leg5,leg6,leg7,leg8],legend_strings);
% l.Location = 'southeast';
latexify;
fontsize(20);
end

function addSamples(ax,alg,sampledmean,sampledActionIndices,post_mean)
isNormalize = 0; %hard coded!

hold(ax,'on');

% For each action:
for i = 1:size(sampledmean,2)
    
    if isNormalize
        current_sample = (sampledmean(:,i)-min(post_mean))/(max(post_mean)-min(post_mean));
    else
        current_sample = sampledmean(:,i);
    end
    
    % plot drawn sample
    plot(ax,current_sample,'b--');
    
    % plot sampled actions
    scatter(ax,sampledActionIndices(i),alg.settings.simulation.true_objectives(sampledActionIndices(i)),100,'ko','filled');
end

hold(ax,'off');
end

