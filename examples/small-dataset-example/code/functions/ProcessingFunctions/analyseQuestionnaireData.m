% Function ANALYSEQUESTIONNAIREDATA Processes and saves questionnaire data for a given participant.
    %
    % INPUTS:
    %   data               - A structure containing questionnaire data for multiple participants and experiments.
    %                        It should include fields for each experiment and participant, with questionnaire data details.
    %   experiment         - A string specifying the experiment identifier within the data structure.
    %   participant        - A string specifying the participant identifier within the experiment.
    %   processedTablesDir - A string specifying the directory path where processed questionnaire data will be saved.
    %
    % OUTPUTS:
    %   Saves a .mat file in the specified directory containing:
    %     - questionnaireFeatures: Struct with participant ID, experiment ID, and the loaded questionnaire data.
    %
    % FUNCTIONALITY:
    % 1. Retrieves the questionnaire data for the specified participant and experiment from the data structure.
    % 2. Checks for the presence of a specific questionnaire data file within the retrieved data.
    % 3. Loads the questionnaire data from the file, setting all variables as 'char'.
    % 4. Creates a structure to hold the questionnaire features, including participant ID, experiment ID, and data.
    % 5. Saves the questionnaire data and features into a .mat file in the specified directory.
    % 6. Displays debug messages indicating the processing steps and paths of the saved files.
function analyseQuestionnaireData(data, experiment, participant, processedTablesDir)
    % Display message indicating the start of questionnaire data processing
    disp(['Processing questionnaire data for ', experiment, ' - ', participant]); % Debug statement
    
     % Retrieve participant data if it exists in the data structure
    if isfield(data, makeValidFieldName(experiment)) && ...
       isfield(data.(makeValidFieldName(experiment)), makeValidFieldName(participant)) && ...
       isfield(data.(makeValidFieldName(experiment)).(makeValidFieldName(participant)), 'questionnaire_data')
   
        questionnaireData = data.(makeValidFieldName(experiment)).(makeValidFieldName(participant)).questionnaire_data;
        
         % Define the specific file name pattern for the questionnaire data
        targetFileName = sprintf('questionnaire-data-%s.csv', participant);
        targetFileNameField = makeValidFieldName(targetFileName);
        
        % Check if the specific file exists in the questionnaire data structure
        if isfield(questionnaireData, targetFileNameField)
            filePath = questionnaireData.(targetFileNameField);
            disp(['Processing questionnaire file: ', filePath]); % Debug statement
            
            % Load the questionnaire data from the file
            opts = detectImportOptions(filePath);
            varTypes = repmat({'char'}, 1, width(opts.VariableNames)); % Set all variables as 'char'
            opts.VariableTypes = varTypes;
            questionnaireTable = readtable(filePath, opts);
            
            % Display the loaded questionnaire table for verification
            disp('Loaded questionnaire table:');
            disp(questionnaireTable);
            
            % Create a structure to hold the questionnaire features
            questionnaireFeatures = struct();
            questionnaireFeatures.participantID = participant;
            questionnaireFeatures.experimentID = experiment;
            questionnaireFeatures.data = questionnaireTable;
            
            % Save the questionnaire data and experiment information to a .mat file
            savePath = fullfile(processedTablesDir, sprintf('%s_%s_questionnaire_data.mat', experiment, participant));
            save(savePath, 'questionnaireFeatures');
            
            disp(['Saved questionnaire data to: ', savePath]); % Debug statement
        else
            % If the specific questionnaire file is not found in the data structure
            disp(['Specific questionnaire file not found: ', targetFileName]); % Debug statement
        end
    else
        % If questionnaire data for the specified experiment or participant is not found
        disp(['Questionnaire data not found for ', experiment, ' - ', participant]); % Debug statement
    end
end