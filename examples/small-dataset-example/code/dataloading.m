%% Data Loading File

% Author: Debora P.S.
% Date: 26 Nov 2024
% Version: 1.1
% MATLAB Version: 2024.b

% Clear the command window, workspace, and close all figures
clc;
clear;
close all;

%% Add Project Paths
% Define the project root and function paths
addProjectPaths();

%% Select or Create Dataset Structure

% Prompt the user to create or select the dataset JSON
disp('Step 1 - Data Loading started');
disp('Dataset Configuration');
disp('1. Create a new dataset-structure.json');
disp('2. Select an existing dataset-structure.json');
choice = input('Choose an option (1 or 2): ');

if choice == 1
    % Call the createDatasetJSON function
    jsonFilePath = createDatasetJSON();
elseif choice == 2
    % Use a file selection dialog to locate the JSON file
    [fileName, filePath] = uigetfile('*.json', 'Select Dataset Structure JSON');
    if isequal(fileName, 0)
        error('No file selected. Cannot proceed without a dataset structure.');
    end
    jsonFilePath = fullfile(filePath, fileName);
else
    error('Invalid choice. Please restart and select either 1 or 2.');
end

% altenative option without prompts(loading the WheelSimPhysio-2023 dataset-structure.jon):
  % jsonFilePath = fullfile(pwd, 'dataSetStructure_example.json');


%% Load Dataset Configuration
% Load the dataset structure from the JSON file
jsonData = jsondecode(fileread(jsonFilePath));
jsonData = checkAndLoadJsonData();
disp('Loaded experiment configuration:');
disp(jsonData);

%% Define Experiment and Results Paths from JSON

% Use the loaded JSON data to define experiment directories
experimentPaths = jsonData.experiments;
for i = 1:length(experimentPaths)
    fprintf('Experiment %d: %s\n', i, experimentPaths(i).name);
    % Display each experiment's directory
    disp(['Directory: ', experimentPaths(i).dir]);
end

% Check if results directory exists in JSON
if isfield(jsonData, 'resultsDir')
    resultsDir = jsonData.resultsDir;
    disp(['Results Directory: ', resultsDir]);
else
    error('No resultsDir field in JSON file.');
end

% Define processed tables directory
processedTablesDir = fullfile(resultsDir, 'processed-tables');
logsDir = fullfile(resultsDir, 'logs');
graphsDir = fullfile(resultsDir, 'graphs');

% Ensure processed-tables directory exists
if ~isfolder(processedTablesDir)
    mkdir(processedTablesDir);
    disp(['Created processed tables directory at: ', processedTablesDir]);
else
    disp(['Processed tables directory exists at: ', processedTablesDir]);
end

if ~isfolder(logsDir)
    mkdir(logsDir);
    disp(['Logs directory at: ', logsDir]);
else
    disp(['Logs directory exists at: ', logsDir]);
end

if ~isfolder(graphsDir)
    mkdir(graphsDir);
    disp(['Created graphs directory at: ', graphsDir]);
else
    disp(['Graphs directory exists at: ', graphsDir]);
end

%% Display Selected Directories
% Provide feedback on all defined directories
clc;
disp('---- Selected Paths ----');
disp(['Results Directory: ', resultsDir]);
disp(['Processed Tables Directory: ', processedTablesDir]);
disp('Experiment Paths:');
disp(jsonData.experiments);
disp('Step 1 - Data Loading is completed! ');
disp('-------------------------');