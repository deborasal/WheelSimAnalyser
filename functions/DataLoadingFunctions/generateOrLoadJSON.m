function generateOrLoadJSON()
    % Ask the user whether to create a new JSON or select an existing one
    choice = menu('Choose an option:', ...
                  '1 - Create a new dataset-structure.json', ...
                  '2 - Load an existing dataset-structure JSON file');
    
    if choice == 1
        % Create a new dataset structure
        jsonFile = createDatasetJSON();
        
        % Load the newly created JSON file automatically
        disp('Loading the newly created JSON file...');
        loadJSONData(jsonFile);  % Call function to load and display the JSON content
        
    elseif choice == 2
        % Load an existing JSON file
        [file, path] = uigetfile('*.json', 'Select a dataset-structure.json file');
        if isequal(file, 0)
            disp('No file selected. Exiting.');
            return;
        end
        jsonFile = fullfile(path, file);
        disp(['Loaded JSON file: ', jsonFile]);
        
        % Load and display the selected JSON file
        loadJSONData(jsonFile);
    else
        disp('No option selected. Exiting.');
        return;
    end
    
    % Display the JSON file path
    disp(['JSON file ready: ', jsonFile]);
end

function loadJSONData(jsonFile)
    % Check if the file exists
    if exist(jsonFile, 'file') == 2
        % Load and display the content of the JSON file
        jsonText = fileread(jsonFile);
        jsonData = jsondecode(jsonText);
        
        % Optionally, display parts of the JSON data (for verification)
        disp('--- JSON Content ---');
        disp(jsonData);  % This can be customized based on the structure
        
        % Additional functionality: you can process or display more specific parts of the JSON here
        % For example, if you want to display the dataset directory:
        disp(['Dataset Directory: ', jsonData.datasetDir]);
        disp(['Results Directory: ', jsonData.resultsDir]);
        disp('Experiments and Groups:');
        disp(jsonData.experiments);
    else
        disp('The specified JSON file does not exist.');
    end
end
