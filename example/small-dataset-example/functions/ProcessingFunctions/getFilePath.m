% Helper function to get the file path matching a pattern
% This function searches for a file name in the participantData structure 
% that matches the provided pattern and returns the corresponding file path.
function filePath = getFilePath(participantData, filePattern)
    % Get all field names from the participantData structure
    fileNames = fieldnames(participantData);
    % Initialize the filePath as an empty string
    filePath = '';
    % Loop through each field name
    for i = 1:numel(fileNames)
        % Check if the current field name contains the specified pattern
        if contains(fileNames{i}, filePattern)
            % If a match is found, set filePath to the corresponding value and exit loop
            filePath = participantData.(fileNames{i});
            break;
        end
    end
end