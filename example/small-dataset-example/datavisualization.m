%% 5.1 Plotting the descriptive information for Physiolgical Data:
clc;
disp('Step 5 - Data Visualization Started');
disp('Loading aggregated data...');

% Add Project Paths
% Define the project root and function paths
addProjectPaths();

%% Check if Dataset Strucutre (jsonData) exists and is a structure
jsonData = checkAndLoadJsonData();

% Load the combined dataset for analysis
experiments = jsonData.experiments;
datasetDir=jsonData.datasetDir;
resultsDir=jsonData.resultsDir;
processedTablesDir=fullfile(resultsDir,'processed-tables');
logsDir=fullfile(resultsDir,'logs');
graphsDir=fullfile(resultsDir,'graphs');

load(fullfile(resultsDir,'processed-tables/allData.mat'));
load(fullfile(resultsDir,'processed-tables/allPhysiologicalFeatures.mat'));
load(fullfile(resultsDir,'processed-tables/allSystemData.mat'));
load(fullfile(resultsDir,'processed-tables/allQuestionnaireData.mat'));

% Ensure that data exists for visualization
if isempty(allPhysiologicalFeatures) || isempty(allQuestionnaireData) || isempty(allSystemData)
    error('Required data tables are empty. Visualization cannot proceed.');
end


%%
% Define target column names
targetColumnNames = {'IBI_meanIBI', 'IBI_sdnn', 'IBI_rmssd', 'IBI_nn50', 'IBI_pnn50', ...
                     'HR_meanHR', 'HR_maxHR', 'HR_minHR', 'HR_hrRange', 'HR_sdHR', ...
                     'EDA_meanSCRAmplitude', 'EDA_scrCount', 'EDA_meanSCL', 'EDA_meanSCRRiseTime', 'EDA_meanSCRRecoveryTime', ...
                     'EDA_F0SC', 'EDA_F1SC', 'EDA_F2SC', 'EDA_F3SC', 'EDA_meanFirstDerivative', 'EDA_meanSecondDerivative', ...
                     'Participant', 'Experiment', 'Period'}; 
% Extract numerical columns
numericalCols = targetColumnNames(~ismember(targetColumnNames, {'Participant', 'Experiment', 'Period'}));
%%
% Separate data based on experiment
experimentNames = unique(allPhysiologicalFeatures.Experiment);
T_experiment = cell(length(experimentNames), 1);

% Separate data by experiment
for exp_idx = 1:length(experimentNames)
    % Use strcmp to match experiment names
    T_experiment{exp_idx} = allPhysiologicalFeatures(strcmp(allPhysiologicalFeatures.Experiment, experimentNames{exp_idx}), :);
end

% Initialize results table
resultsTable = table();

% Loop through each numerical column
for i = 1:numel(numericalCols)
    metric = numericalCols{i};
    metricStrFormatted = strrep(metric, '_', ' ');  % Replace underscores with spaces

    % Combine data for all experiments
    combinedData = [];
    combinedExperiment = [];
    combinedMetricsType = [];

    for exp_idx = 1:length(T_experiment)
        if ismember(metric, T_experiment{exp_idx}.Properties.VariableNames)
            combinedData = [combinedData; T_experiment{exp_idx}.(metric)];
            combinedExperiment = [combinedExperiment; repmat(string(experimentNames(exp_idx)), height(T_experiment{exp_idx}), 1)];
            combinedMetricsType = [combinedMetricsType; T_experiment{exp_idx}.Period];
        end
    end

    % Create table for plotting
    plotData = table(combinedData, combinedExperiment, combinedMetricsType, ...
        'VariableNames', {'Value', 'Experiment', 'Period'});
    plotData = plotData(~isnan(plotData.Value), :); % Remove NaN values

    % Create a figure for the current metric
    figure;
    set(gcf, 'Position', [100, 100, 1800, 1200]);

    % Subplot 1: Box Plot
    subplot(2, 1, 1);
    boxplot(plotData.Value, {plotData.Experiment, plotData.Period}, 'LabelOrientation', 'inline');
    title(['Box Plot - ', upper(metricStrFormatted)], 'FontWeight', 'bold');
    ylabel('Value');
    xlabel('Experiment and Metrics Type');

    % Subplot 2: Histogram
    subplot(2, 1, 2);
    hold on;
    for exp_idx = 1:length(T_experiment)
        histogram(T_experiment{exp_idx}.(metric), 'FaceAlpha', 0.5, ...
            'DisplayName', experimentNames{exp_idx});
    end
    hold off;
    title(['Histogram - ', upper(metricStrFormatted)], 'FontWeight', 'bold');
    ylabel('Frequency');
    xlabel(metricStrFormatted);
    legend show;

   

    % Save figure
    saveas(gcf, fullfile(graphsDir, sprintf('Descriptive_Plots_%s.png', metricStrFormatted)));

    % Compute descriptive statistics and append to results table
    stats = grpstats(plotData, {'Experiment', 'Period'}, {'mean', 'median', 'std', 'numel'}, ...
        'DataVars', 'Value');
    stats.Metric = repmat({metric}, height(stats), 1);
    % resultsTable = [resultsTable, stats];
  
   
   resultTables = unique([resultsTable; stats], 'rows');


end

% Save the descriptive statistics table
statsPath = fullfile(processedTablesDir, 'descriptiveStats.xlsx');
writetable(resultsTable, statsPath);

%% 5.2 Plotting Questionnaire and System (Performance) Data:
% Load the data into MATLAB (assuming you have the data in a CSV file or MATLAB table)
data = allTables;

% Convert relevant columns to numeric types if they are not already
data.valence = str2double(data.valence);
data.arousal = str2double(data.arousal);
data.dominance = str2double(data.dominance);
data.immersion_total = str2double(data.immersion_total);
data.usability_total = str2double(data.usability_total);
data.nasa_weighted = str2double(data.nasa_weighted);

% Ensure Experiment is a string type (if it’s not numeric)
if iscell(data.Experiment)
    data.Experiment = string(data.Experiment);
end

% Extract unique experiment IDs
experimentIDs = unique(data.Experiment);

% Define colors for different experiments
colors = lines(length(experimentIDs)); % Generate distinct colors

% Metric groups and their titles
metricGroups = {
    {'numCollisions', 'numCommandChanges', 'totalTime'}, ...
    {'valence', 'arousal', 'dominance'}, ...
    {'immersion_total', 'usability_total', 'nasa_weighted'}
};
titlesGroups = {
    {'Number of Collisions', 'Number of Command Changes', 'Total Time (seconds)'}, ...
    {'Valence', 'Arousal', 'Dominance'}, ...
    {'Immersion', 'Usability', 'Cognitive Task Load'}
};
figureNames = {'Performance Metrics', 'Emotional Metrics', 'Other Metrics'};

% Define plot types
plotTypes = {'histogram', 'bar', 'line'};

% Loop through each group of metrics
for g = 1:length(metricGroups)
    metrics = metricGroups{g};
    titles = titlesGroups{g};
    
    % Create a figure for the current group
    figure('Name', figureNames{g}, 'NumberTitle', 'off');
    
    % Calculate the number of subplots needed
    numMetrics = length(metrics);
    numTypes = length(plotTypes);
    numSubplots = numMetrics * numTypes;
    
    % Determine the layout for subplots (e.g., 3x3 grid for 9 subplots)
    numRows = ceil(numSubplots / numTypes);
    numCols = numTypes;
    
    % Initialize subplot index
    plotIndex = 1;
    
    % Loop through each metric to create subplots
    for j = 1:length(metrics)
        % Create subplots for each plot type
        for p = 1:length(plotTypes)
            subplot(numRows, numCols, plotIndex);
            hold on;
            
            % Loop through each experiment and plot data
            for i = 1:length(experimentIDs)
                expID = experimentIDs(i);
                
                % Filter data for the current experiment
                expData = data(data.Experiment == expID, :);
                
                % Get the metric data
                metricData = expData.(metrics{j});
                validData = metricData(~isnan(metricData)); % Remove NaNs
                
                switch plotTypes{p}
                    case 'histogram'
                        histogram(validData, 'FaceColor', colors(i,:), 'DisplayName', char(expID), 'FaceAlpha', 0.5);
                        ylabel('Frequency');
                    case 'bar'
                        % Compute means for bar chart
                        meanValue = mean(validData, 'omitnan');
                        bar(i, meanValue, 'FaceColor', colors(i,:), 'DisplayName', char(expID));
                        ylabel('Mean Value');
                        % Set x-ticks for clarity
                        set(gca, 'XTick', 1:length(experimentIDs), 'XTickLabel', experimentIDs);
                    case 'line'
                        % Plot line plot
                        plot(validData, 'Color', colors(i,:), 'DisplayName', char(expID), 'LineWidth', 1.5);
                        ylabel('Value');
                        xlabel('Observation Index');
                end
            end
            
            % Add title and legend
            title(titles{j});
            
            if strcmp(plotTypes{p}, 'line')
                % Add legend for line plot
                legend('show', 'Location', 'best');
                
            end
            
            hold off;
            
            plotIndex = plotIndex + 1;
        end
    end
    
    % Adjust layout manually to avoid overlap
    set(gcf, 'Position', [100, 100, 1800, 1200]); % Increase figure size for better spacing
    
    % Save the figure as an image file
    saveas(gcf, fullfile(graphsDir, [figureNames{g}, '_comprehensive_plots.png']));
end
disp('Step 5 - Data Visualization step is complete!');