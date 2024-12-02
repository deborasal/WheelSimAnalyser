% Function to process system data for each participant
%
% This function processes system data for a given participant by scanning specific subfolders
% within the 'system-data' directory. It calls the processDirectory function to handle 
% each subfolder and update the systemData structure with file paths.
%
% Inputs:
%   - participantFolder: The path to the participant's main folder.
%   - systemData: The structure where the system data paths will be stored.
%   - experiment: The name of the experiment being processed.
%   - participantId: The unique identifier for the participant.
%   - resultsDir: The directory where the log file should be saved.
%
% Outputs:
%   - systemData: The updated structure containing the paths of the processed system files.
function systemData = processSystemData(participantFolder, systemData, experiment, participantId, resultsDir)
    % Prepare log file path to save the log
    logFilePath = fullfile(resultsDir, 'logs/system_data_log.txt');
    
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

    % Define subfolders within the 'system-data' directory to process
    subfolders = {'Unity'};
    
    % Loop through each subfolder specified in the list
    for k = 1:numel(subfolders)
        % Construct the path to the current subfolder within 'system-data'
        subfolderPath = fullfile(participantFolder, 'system-data', subfolders{k});
        
        % Check if the current subfolder exists
        if isfolder(subfolderPath)
            % Log the found folder
            fprintf(fid, 'Found and Processing folder: %s\n', subfolderPath);
            
            % Call the processDirectory function to process the files in the subfolder
            % The field name for system data is set to the name of the subfolder
            systemData = processDirectory(subfolderPath, systemData, experiment, participantId, 'system-data', subfolders{k});
        else
            % Log the missing folder
            fprintf(fid, 'Missing folder: %s\n', subfolderPath);
        end
    end
    
    % Close the log file after processing the participant
    fclose(fid);

    % Return the updated system data structure
end
