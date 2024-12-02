% Function ADDTOFEATURETABLES - Aggregates data from multiple .mat files for 
% physiological features, questionnaire data, and system data, and 
% compiles them into comprehensive tables.
%
% Syntax: 
%   [allTestFeatures, allBaselineFeatures, allDifferenceFeatures, 
%    allQuestionnaireData, allSystemData] = addToFeatureTables(
%        processedTablesDir, experiment, allTestFeatures, 
%        allBaselineFeatures, allDifferenceFeatures, 
%        allQuestionnaireData, allSystemData)
%
% Inputs:
%   processedTablesDir (string) - Directory where processed .mat files are stored.
%   experiment (string) - Identifier for the specific experiment (e.g., 'experiment1', 'experiment2').
%   allTestFeatures (table) - Accumulated table of test physiological features.
%   allBaselineFeatures (table) - Accumulated table of baseline physiological features.
%   allDifferenceFeatures (table) - Accumulated table of difference physiological features.
%   allQuestionnaireData (table) - Accumulated table of questionnaire data.
%   allSystemData (table) - Accumulated table of system data.
%
% Outputs:
%   allTestFeatures (table) - Updated table of test physiological features including new data.
%   allBaselineFeatures (table) - Updated table of baseline physiological features including new data.
%   allDifferenceFeatures (table) - Updated table of difference physiological features including new data.
%   allQuestionnaireData (table) - Updated table of questionnaire data including new data.
%   allSystemData (table) - Updated table of system data including new data.
%
% Operation:
%   - Lists feature files for the specified experiment and loads physiological feature data.
%   - Extracts participant IDs and flattens feature structures into tables.
%   - Appends new data to the aggregated tables for test features, baseline features, and difference features.
%   - Processes and transposes questionnaire data, appending it to the aggregated questionnaire table.
%   - Loads system data, extracts relevant fields, and appends it to the aggregated system data table.

function [allTestFeatures, allBaselineFeatures, allDifferenceFeatures, allQuestionnaireData, allSystemData] = addToFeatureTables(processedTablesDir, experiment, allTestFeatures, allBaselineFeatures, allDifferenceFeatures, allQuestionnaireData, allSystemData)
    % List all feature files for the given experiment
    featureFiles = dir(fullfile(processedTablesDir, sprintf('%s_*_PhysiologicalFeatures.mat', experiment)));
    questionnaireFiles = dir(fullfile(processedTablesDir, sprintf('%s_*_questionnaire_data.mat', experiment)));
    systemFiles = dir(fullfile(processedTablesDir, sprintf('%s_*_system_data.mat', experiment)));

    % Iterate over each feature file
    for i = 1:length(featureFiles)
        % Load the feature file
        load(fullfile(processedTablesDir, featureFiles(i).name), 'Test_PhysiologicalFeatures_struct', 'Baseline_PhysiologicalFeatures_struct', 'Difference_PhysiologicalFeatures_struct');
        
        % Extract participant ID from the filename
        participantID = extractBetween(featureFiles(i).name, sprintf('%s_', experiment), '_PhysiologicalFeatures.mat');
        
        % Flatten the structures with participantID and experiment info
        testTable = flattenStruct(Test_PhysiologicalFeatures_struct, participantID, experiment);
        baselineTable = flattenStruct(Baseline_PhysiologicalFeatures_struct, participantID, experiment);
        diffTable = flattenStruct(Difference_PhysiologicalFeatures_struct, participantID, experiment);

        %Formmaitng the diffTable (removing duplicates):
        % List of columns to remove
        columnsToRemove = {'IBI_participantID', 'HR_participantID',...
         'EDA_participantID', 'IBI_experimentID', 'HR_experimentID', ...
         'EDA_experimentID','EDA_Experiment','EDA_Participant', ...
         'IBI_Experiment','IBI_Participant', ...
         'HR_Experiment','HR_Participant'};

        % Remove the specified columns
         diffTable(:, columnsToRemove) = [];

         % Formating the test and baseline table:
         % Specify the target column names
         targetColumnNames = {'IBI_meanIBI', 'IBI_sdnn', 'IBI_rmssd', 'IBI_nn50', 'IBI_pnn50', ...
                     'HR_meanHR', 'HR_maxHR', 'HR_minHR', 'HR_hrRange', 'HR_sdHR', ...
                     'EDA_meanSCRAmplitude', 'EDA_scrCount', 'EDA_meanSCL', 'EDA_meanSCRRiseTime', ...
                     'EDA_meanSCRRecoveryTime', 'EDA_F0SC', 'EDA_F1SC', 'EDA_F2SC', 'EDA_F3SC', ...
                     'EDA_meanFirstDerivative', 'EDA_meanSecondDerivative', ...
                     'Participant', 'Experiment', 'Period'};
         expandedTestTable = expandPhysiologicalData(testTable, targetColumnNames);
         expandedBaselineTable = expandPhysiologicalData(baselineTable, targetColumnNames);
        
        % Append to aggregated tables
        allTestFeatures = unique([allTestFeatures; expandedTestTable], 'rows');
        allBaselineFeatures = unique([allBaselineFeatures; expandedBaselineTable], 'rows');
        allDifferenceFeatures = unique([allDifferenceFeatures; diffTable], 'rows');

    end

    % Iterate over each questionnaire file
    for i = 1:length(questionnaireFiles)
        % Load the questionnaire data
        load(fullfile(processedTablesDir, questionnaireFiles(i).name), 'questionnaireFeatures');
        % Extract participant ID from the filename
        participantID = extractBetween(questionnaireFiles(i).name, sprintf('%s_', experiment), '_questionnaire_data.mat');
        
        % Extract data and transpose it correctly
        questionnaireData = questionnaireFeatures.data;
        headers = questionnaireData{:, 1}; % First column as headers
        values = questionnaireData{:, 2:end}'; % Transpose remaining data

        % Create a new table with headers as columns and values as rows
        transposedTable = array2table(values, 'VariableNames', headers');
        
        % Add participant ID and experiment ID as new columns
        numRows = height(transposedTable);
        transposedTable.participantID = repmat(participantID, numRows, 1);
        transposedTable.experimentID = repmat({experiment}, numRows, 1);

           % Rename the column
        currentName = 'participantID';  % Original column name
        newName = 'Participant';            % New concise nam
        % Update the table variable name
        transposedTable.Properties.VariableNames{strcmp(transposedTable.Properties.VariableNames, currentName)} = newName;
        currentName = 'experimentID';  % Original column name
        newName = 'Experiment'; 
        transposedTable.Properties.VariableNames{strcmp(transposedTable.Properties.VariableNames, currentName)} = newName;
        
        
        % Append to the aggregated questionnaire table
        allQuestionnaireData = [allQuestionnaireData; transposedTable];
    end

    % Iterate over each system data file
    for i = 1:length(systemFiles)
        % Load the system data
        data = load(fullfile(processedTablesDir, systemFiles(i).name));
        
        % Check if 'systemDataFeatures' struct exists in the file
        if isfield(data, 'systemDataFeatures')
            systemDataFeatures = data.systemDataFeatures;
            
            % Extract necessary fields
            participantID = systemDataFeatures.participantID;
            experimentID = systemDataFeatures.experimentID;
            numCollisions = systemDataFeatures.numCollisions;
            numCommandChanges = systemDataFeatures.numCommandChanges;
            totalTime = systemDataFeatures.totalTime;

            % Create a structure with system data features
            systemDataEntry = struct();
            systemDataEntry.participantID = participantID;
            systemDataEntry.experimentID = experimentID;
            systemDataEntry.numCollisions = numCollisions;
            systemDataEntry.numCommandChanges = numCommandChanges;
            systemDataEntry.totalTime = totalTime;

            % Convert the structure to a table
            systemDataTable = struct2table(systemDataEntry, 'AsArray', true);

                    % Rename the column
        currentName = 'participantID';  % Original column name
        newName = 'Participant';            % New concise nam
        % Update the table variable name
        systemDataTable.Properties.VariableNames{strcmp(systemDataTable.Properties.VariableNames, currentName)} = newName;
        currentName = 'experimentID';  % Original column name
        newName = 'Experiment'; 
        systemDataTable.Properties.VariableNames{strcmp(systemDataTable.Properties.VariableNames, currentName)} = newName;

        % Append to the aggregated system data table
        allSystemData = [allSystemData; systemDataTable];
        else
            warning('Variable ''systemDataFeatures'' not found in %s', systemFiles(i).name);
        end
    end
   

end

%% Local Functions: 

function expandedTable = expandPhysiologicalData(dataTable, targetColumnNames)
% EXPANDPHYSIOLOGICALDATA Extracts and combines nested physiological data from a table.
%
% Syntax:
%   expandedTable = expandPhysiologicalData(dataTable, targetColumnNames)
%
% Inputs:
%   dataTable (table) - Input table containing nested IBI, HR, and EDA data.
%   targetColumnNames (cell array) - Cell array of strings specifying the new column names.
%
% Outputs:
%   expandedTable (table) - Expanded table with extracted physiological data and renamed columns.
%
% Operation:
%   - Extracts IBI, HR, and EDA data from the nested tables in the input.
%   - Combines extracted data with Participant, Experiment, and Period columns.
%   - Renames variables to match the target column names.
    
    % Extract variables from nested tables
    IBI_data = dataTable.IBI;  % Extract nested table for IBI
    HR_data = dataTable.HR;    % Extract nested table for HR
    EDA_data = dataTable.EDA;  % Extract nested table for EDA

    % Combine the extracted data into new columns
    expandedTable =array2table([IBI_data, HR_data, EDA_data]);
    

    % Add Participant, Experiment, and Period columns
    expandedTable.Participant = dataTable.Participant;
    expandedTable.Experiment = dataTable.Experiment;
    expandedTable.Period = dataTable.Period;

    % Rename the variables to match targetColumnNames
    expandedTable.Properties.VariableNames = targetColumnNames;

    % Display the resulting table (optional)
    % disp(expandedTable);
end
