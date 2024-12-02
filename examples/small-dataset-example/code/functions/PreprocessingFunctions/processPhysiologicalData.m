% Function to process physiological data for each participant
% This function iterates through specific subfolders within the participant's data directory
% and processes each one by calling the processDirectory function.
%
% Inputs:
%   - participantFolder: The path to the participant's main data folder.
%   - physiologicalData: The structure to store the processed physiological data.
%   - experiment: The name of the experiment being processed.
%   - participantId: The unique identifier for the participant.
%
% Outputs:
%   - physiologicalData: The updated structure containing processed data.
function physiologicalData = processPhysiologicalData(participantFolder, physiologicalData, experiment, participantId, resultsDir)
    % List of subfolders to process within the 'physiological-data' directory
    subfolders = {'e4', 'LSL', 'OpenFace', 'OpenVibe'};
    
    
    % Prepare log file path to save the log
    pysioLogFilePath = fullfile(resultsDir, 'logs/physiological_data_log.txt');

    
    % Open the log file for writing (append mode)
    fid = fopen(pysioLogFilePath, 'a');
    if fid == -1
        error('Could not open log file for writing.');
    end

    % Write header for new participant in log
    fprintf(fid, '\nProcessing Participant: %s\n', participantId);
    fprintf(fid, 'Experiment: %s\n', experiment);
    fprintf(fid, 'Participant Folder: %s\n', participantFolder);
    fprintf(fid, '-------------------------------------------------\n');

    % Loop through each subfolder specified in the list
    for k = 1:numel(subfolders)
        % Construct the full path to the current subfolder
        subfolderPath = fullfile(participantFolder, 'physiological-data', subfolders{k});
        
        % Check if the current subfolder exists
        if isfolder(subfolderPath)
            % Log the found subfolder in the log file
            fprintf(fid, 'Found and Processing folder: %s\n', subfolderPath);
            
            % Call the processDirectory function to process the files in the subfolder
            % This function will update the physiologicalData structure with paths and details
            physiologicalData = processDirectory(subfolderPath, physiologicalData, experiment, participantId, 'physiological-data', subfolders{k});
        else
            % Log missing subfolder
            fprintf(fid, 'Missing folder: %s\n', subfolderPath);
        end
    end
    
    % Close the log file after processing the participant
    fclose(fid);
    
    % Return the updated physiological data structure
end
