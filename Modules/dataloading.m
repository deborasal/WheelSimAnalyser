%% Data Loading File

% Author: Debora P.S.
% Date: 26 Nov 2024
% Version: 1.1
% MATLAB Version: 2024.b

% Clear the command window to remove any previous outputs
clc;
% Clear all variables from the workspace to avoid conflicts with existing variables
clear;
% Close all figure windows to start with a clean slate
close all;
    
% Define the path to the functions

% Get the full path to the current script
scriptPath = genpath('~/WheelSimAnalyser/SupportingFunctions/')

% Navigate up to the project root by going up three directory levels
projectRoot=genpath('~/WheelSimAnalyser/');

% Construct the path to the folder containing the required functions
% Adding the violin function path to the project
violinfunctionPath = fullfile(projectRoot,'violin');

% Add the functions folder to MATLAB's search path
addpath(projectRoot)
addpath(violinfunctionPath)