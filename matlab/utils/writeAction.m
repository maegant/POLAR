function [ ] = writeAction(action, iteration,export_path)

if ~isfolder(export_path)
    mkdir(export_path)
end

fileID = fopen(fullfile(export_path,['iteration_',num2str(iteration),'.yaml']), 'w');

% Write each action as comma separated vector
for i = 1:size(action,1)
    for j = 1:size(action,2)
        if j == 1
            fprintf(fileID, '[ %f, ', action(i,j));
        elseif j == size(action,2)
            fprintf(fileID, '%f]', action(i,j));
        else
            fprintf(fileID, '%f, ', action(i,j));
        end
    end
    fprintf(fileID, '\n');
end

fclose(fileID);