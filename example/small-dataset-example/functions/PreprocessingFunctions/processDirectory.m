% Function to recursively process files in a directory and save their paths to a structure
%
% This function scans a directory for files, processes each file based on its extension,
% and saves the file paths to a nested structure. It also recursively processes subdirectories.
%
% Inputs:
%   - directoryPath: The path to the directory to be processed.
%   - data: The structure where the file paths will be stored.
%   - experiment: The name of the experiment for organizing data.
%   - participantId: The unique identifier for the participant.
%   - dataType: The type of data being processed (used for organizing).
%   - dataTypeField: The specific field within the dataType for storing file paths (can be empty).
%
% Outputs:
%   - data: The updated structure containing the paths of the processed files.
function data = processDirectory(directoryPath, data, experiment, participantId, dataType, dataTypeField)
    % Get all items (files and directories) in the specified directory
    items = dir(fullfile(directoryPath, '*'));
    % Filter out directories, keeping only files
    items = items(~[items.isdir]);

    % Convert experiment and participant ID to valid field names for the structure
    experimentField = makeValidFieldName(experiment);
    participantField = makeValidFieldName(participantId);

    % Initialize the structure fields if they do not exist
    if ~isfield(data, experimentField)
        data.(experimentField) = struct();
    end
    if ~isfield(data.(experimentField), participantField)
        data.(experimentField).(participantField) = struct();
    end
    
    % Handle the case where dataTypeField is empty (e.g., for questionnaire-data)
    if isempty(dataTypeField)
        dataTypeField = makeValidFieldName(dataType);
    end
    
    % Initialize the dataTypeField if it does not exist
    if ~isfield(data.(experimentField).(participantField), dataTypeField)
        data.(experimentField).(participantField).(dataTypeField) = struct();
    end
    
    % Loop through each item in the directory
    for k = 1:numel(items)
        % Get the full path to the current file
        filePath = fullfile(directoryPath, items(k).name);
        %disp(['Found file: ', filePath]);

        % Convert the file name to a valid field name
        fileFieldName = makeValidFieldName(items(k).name);
        
        % Get the file extension
        [~, ~, ext] = fileparts(items(k).name);
        
        % Process the file based on its extension
        switch ext
            case '.csv'
                % For CSV files, save the file path to the structure
                data.(experimentField).(participantField).(dataTypeField).(fileFieldName) = filePath;
               % disp(['Saved file path for CSV file: ', items(k).name]);
            case '.xdf'
                % For XDF files, save the file path to the structure
               % disp(['Processing XDF file: ', items(k).name]);
                data.(experimentField).(participantField).(dataTypeField).(fileFieldName) = filePath;
            case '.txt'
                % For TXT files, save the file path to the structure
              %  disp(['Processing .txt file: ', items(k).name]);
                data.(experimentField).(participantField).(dataTypeField).(fileFieldName) = filePath;
            case '.xlsx'
               % For XLSX files, save the file path to the structure
             %  disp(['Processing .xlsx file: ', items(k).name]);
               data.(experimentField).(participantField).(dataTypeField).(fileFieldName) = filePath;
        end
    end

    % Get all subdirectories in the current directory
    subdirs = dir(fullfile(directoryPath, '*'));
    subdirs = subdirs([subdirs.isdir] & ~ismember({subdirs.name}, {'.', '..'}));

    % Recursively process each subdirectory
    for k = 1:numel(subdirs)
        % Get the full path to the subdirectory
        subdirPath = fullfile(directoryPath, subdirs(k).name);
        disp(['Entering directory: ', subdirPath]);
        % Recursive call to processDirectory for the subdirectory
        data = processDirectory(subdirPath, data, experiment, participantId, dataType, subdirs(k).name);
    end
end