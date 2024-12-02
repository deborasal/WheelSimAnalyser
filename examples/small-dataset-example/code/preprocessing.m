clc;
disp('Step 2 - Preprocessing started');
% Define the project root and function paths
addProjectPaths();
%% Initialize data structures for storing results
physiologicalData = struct();
questionnaireData = struct();
systemData = struct();

%% Check if Dataset Strucutre (jsonData) exists and is a structure
jsonData = checkAndLoadJsonData();
experiments = jsonData.experiments;
datasetDir=jsonData.datasetDir;
resultsDir=jsonData.resultsDir;
logsDir=fullfile(resultsDir,'logs');
%% Checking the dataset files

% Log file path (saving it in the Results directory)
logFilePath = fullfile(resultsDir, 'logs/experiment_summary_log.txt');


% Open log file for writing
fid = fopen(logFilePath, 'w');
if fid == -1
    error('Could not open log file for writing.');
end

% Write header
fprintf(fid, 'Experiment Summary Log\n');
fprintf(fid, '======================\n\n');

% Loop through each experiment in jsonData
for expIdx = 1:length(jsonData.experiments)
    experiment = jsonData.experiments(expIdx); % Access each experiment
    fprintf(fid, 'Experiment: %s\n', experiment.name);
    fprintf(fid, 'Directory: %s\n\n', experiment.dir);
    expDir = experiment.dir;
    groups = experiment.groups;

    % Loop through groups in the experiment
    for g = 1:length(groups)
        groupName = groups(g).name;
        participantCount = groups(g).participantCount;

        % Use defined ID pattern or fallback to incremental numeric pattern
        if isfield(groups(g), 'idPattern') && ~isempty(groups(g).idPattern)
            idPattern = groups(g).idPattern;
        else
            % Fallback pattern for participant IDs
            idPattern = '%d'; 
        end

        % Log group details
        fprintf(fid, '  Group: %s\n', groupName);
        fprintf(fid, '  Participant Count: %d\n', participantCount);
        fprintf(fid, '  ID Pattern: %s\n', idPattern);

        % Handle for each experiment group
        groupFolder = fullfile(expDir, groupName);
        fprintf(fid, '  Group Folder Path: %s\n\n', groupFolder);

        % Initialize counters for found and not found participant folders
        foundCount = 0;
        notFoundCount = 0;
        missingFolders = {};
        foundFolders = {};

        % Loop through participants in the group
        for i = 1:participantCount
            % Construct the participant ID based on the defined pattern
            participantId = sprintf(idPattern, i);

            % Construct the participant folder path
            participantFolder = fullfile(groupFolder, participantId);

            % Check if the folder exists
            if isfolder(participantFolder)
                foundCount = foundCount + 1;
                foundFolders{end+1} = participantFolder; % Add to found list
                % Log participant folder found
                fprintf(fid, '    Participant %d: %s\n      Folder exists.\n', i, participantFolder);

                % Process physiological data for the current participant
                physiologicalData = processPhysiologicalData(participantFolder, physiologicalData, experiment.name, participantId, resultsDir);

                % Process questionnaire data for the current participant
                questionnaireData = processQuestionnaireData(participantFolder, questionnaireData, experiment.name, participantId, resultsDir);

                % Process system data for the current participant
                systemData = processSystemData(participantFolder, systemData, experiment.name, participantId, resultsDir);
            else
                notFoundCount = notFoundCount + 1;
                missingFolders{end+1} = participantFolder; % Add to missing list
                % Log participant folder not found
                fprintf(fid, '    Participant %d: %s\n      Folder does NOT exist.\n', i, participantFolder);
            end
        end

        % Log summary for the group
        fprintf(fid, '  Group Summary: %d participants found, %d participants missing.\n', foundCount, notFoundCount);
        if foundCount > 0
            fprintf(fid, '    Found Participants:\n');
            for k = 1:length(foundFolders)
                fprintf(fid, '      %s\n', foundFolders{k});
            end
        end
        if notFoundCount > 0
            fprintf(fid, '    Missing Participants:\n');
            for k = 1:length(missingFolders)
                fprintf(fid, '      %s\n', missingFolders{k});
            end
        end
        fprintf(fid, '\n');
    end
    fprintf(fid, '\n');
end

% Close the log file
fclose(fid);
% % Save the combined tables into .MAT files
save(fullfile(logsDir, 'physiologicalData.mat'), 'physiologicalData');
save(fullfile(logsDir, 'questionnaireData.mat'), 'questionnaireData');
save(fullfile(logsDir, 'systemData.mat'), 'systemData');

%% Save the dataset condition in a log file
fprintf('Log file created: %s\n', logFilePath);
disp('Step 2 - Preprocessing is completed! ');
disp('-------------------------');