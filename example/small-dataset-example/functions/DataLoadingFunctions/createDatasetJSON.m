function jsonFile = createDatasetJSON()
    % Prompt user for dataset and results directories
    fprintf('\n--- Dataset and Results Directories ---\n');
    datasetDir = input('Enter the dataset directory path: ', 's');
    if isempty(datasetDir)
        error('Dataset directory path cannot be empty.');
    end
    
    resultsDir = input('Enter the results directory path: ', 's');
    if isempty(resultsDir)
        error('Results directory path cannot be empty.');
    end
    
    % Initialize an empty experiments array
    experiments = [];
    
    % Ask the user for the number of experiments
    nExperiments = input('\nHow many experiments do you want to add? ');
    
    for i = 1:nExperiments
        fprintf('\n--- Experiment %d ---\n', i);
        
        % Get experiment details
        expName = input('Enter experiment name: ', 's');
        expDir = input('Enter experiment directory (relative to dataset directory): ', 's');
        
        % Get the number of groups in the experiment
        nGroups = input(sprintf('How many groups in experiment "%s"? ', expName));
        groups = [];
        
        for j = 1:nGroups
            fprintf('\n--- Group %d for Experiment "%s" ---\n', j, expName);
            
            % Get group details
            groupName = input('Enter group name: ', 's');
            % Ask for the group folder path (relative to the experiment directory)
            groupDir = input('Enter the group directory (relative to experiment directory): ', 's');
            participantCount = input('Enter participant count: ');
            idPattern = input('Enter ID pattern (e.g., "group-%d"): ', 's');
            
            
            % Add the group structure with the directory path
            groups = [groups; struct('name', groupName, ...
                                      'participantCount', participantCount, ...
                                      'idPattern', idPattern, ...
                                      'groupDir', fullfile(groupDir))];
        end
        
        % Add the experiment structure
        experiments = [experiments; struct('name', expName, ...
                                           'dir', fullfile(expDir), ...
                                           'groups', groups)];
    end
    
    % Create JSON-compatible structure
    jsonCompatible = struct('datasetDir', datasetDir, ...
                             'resultsDir', resultsDir, ...
                             'experiments', experiments);
    
    % Encode to JSON format
    jsonText = jsonencode(jsonCompatible, 'PrettyPrint', true);
    
    % Check if the file already exists in the results directory
    jsonFile = fullfile(resultsDir, 'dataset-structure.json');
    
    if exist(jsonFile, 'file') == 2
        % Ask user whether to replace the file or create a new one
        choice = menu('The file already exists. What would you like to do?', ...
                      'Replace the existing file', ...
                      'Save with a new name');
        if choice == 1
            % Replace the existing file
            fid = fopen(jsonFile, 'w');
            if fid == -1
                error('Cannot create JSON file in the specified results directory.');
            end
            fwrite(fid, jsonText, 'char');
            fclose(fid);
            disp(['File replaced: ', jsonFile]);
        elseif choice == 2
            % Save with a new name (incremental numbering)
            i = 1;
            newJsonFile = fullfile(resultsDir, sprintf('dataset-structure_%d.json', i));
            while exist(newJsonFile, 'file') == 2
                i = i + 1;
                newJsonFile = fullfile(resultsDir, sprintf('dataset-structure_%d.json', i));
            end
            fid = fopen(newJsonFile, 'w');
            if fid == -1
                error('Cannot create JSON file in the specified results directory.');
            end
            fwrite(fid, jsonText, 'char');
            fclose(fid);
            disp(['File saved as: ', newJsonFile]);
        end
    else
        % If the file doesn't exist, save it normally
        fid = fopen(jsonFile, 'w');
        if fid == -1
            error('Cannot create JSON file in the specified results directory.');
        end
        fwrite(fid, jsonText, 'char');
        fclose(fid);
        disp(['File created: ', jsonFile]);
    end
end
