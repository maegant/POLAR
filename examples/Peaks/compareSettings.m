
toolbox_addpath
example_name = '1D Function';
settings = loadExample(example_name);

n_choices = [2 3 4];
n_iters = 20;
n_runs = 10;

num_choices = length(n_choices);
believed_mean = zeros(num_choices,n_iters+1);
believed_std = believed_mean;
T_mean = zeros(num_choices,n_iters); T_std = T_mean;

for i = 1:num_choices
    believed_obj = zeros(n_runs,n_iters+1);
    T_temp = zeros(n_runs,n_iters);
    
    for n = 1:n_runs
        alg = PBL(settings);
        
        % change settings
        alg.settings.n = n_choices(i);
        
        for iter = 1:n_iters
            alg.getNewActions; % updates alg.current_actions
            feedback = getSyntheticPreference_max(alg, iter);
            
            tstart = tic;
            alg.addFeedback(feedback,[],[],iter);
            T_temp(n,iter) = toc(tstart);
            
        end
        temp = [alg.iteration(:).best];
        if ~isempty(alg.post_model.full)
            believed_obj(n,:) = [0; alg.post_model.full.mean([temp.globalInd])];
        elseif ~isempty(alg.post_model.visited)
            believed_obj(n,:) = [0; alg.post_model.visited.mean([temp.visitedInd])];
        elseif ~isempty(alg.post_model.subset)
            believed_obj(n,:) = [0; alg.post_model.subset.mean([temp.visitedInd])];
        else
            error('No posterior model')
        end
    end
    
    % get mean and std across results
    believed_mean(i,:) = mean(believed_obj,1);
    believed_std(i,:) = std(believed_obj,[],1);
    T_mean(i,:) = mean(T_temp,1);
    T_std(i,:) = std(T_temp,[],1);
    
    if alg.settings.useSubset
        legend_label{i} = sprintf('n = %i, dim reduction',n_choices(i));
    else 
        legend_label{i} = sprintf('n = %i, no reduction',n_choices(i));
    end
end

%% Plot time plot
figure(1); clf; hold on;
colors = parula(num_choices); pAx = [];
for i = 1:num_choices
    pAx(i) = plot(1:n_iters,T_mean(i,:),'color',colors(i,:),'LineWidth',2);
    
    fill([1:n_iters, fliplr(1:n_iters)], ...
        [T_mean(i,:) + T_std(i,:), ...
        fliplr(T_mean(i,:) - T_std(i,:))], ...
        colors(i,:),'FaceAlpha',0.2,'EdgeColor','none');
end
title('Computation Time');
xlabel('Iteration Number');
xlim([1,n_iters]);
ylabel('Time (s)');
legend(pAx, legend_label);

% save result
imageName = 'Compared_time.png';
print(['example/',example_name,'/',imageName],'-dpng')
%% plot compared objective values
figure(2);

trueMax = alg.settings.true_bestObjective;
pBest = plot(0:n_iters,ones(1,n_iters+1)*trueMax,'b--','LineWidth',2);

% plot learned best
hold on;
colors = parula(num_choices);
for i = 1:num_choices
    % Plot std
    fill([0:n_iters, fliplr(0:n_iters)], ...
        [believed_mean(i,:) + believed_std(i,:), ...
        fliplr(believed_mean(i,:) - believed_std(i,:))], ...
        colors(i,:),'FaceAlpha',0.2);
    
    % Plot mean
    pAx(i) = plot(0:n_iters,believed_mean(i,:),'color',colors(i,:),'LineWidth',2);
    
end
hold off;

% style
title(sprintf('Average Best Objective (%i runs)',n_runs))
xlabel('Iteration');
ylabel('Objective Value');
legend([pBest,pAx],[{'True Best'},legend_label],'Location','southeast')

% save result
imageName = 'Compared_n.png';
print(['example/',example_name,'/',imageName],'-dpng')