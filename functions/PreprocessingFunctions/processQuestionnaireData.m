% Function to process questionnaire data for each participant
%
% This function processes the questionnaire data for a given participant by calling the 
% processDirectory function. It looks for the 'questionnaire-data' subfolder within 
% the participant's folder and updates the questionnaireData structure with paths to 
% relevant files.
%
% Inputs:
%   - participantFolder: The path to the participant's main folder.
%   - questionnaireData: The structure where the questionnaire data paths will be stored.
%   - experiment: The name of the experiment being processed.
%   - participantId: The unique identifier for the participant.
%   - resultsDir: The directory where the log file should be saved.
%
% Outputs:
%   - questionnaireData: The updated structure containing the paths of the processed 
%     questionnaire files.
function questionnaireData = processQuestionnaireData(participantFolder, questionnaireData, experiment, participantId, resultsDir)
    % Prepare log file path to save the log
    logFilePath = fullfile(resultsDir, 'logs/questionnaire_data_log.txt');
    
    % Open the log file for writing (append mode)
    fid = fopen(logFilePath, 'a');
    if fid == -1
        error('Could not open log file for writing.');
    end

    % Write header for new participant in log
    fprintf(fid, '\nProcessing Participant: %s\n', participantId);
    fprintf(fid, 'Experiment: %s\n', experiment);
    fprintf(fid, 'Participant Folder: %s\n', participantFolder);
    fprintf(fid, '-------------------------------------------------\n');

    % Construct the path to the 'questionnaire-data' subfolder within the participant's folder
    questionnaireFolderPath = fullfile(participantFolder, 'questionnaire-data');
    
    % Check if the 'questionnaire-data' subfolder exists
    if isfolder(questionnaireFolderPath)
        % Log the found questionnaire folder
        fprintf(fid, 'Found and Processing folder: %s\n', questionnaireFolderPath);
        
        % Call the processDirectory function to process the files in the 'questionnaire-data' subfolder
        questionnaireData = processDirectory(questionnaireFolderPath, questionnaireData, experiment, participantId, 'questionnaire-data', '');
    else
        % Log missing questionnaire folder
        fprintf(fid, 'Missing folder: %s\n', questionnaireFolderPath);
    end
    
    % Close the log file after processing the participant
    fclose(fid);
    
    % Return the updated questionnaire data structure
end
