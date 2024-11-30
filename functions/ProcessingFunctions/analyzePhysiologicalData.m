
% Function ANALYZEPHYSIOLOGICALDATA Processes and analyzes physiological data for a given participant.
    % 
    % INPUTS:
    %   physiologicalData - A structure containing physiological data for multiple participants and experiments.
    %                       It should include fields for each experiment and participant, with further details for devices.
    %   experiment        - A string specifying the experiment identifier within physiologicalData.
    %   participant       - A string specifying the participant identifier within the experiment.
    %   processedTablesDir - A string specifying the directory path where processed tables will be saved.
    % 
    % OUTPUTS:
    %   Saves a .mat file in the specified directory containing:
    %     - Test_PhysiologicalFeatures_struct: Struct with extracted features from the test period.
    %     - Baseline_PhysiologicalFeatures_struct: Struct with extracted features from the baseline period.
    %     - Difference_PhysiologicalFeatures_struct: Struct with differences between test and baseline features.
    %     - synchronizedTestTable: Timetable with synchronized data for the test period.
    %     - synchronizedBaselineTable: Timetable with synchronized data for the baseline period.
    % 
    % FUNCTIONALITY:
    % 1. Retrieves the physiological data for the specified participant and experiment.
    % 2. Reads and processes various physiological data files (BVP, IBI, HR, EDA).
    % 3. Extracts and synchronizes features for the test and baseline periods.
    % 4. Calculates differences in features between test and baseline periods.
    % 5. Saves the processed data and features into a .mat file in the specified directory.
    % 6. Displays debug messages to indicate progress and paths of processed files.
    % 7. Includes placeholders for future integration with OpenFace and OpenVibe data.
function analyzePhysiologicalData(physiologicalData, experiment, participant, processedTablesDir)
    disp(['Processing data for ', experiment, ' - ', participant]); % Debug statement
    
    % Retrieve participant data
    if isfield(physiologicalData, makeValidFieldName(experiment)) && ...
       isfield(physiologicalData.(makeValidFieldName(experiment)), makeValidFieldName(participant)) && ...
       isfield(physiologicalData.(makeValidFieldName(experiment)).(makeValidFieldName(participant)), 'e4')
       
        participantData = physiologicalData.(makeValidFieldName(experiment)).(makeValidFieldName(participant)).e4;
        
        % Debug: Print available files
        disp('Available files:');
        disp(participantData);

        % Initialize empty timetables
        IBI_timetable = [];
        HR_timetable = [];
        EDA_timetable = [];

        % Check for BVP data
        if isfield(participantData, 'BVP_csv')
            BVP_file_path = participantData.BVP_csv;
            disp(['BVP file path: ', BVP_file_path]); % Debug statement
            BVP_timetable = readingBVP(BVP_file_path, participant);
        end

        % Check for IBI data
        if isfield(participantData, 'IBI_csv')
            IBI_file_path = participantData.IBI_csv;
            disp(['IBI file path: ', IBI_file_path]); % Debug statement
            IBI_timetable = readingIBI(IBI_file_path, participant);
        end

        % Check for HR data
        if isfield(participantData, 'HR_csv')
            HR_file_path = participantData.HR_csv;
            disp(['HR file path: ', HR_file_path]); % Debug statement
            HR_timetable = readingHR(HR_file_path, participant);
        end

        % Check for EDA data
        if isfield(participantData, 'EDA_csv')
            EDA_file_path = participantData.EDA_csv;
            disp(['EDA file path: ', EDA_file_path]); % Debug statement
            EDA_timetable = readingEDA(EDA_file_path, participant);
        end

         % Check for Tags data
        if isfield(participantData, 'tags_csv')
            tags_file_path = participantData.tags_csv;
            disp(['Tags file path: ', tags_file_path]); % Debug statement
            tags_timetable = readingTags(tags_file_path, participant);
            
            % Ensure tags_timetable is not empty and contains necessary columns
            if ~isempty(tags_timetable) && width(tags_timetable) >= 4
                start_test = table2array(tags_timetable(1, 2)) + hours(1);
                end_test = table2array(tags_timetable(1, 3)) + hours(1);
                start_baseline = table2array(tags_timetable(1, 4)) + hours(1);
                end_baseline = table2array(tags_timetable(1, 5)) + hours(1);
              
                test_range = timerange(start_test, end_test);
                baseline_range = timerange(start_baseline, end_baseline);

                
             % Synchronize and trim timetables
             if ~isempty(IBI_timetable)
                    IBI_timetable = sortrows(IBI_timetable, 'Time'); % Sort the timetables by time
                    IBI_test_timetable = IBI_timetable(test_range, :);
                    IBI_baseline_timetable = IBI_timetable(baseline_range, :);
             end
             if ~isempty(EDA_timetable)
                    EDA_timetable = sortrows(EDA_timetable, 'Time');
                    EDA_test_timetable = EDA_timetable(test_range, :);
                    EDA_baseline_timetable = EDA_timetable(baseline_range, :);
             end
             if ~isempty(HR_timetable)
                    HR_timetable = sortrows(HR_timetable, 'Time');
                    HR_test_timetable = HR_timetable(test_range, :);
                    HR_baseline_timetable = HR_timetable(baseline_range, :);
             end
                % Debug: Display time ranges of the test and baseline periods
                disp('IBI_test_timetable Time Range:');
                disp([min(IBI_test_timetable.Time), max(IBI_test_timetable.Time)]);
                disp('HR_test_timetable Time Range:');
                disp([min(HR_test_timetable.Time), max(HR_test_timetable.Time)]);
                disp('EDA_test_timetable Time Range:');
                disp([min(EDA_test_timetable.Time), max(EDA_test_timetable.Time)]);

                disp('IBI_baseline_timetable Time Range:');
                disp([min(IBI_baseline_timetable.Time), max(IBI_baseline_timetable.Time)]);
                disp('HR_baseline_timetable Time Range:');
                disp([min(HR_baseline_timetable.Time), max(HR_baseline_timetable.Time)]);
                disp('EDA_baseline_timetable Time Range:');
                disp([min(EDA_baseline_timetable.Time), max(EDA_baseline_timetable.Time)]);

                % Convert times to datetime with millisecond precision
                IBI_test_timetable.Time = datetime(IBI_test_timetable.Time, 'Format', 'yyyy-MM-dd HH:mm:ss.SSS');
                HR_test_timetable.Time = datetime(HR_test_timetable.Time, 'Format', 'yyyy-MM-dd HH:mm:ss.SSS');
                EDA_test_timetable.Time = datetime(EDA_test_timetable.Time, 'Format', 'yyyy-MM-dd HH:mm:ss.SSS');

                IBI_baseline_timetable.Time = datetime(IBI_baseline_timetable.Time, 'Format', 'yyyy-MM-dd HH:mm:ss.SSS');
                HR_baseline_timetable.Time = datetime(HR_baseline_timetable.Time, 'Format', 'yyyy-MM-dd HH:mm:ss.SSS');
                EDA_baseline_timetable.Time = datetime(EDA_baseline_timetable.Time, 'Format', 'yyyy-MM-dd HH:mm:ss.SSS');

                % Synchronize numeric variables for test and baseline periods
                synchronizedNumericTestTable = synchronize(IBI_test_timetable(:, setdiff(IBI_test_timetable.Properties.VariableNames, {'Sample_ID'})), ...
                                                           HR_test_timetable(:, setdiff(HR_test_timetable.Properties.VariableNames, {'Sample_ID'})), ...
                                                           EDA_test_timetable(:, setdiff(EDA_test_timetable.Properties.VariableNames, {'Sample_ID'})), ...
                                                           'union', 'mean');

                synchronizedNumericBaselineTable = synchronize(IBI_baseline_timetable(:, setdiff(IBI_baseline_timetable.Properties.VariableNames, {'Sample_ID'})), ...
                                                               HR_baseline_timetable(:, setdiff(HR_baseline_timetable.Properties.VariableNames, {'Sample_ID'})), ...
                                                               EDA_baseline_timetable(:, setdiff(EDA_baseline_timetable.Properties.VariableNames, {'Sample_ID'})), ...
                                                               'union', 'mean');

                % Extract non-numeric variables from each timetable for test and baseline periods
                IBI_test_nonNumeric = IBI_test_timetable(:, ~varfun(@(x) isnumeric(x) || isdatetime(x) || isduration(x), IBI_test_timetable, 'OutputFormat', 'uniform'));
                HR_test_nonNumeric = HR_test_timetable(:, ~varfun(@(x) isnumeric(x) || isdatetime(x) || isduration(x), HR_test_timetable, 'OutputFormat', 'uniform'));
                EDA_test_nonNumeric = EDA_test_timetable(:, ~varfun(@(x) isnumeric(x) || isdatetime(x) || isduration(x), EDA_test_timetable, 'OutputFormat', 'uniform'));

                IBI_baseline_nonNumeric = IBI_baseline_timetable(:, ~varfun(@(x) isnumeric(x) || isdatetime(x) || isduration(x), IBI_baseline_timetable, 'OutputFormat', 'uniform'));
                HR_baseline_nonNumeric = HR_baseline_timetable(:, ~varfun(@(x) isnumeric(x) || isdatetime(x) || isduration(x), HR_baseline_timetable, 'OutputFormat', 'uniform'));
                EDA_baseline_nonNumeric = EDA_baseline_timetable(:, ~varfun(@(x) isnumeric(x) || isdatetime(x) || isduration(x), EDA_baseline_timetable, 'OutputFormat', 'uniform'));

                % Synchronize the non-numeric variables using 'previous' method for missing data
                synchronizedNonNumericTestTable = synchronize(IBI_test_nonNumeric, HR_test_nonNumeric, EDA_test_nonNumeric, 'union', 'previous');
                synchronizedNonNumericBaselineTable = synchronize(IBI_baseline_nonNumeric, HR_baseline_nonNumeric, EDA_baseline_nonNumeric, 'union', 'previous');

                % Combine synchronized tables for test and baseline periods
                synchronizedTestTable = [synchronizedNonNumericTestTable, synchronizedNumericTestTable(:, 2:end)];
                synchronizedBaselineTable = [synchronizedNonNumericBaselineTable, synchronizedNumericBaselineTable(:, 2:end)];

                % Extract features for test and baseline periods
                [IBI_Test_Features, HR_Test_Features] = extractingIBIFeatures(IBI_test_timetable);
                EDA_Test_Features = extractEDAFeatures(EDA_test_timetable);

                [IBI_Baseline_Features, HR_Baseline_Features] = extractingIBIFeatures(IBI_baseline_timetable);
                EDA_Baseline_Features = extractEDAFeatures(EDA_baseline_timetable);

                 % Convert extracted features to structures for easier handling
                IBI_Test_Features_struct = struct('participantID', participant, 'experimentID', experiment, 'meanIBI', IBI_Test_Features(1), 'sdnn', IBI_Test_Features(2), 'rmssd', IBI_Test_Features(3), 'nn50', IBI_Test_Features(4), 'pnn50', IBI_Test_Features(5));
                HR_Test_Features_struct = struct('participantID', participant, 'experimentID', experiment, 'meanHR', HR_Test_Features(1), 'maxHR', HR_Test_Features(2), 'minHR', HR_Test_Features(3), 'hrRange', HR_Test_Features(4), 'sdHR', HR_Test_Features(5));
                EDA_Test_Features_struct = struct('participantID', participant, 'experimentID', experiment, 'meanSCRAmplitude', EDA_Test_Features(1), 'scrCount', EDA_Test_Features(2), 'meanSCL', EDA_Test_Features(3), 'meanSCRRiseTime', EDA_Test_Features(4), 'meanSCRRecoveryTime', EDA_Test_Features(5), 'F0SC', EDA_Test_Features(6), 'F1SC', EDA_Test_Features(7), 'F2SC', EDA_Test_Features(8), 'F3SC', EDA_Test_Features(9), 'meanFirstDerivative', EDA_Test_Features(10), 'meanSecondDerivative', EDA_Test_Features(11));

                IBI_Baseline_Features_struct = struct('participantID', participant, 'experimentID', experiment, 'meanIBI', IBI_Baseline_Features(1), 'sdnn', IBI_Baseline_Features(2), 'rmssd', IBI_Baseline_Features(3), 'nn50', IBI_Baseline_Features(4), 'pnn50', IBI_Baseline_Features(5));
                HR_Baseline_Features_struct = struct('participantID', participant, 'experimentID', experiment, 'meanHR', HR_Baseline_Features(1), 'maxHR', HR_Baseline_Features(2), 'minHR', HR_Baseline_Features(3), 'hrRange', HR_Baseline_Features(4), 'sdHR', HR_Baseline_Features(5));
                EDA_Baseline_Features_struct = struct('participantID', participant, 'experimentID', experiment, 'meanSCRAmplitude', EDA_Baseline_Features(1), 'scrCount', EDA_Baseline_Features(2), 'meanSCL', EDA_Baseline_Features(3), 'meanSCRRiseTime', EDA_Baseline_Features(4), 'meanSCRRecoveryTime', EDA_Baseline_Features(5), 'F0SC', EDA_Baseline_Features(6), 'F1SC', EDA_Baseline_Features(7), 'F2SC', EDA_Baseline_Features(8), 'F3SC', EDA_Baseline_Features(9), 'meanFirstDerivative', EDA_Baseline_Features(10), 'meanSecondDerivative', EDA_Baseline_Features(11));

                % Calculate differences between test and baseline features
                IBI_Feature_Diffs = calculateFeatureDifferences(IBI_Test_Features_struct, IBI_Baseline_Features_struct);
                HR_Feature_Diffs = calculateFeatureDifferences(HR_Test_Features_struct, HR_Baseline_Features_struct);
                EDA_Feature_Diffs = calculateFeatureDifferences(EDA_Test_Features_struct, EDA_Baseline_Features_struct);

                % Prepare structures with labels for test, baseline, and difference data
                Test_PhysiologicalFeatures_struct = struct('metrics_type', 'test', 'IBI', IBI_Test_Features, 'HR', HR_Test_Features, 'EDA', EDA_Test_Features);
                Baseline_PhysiologicalFeatures_struct = struct('metrics_type', 'baseline', 'IBI', IBI_Baseline_Features, 'HR', HR_Baseline_Features, 'EDA', EDA_Baseline_Features);
                Difference_PhysiologicalFeatures_struct = struct('metrics_type', 'difference', 'IBI', IBI_Feature_Diffs, 'HR', HR_Feature_Diffs, 'EDA', EDA_Feature_Diffs);

                 % Save the features and synchronized tables to a .mat file
                save(fullfile(processedTablesDir, sprintf('%s_%s_PhysiologicalFeatures.mat', experiment, participant)), ...
                     'Test_PhysiologicalFeatures_struct', 'Baseline_PhysiologicalFeatures_struct', 'Difference_PhysiologicalFeatures_struct', ...
                     'synchronizedTestTable', 'synchronizedBaselineTable');
            else
                 % If tags_timetable is empty or does not contain the required columns
                disp('Tags timetable is empty or does not contain required columns.');
            end
        else
            % If tags data is not found for the participant
            disp(['Tags data not found for ', experiment, ' - ', participant']); % Debug statement
        end
    else
        % If data for the specified experiment or participant is not found
        disp(['Data not found for ', experiment, ' - ', participant']); % Debug statement
    end
        
    % Check for OpenFace and OpenVibe data (not implemented yet)
    if isfield(physiologicalData, makeValidFieldName(experiment)) && ...
       isfield(physiologicalData.(makeValidFieldName(experiment)), makeValidFieldName(participant)) && ...
       isfield(physiologicalData.(makeValidFieldName(experiment)).(makeValidFieldName(participant)), 'OpenFace')
        % ToDO -- It will be implemented in the next wheelSimAnalyzer
        % Version
        % disp(['OpenFace Data for ', experiment, ' - ', participant']); % Debug statement
    end
    if isfield(physiologicalData, makeValidFieldName(experiment)) && ...
       isfield(physiologicalData.(makeValidFieldName(experiment)), makeValidFieldName(participant)) && ...
       isfield(physiologicalData.(makeValidFieldName(experiment)).(makeValidFieldName(participant)), 'OpenVibe')
        % ToDO -- It will be implemented in the next wheelSimAnalyzer
        % Version
        % disp(['OpenVibe Data for ', experiment, ' - ', participant']); % Debug statement
    end
end
