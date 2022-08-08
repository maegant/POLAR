function runPBL(obj)

%  run PBL for all new runs
for i = 1:length(obj.settings)
    
    for j = 1:obj.new_runs
        
        obj.settings{i}.maxIter = obj.num_iters;
        obj.settings{i}.printInfo = false;
        
        fprintf('Running simulation %i of parameter set %i \n',j, i);
        alg = PBL(obj.settings{i}); 
        alg.runSimulation(0,0);
%         obj.results{i,j} = alg;
        
        % compile metrics:
        all_metrics = fields(alg.metrics);
%         c = cell(length(all_metrics),1);
%         temp_all = cell2struct(c,all_metrics);
        
        %  Get vector array of metrics for current run
        temp_metrics = [];
        for m = 1:length(all_metrics)
            if ~isfield(temp_metrics,all_metrics{m})
                temp_metrics.(all_metrics{m}) = [alg.metrics.(all_metrics{m})];
            else
                temp_metrics.(all_metrics{m}) = cat(1,temp_metrics.(all_metrics{m}),[alg.metrics.(all_metrics{m})]);
            end
        end
        
        % append vector array to list of all metric runs
        for m = 1:length(all_metrics)
            if ~isfield(obj.results,all_metrics{m})
                obj.results.(all_metrics{m}) = temp_metrics.(all_metrics{m});
            else
                obj.results.(all_metrics{m})(i,:,obj.total_runs+j) = temp_metrics.(all_metrics{m});
            end
        end
    end
end

%% update total number of runs
obj.total_runs = obj.total_runs + obj.new_runs;

end

