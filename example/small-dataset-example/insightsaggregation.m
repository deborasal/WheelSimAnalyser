% %% 4. DATA INSIGHTS AGGREGATION: Compile all the features into tables in .mat and .xlsx
clc;
disp('Step 4 - Insights Aggregation Started');
% Define the project root and function paths
addProjectPaths();
%% Check if Dataset Strucutre (jsonData) exists and is a structure
jsonData = checkAndLoadJsonData();

%% Extracting Experiment Information
% Assuming jsonData contains 'experiments' field that holds the experiment details
experiments = jsonData.experiments; % This should be a list of experiments and their details
datasetDir=jsonData.datasetDir;
resultsDir=jsonData.resultsDir;
processedTablesDir=fullfile(resultsDir,'processed-tables');
logsDir=fullfile(resultsDir,'logs');


% Initialize tables to hold features for all participants
allTestFeatures = table();
allBaselineFeatures = table();
allDifferenceFeatures = table();
allQuestionnaireData = table();
allSystemData = table();

% Extract features from processed tables for each experiment
   % Loop over experiments to extract and aggregate features
    for exp_idx = 1:length(experiments)
           experimentName = experiments(exp_idx).name;
        [allTestFeatures, allBaselineFeatures, allDifferenceFeatures, allQuestionnaireData, allSystemData] = ...
            addToFeatureTables(processedTablesDir, experimentName, allTestFeatures, allBaselineFeatures, ...
            allDifferenceFeatures, allQuestionnaireData, allSystemData);
    end

% % Sort each table by 'Participant' column
allTestFeatures= sortrows(allTestFeatures, 'Participant');
allBaselineFeatures = sortrows(allBaselineFeatures, 'Participant');
allDifferenceFeatures = sortrows(allDifferenceFeatures, 'Participant');
% 
% % Merge the tables and sort the combined table by 'Participant'
allPhysiologicalFeatures = [allBaselineFeatures; allTestFeatures; allDifferenceFeatures];
allPhysiologicalFeatures = sortrows(allPhysiologicalFeatures, 'Participant');

% % Merge Physiological (only difference), Questionnaire, and System data
allTables = join(allSystemData, allQuestionnaireData);
allTables = join(allTables, allDifferenceFeatures);
% 
% % Save the combined tables into .MAT files
save(fullfile(processedTablesDir, 'allData.mat'), 'allTables');
save(fullfile(processedTablesDir, 'allPhysiologicalFeatures.mat'), 'allPhysiologicalFeatures');
save(fullfile(processedTablesDir, 'allQuestionnairedata.mat'), 'allQuestionnaireData');
save(fullfile(processedTablesDir, 'allSystemData.mat'), 'allSystemData');

% Define the output Excel file path
excelFile = fullfile(processedTablesDir, 'AllData.xlsx');

% Write each table to a separate sheet
% Check if variables are tables or convert them if needed
if istable(allTables)
    writetable(allTables, excelFile, 'Sheet', 'allTables');
end
if istable(allPhysiologicalFeatures)
    writetable(allPhysiologicalFeatures, excelFile, 'Sheet', 'allPhysiologicalFeatures');
end
if istable(allQuestionnaireData)
    writetable(allQuestionnaireData, excelFile, 'Sheet', 'allQuestionnaireData');
end
if istable(allSystemData)
    writetable(allSystemData, excelFile, 'Sheet', 'allSystemData');
end

disp('Analysis complete.');