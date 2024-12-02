% Author: Debora P.S.
% Date: 26 Nov 2024
% Version: 2.0
% MATLAB Version: 2024.b

% Clear the command window, workspace, and close all figures
clc;
clear;
close all;

% Display the starting message
fprintf('Starting WheelSimAnalyser Pipeline...\n');

%% Step 1: Data Loading
% Load the data from the appropriate sources (CSV, Excel, etc.)
fprintf('Loading Data...\n');
run('dataloading.m');  % This will call the data loading script

%% Step 2: Preprocessing
% Clean and preprocess the loaded data
fprintf('Preprocessing Data...\n');
run('preprocessing.m');  % This will call the preprocessing script

%% Step 3: Processing
% Process the data for further analysis
fprintf('Processing Data...\n');
run('processing.m');  % This will call the processing script

%% Step 4: Insights Aggregation
% Aggregate insights or metrics from the processed data
fprintf('Aggregating Insights...\n');
run('insightsaggregation.m');  % This will call the insights aggregation script

%% Step 5: Data Visualisation
% Generate visualisations based on the aggregated insights
fprintf('Visualising Data...\n');
run('datavisualisation.m');  % This will call the data visualization script

% Display the completion message
fprintf('Pipeline Complete.\n');
