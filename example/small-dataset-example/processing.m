%% Processing
clc;
disp('Step 3 - Processing started');
% Define the project root and function paths
addProjectPaths();
%% Check if Dataset Strucutre (jsonData) exists and is a structure
jsonData = checkAndLoadJsonData();

%% Extracting Experiment Information
% Assuming jsonData contains 'experiments' field that holds the experiment details
 % This should be a list of experiments and their details
experiments = jsonData.experiments;
datasetDir=jsonData.datasetDir;
resultsDir=jsonData.resultsDir;
logsDir=fullfile(resultsDir,'logs');
processedTablesDir=fullfile(resultsDir,'processed-tables');

load(fullfile(logsDir,'physiologicalData.mat'));
load(fullfile(logsDir,'questionnaireData.mat'));
load(fullfile(logsDir,'systemData.mat'));



% Display a message indicating the start of analysis
disp('Starting data analysis...');

%% Loop through each experiment
for expIdx = 1:length(experiments)
    % Extract the experiment name and groups
    experimentName = experiments(expIdx).name;
    groups = experiments(expIdx).groups;
    experimentDir = experiments(expIdx).dir;

    % Loop through each group in the current experiment
    for g = 1:length(groups)
        groupName = groups(g).name;
        participantCount = groups(g).participantCount;
        idPattern = groups(g).idPattern;

        % Log message for the current group
        disp(['Analyzing group: ', groupName, ' (', num2str(participantCount), ' participants)']);
        
        % Loop through each participant in the group
        for i = 1:participantCount
            % Construct the participant ID based on the defined pattern
            participantId = sprintf(idPattern, i);
            disp(['Analyzing participant: ', participantId]); % Debug statement
            
            % Construct participant folder path
            participantFolder = fullfile(experimentDir, groupName, participantId);
            
            % Check if participant folder exists
            if isfolder(participantFolder)
                % Analyze physiological data for the current participant          
                analysePhysiologicalData(physiologicalData, experimentName, participantId, processedTablesDir);

                % Analyze questionnaire data for the current participant
                analyzeQuestionnaireData(questionnaireData, experimentName, participantId, processedTablesDir);
                
                % Analyze system data for the current participant
                analyzeSystemData(systemData, experimentName, participantId, processedTablesDir);
            else
                % If participant folder does not exist, log it
                disp(['Participant folder does not exist for: ', participantId]);
            end
        end
    end
end
