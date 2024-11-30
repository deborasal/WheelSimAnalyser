function jsonData = checkAndLoadJsonData()
    % checkAndLoadJsonData checks if jsonData exists in the base workspace and is valid.
    %
    % If jsonData does not exist or is invalid, the function will prompt
    % the user to select a JSON file, then load and validate its contents.
    %
    % Outputs:
    %   - jsonData: Loaded JSON data as a MATLAB structure.

    % Check if jsonData exists in the base workspace
    if evalin('base', 'exist(''jsonData'', ''var'')')
        % Retrieve jsonData from the base workspace
        jsonData = evalin('base', 'jsonData');
    else
        jsonData = [];
    end

    % Validate or load jsonData
    if isempty(jsonData) || ~isstruct(jsonData)
        disp('The dataset structure was not found, please select Dataset Structure in JSON format.');
        % Use a file selection dialog to locate the JSON file
        [fileName, filePath] = uigetfile('*.json', 'Select Dataset Structure JSON');
        if isequal(fileName, 0)
            error('No file selected. Cannot proceed without a dataset structure.');
        end
        % Construct the full path to the JSON file
        jsonFilePath = fullfile(filePath, fileName);
        % Attempt to load and decode the JSON file
        try
            jsonData = jsondecode(fileread(jsonFilePath));
            disp('Loaded experiment configuration:');
            disp(jsonData);
            % Save jsonData back to the base workspace
            assignin('base', 'jsonData', jsonData);
        catch ME
            % Handle JSON decoding errors
            error('Failed to load JSON file. Ensure the file is in the correct format.\nError message: %s', ME.message);
        end
    else
        disp('jsonData is valid and ready to use.');
    end
end
