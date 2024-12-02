function addProjectPaths()
    % addProjectPaths Adds relevant project folders to the MATLAB search path.
    %
    % This function assumes a specific folder structure under the current
    % working directory and adds paths for functions related to the project.

    % Get the current project root (assumes this script is called from the root)
    projectRoot = pwd;

    % Define the paths for different function categories
    functionsPath = fullfile(projectRoot, 'functions');
    dataLoadingfunctionsPath = fullfile(functionsPath, 'DataLoadingFunctions');
    preprocessingfunctionsPath = fullfile(functionsPath, 'PreprocessingFunctions');
    processingfunctionsPath = fullfile(functionsPath, 'ProcessingFunctions');
    insightsAggregationfunctionsPath = fullfile(functionsPath, 'InsightsAggregationFunctions');
    dataVisualisationfunctionsPath = fullfile(functionsPath, 'DataVisualisationFunctions');
    violinFunctionPath = fullfile(functionsPath, 'violin');

    % Add paths to MATLAB search path
    addpath(functionsPath);
    addpath(dataLoadingfunctionsPath);
    addpath(preprocessingfunctionsPath);
    addpath(processingfunctionsPath);
    addpath(insightsAggregationfunctionsPath);
    addpath(dataVisualisationfunctionsPath);
    addpath(violinFunctionPath);

    % Display a message indicating that paths have been added
    disp('Project paths have been added to the MATLAB search path.');
end
