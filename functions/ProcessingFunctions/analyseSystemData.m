 % Function ANALYZESYSTEMDATA Processes and saves system data for a given participant based on the experiment type.
    %
    % INPUTS:
    %   systemData         - A structure containing system data for multiple participants and experiments.
    %                        It should include fields for each experiment and participant, with system data details.
    %   experiment         - A string specifying the experiment identifier within the system data structure.
    %   participant        - A string specifying the participant identifier within the experiment.
    %   processedTablesDir - A string specifying the directory path where processed system data will be saved.
    %
    % OUTPUTS:
    %   Saves a .mat file in the specified directory containing:
    %     - systemDataFeatures: Struct with participant ID, experiment ID, number of collisions, number of command changes,
    %                           total time, and the loaded system data table.
    %
    % FUNCTIONALITY:
    % 1. Retrieves the system data for the specified participant and experiment from the system data structure.
    % 2. Based on the experiment type, handles either a .txt or .xlsx file:
    %    - For 'experiment1': Reads metrics from a .txt file, extracts number of collisions, command changes, and total time.
    %    - For 'experiment2': Reads metrics from a .xlsx file, extracts number of collisions, command changes, and total time.
    % 3. Creates a structure to hold the system data features, including participant ID, experiment ID, and extracted metrics.
    % 4. Saves the processed system data and features into a .mat file in the specified directory.
    % 5. Displays debug messages indicating the processing steps, file paths, and results.
function analyseSystemData(systemData, experiment, participant, processedTablesDir)
    % Display message indicating the start of system data processing
    disp(['Processing system data for ', experiment, ' - ', participant]); % Debug statement
    
    % Retrieve participant data if it exists in the system data structure
    if isfield(systemData, makeValidFieldName(experiment)) && ...
       isfield(systemData.(makeValidFieldName(experiment)), makeValidFieldName(participant)) && ...
       isfield(systemData.(makeValidFieldName(experiment)).(makeValidFieldName(participant)), 'Unity')
   
        participantData = systemData.(makeValidFieldName(experiment)).(makeValidFieldName(participant)).Unity;
        
        % Define file paths based on experiment type
        if (strcmp(experiment, 'experiment-1-monitor') || strcmp(experiment, 'pilot-test'))
            % Handle .txt file
            txtFilePattern = '_PerformanceReport_txt';
            txtFilePath = getFilePath(participantData, txtFilePattern);
            if ~isempty(txtFilePath)
                disp(['Processing .txt file: ', txtFilePath]); % Debug statement
                if isfile(txtFilePath)
                    % Read the table, treating the first row as data
                    systemDataTable = readtable(txtFilePath, 'Delimiter', ' ', 'ReadVariableNames', false);
                else
                    disp(['File not found: ', txtFilePath]); % Debug statement
                    return;
                end
            else
                disp(['Performance report .txt file not found for ', experiment, ' - ', participant']); % Debug statement
                return;
            end
            
            % Extract the number of collisions and commands from the last three rows
            numCollisions = str2double(systemDataTable{end-1, 4}{1});
            numCommandChanges = str2double(systemDataTable{end, 4}{1});
            
            % Extract total time from the string at (end-2, 3)
            totalTimeStr = systemDataTable{end-2, 3}{1};
            totalTimeParts = regexp(totalTimeStr, '(\d+):(\d+)', 'tokens');
            totalTimeParts = totalTimeParts{1};
            totalMinutes = str2double(totalTimeParts{1});
            totalSeconds = str2double(totalTimeParts{2});
            totalTime = totalMinutes * 60 + totalSeconds;
            
            % Store extracted metrics in a structure
            systemDataFeatures = struct();
            systemDataFeatures.participantID = participant;
            systemDataFeatures.experimentID = experiment;
            systemDataFeatures.numCollisions = numCollisions;
            systemDataFeatures.numCommandChanges = numCommandChanges;
            systemDataFeatures.totalTime = totalTime;
            systemDataFeatures.data = systemDataTable;
            
            % Save the processed system data and features in a .mat file
            savePath = fullfile(processedTablesDir, sprintf('%s_%s_system_data.mat', experiment, participant));
            save(savePath, 'systemDataFeatures');
            

            
            disp(['Saved system data to: ', savePath]); % Debug statement

        elseif strcmp(experiment, 'experiment-2-vr')
            % Handle .xlsx file
            xlsxFileName = 'PerformanceReport_xlsx';
            xlsxFilePath = getFilePath(participantData, xlsxFileName);
            if ~isempty(xlsxFilePath)
                disp(['Processing .xlsx file: ', xlsxFilePath]); % Debug statement
                systemDataTable = readtable(xlsxFilePath, 'Sheet', 1, 'ReadVariableNames', true);
            else
                disp(['Performance report .xlsx file not found for ', experiment, ' - ', participant']); % Debug statement
                return;
            end
            
            % Process the system data table 
            % Extract metrics from the systemDataTable
            if ismember('event', systemDataTable.Properties.VariableNames) && ismember('time0', systemDataTable.Properties.VariableNames)
                % Convert the event column to a string array 
                if iscell(systemDataTable.event)
                    events = string(systemDataTable.event);
                elseif ischar(systemDataTable.event)
                    events = string({systemDataTable.event});
                else
                    events = string(systemDataTable.event);
                end
                
                % Extract metrics: Number of collisions and command changes
                collisionKeywords = {'Collision', 'Crash', 'Impact'}; % Replace with actual keywords for collisions
                numCollisions = sum(contains(events, collisionKeywords, 'IgnoreCase', true));
                
                % Change of Commands (Count how many times the event changes from one type to another)
                eventCategories = categorical(events);
                eventCodes = double(eventCategories);
                numCommandChanges = sum(diff(eventCodes) ~= 0); % Counts the number of changes in event types
                
                % Time Calculation
                totalTime = max(systemDataTable.time0) - min(systemDataTable.time0); % Total duration of the experiment
                
                % Store extracted metrics in a structure
                systemDataFeatures = struct();
                systemDataFeatures.participantID = participant;
                systemDataFeatures.experimentID = experiment;
                systemDataFeatures.numCollisions = numCollisions;
                systemDataFeatures.numCommandChanges = numCommandChanges;
                systemDataFeatures.totalTime = totalTime;
                systemDataFeatures.data = systemDataTable;
                
                % Save the processed system data and features in a .mat file
                savePath = fullfile(processedTablesDir, sprintf('%s_%s_system_data.mat', experiment, participant));
                save(savePath, 'systemDataFeatures');
                
                disp(['Saved system data to: ', savePath]); % Debug statement
            else
                disp('Required columns not found in data table'); % Debug statement
            end
        else
            % Handle unknown experiment types
            disp(['Unknown experiment type: ', experiment]); % Debug statement
            return;
        end
    else
        % If system data for the specified experiment or participant is not found
        disp(['System data not found for ', experiment, ' - ', participant]); % Debug statement
    end
end