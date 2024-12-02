function analysePhysiologicalData(physiologicalData, experiment, participant, processedTablesDir)
    fprintf('Processing data for %s - %s\n', experiment, participant); % Debug statement

    %% 1 - Retrieve participant data
    participantData = getParticipantData(physiologicalData, experiment, participant);
    if isempty(participantData)
        fprintf('No data found for %s in %s experiment.\n', participant, experiment);
        return;
    end

    %% 2 - Load physiological data and convert them to timetables
    [IBI_timetable, HR_timetable, EDA_timetable] = loadData(participantData, participant);

    %% 3 - Load the Tags file
    tags_timetable = loadTagsFile(participantData, participant);
    if isempty(tags_timetable)
        fprintf('No tags file found for %s.\n', participant);
        return;
    end

    %  % Extract the start time from the test_time variable
    % task_start_time = tags_timetable.start_test + seconds(2);  % Or any specific time from your `test_time` array
    % 
    % % Define the end time for the task (e.g., 10 minutes later)
    % task_end_time = task_start_time + seconds(20);
    % 
    % % Create a new fake event
    % new_event = table(task_start_time, task_end_time, 'VariableNames', {'TaskStartTime', 'TaskEndTime'});
    % 
    % another_event=table(task_start_time+seconds(22), task_end_time+seconds(42), 'VariableNames', {'TaskStartTime2', 'TaskEndTime2'});
    % 
    % % Append the new event to the existing tags_timetable
    % tags_timetable = [tags_timetable, new_event, another_event]


    %% 4 - Define time ranges for tags (baseline and test periods)
    [time_ranges, task_ranges] = defineTimeRanges(tags_timetable);


    %% 5 - Split the time series data per phase (baseline or test) for each physiological variable 
    [IBI_data] = processTimetableData(IBI_timetable, time_ranges, task_ranges);
    [HR_data] = processTimetableData(HR_timetable, time_ranges, task_ranges);
    [EDA_data] = processTimetableData(EDA_timetable, time_ranges, task_ranges);

    %% 6 - Synchronize the timetables
    synchronizedNumericTestTable = synchronizeData(IBI_data.test_data, HR_data.test_data, EDA_data.test_data);
    synchronizedNumericBaselineTable = synchronizeData(IBI_data.baseline_data, HR_data.baseline_data, EDA_data.baseline_data);

    
    %% 7 - Extract Features 

    % Extract features for test and baseline periods
    [IBI_Test_Features, HR_Test_Features, EDA_Test_Features] = extractPhysiologicalFeatures(IBI_data.test_data, HR_data.test_data, EDA_data.test_data);
    [IBI_Baseline_Features, HR_Baseline_Features, EDA_Baseline_Features] = extractPhysiologicalFeatures(IBI_data.baseline_data, HR_data.baseline_data, EDA_data.baseline_data);
    
    % Create structured data for test and baseline features
    IBI_Test_Features_struct = createIBIStruct(IBI_Test_Features, participant, experiment);
    HR_Test_Features_struct = createHRStruct(HR_Test_Features, participant, experiment);
    EDA_Test_Features_struct = createEDAStruct(EDA_Test_Features, participant, experiment);
    
    IBI_Baseline_Features_struct = createIBIStruct(IBI_Baseline_Features, participant, experiment);
    HR_Baseline_Features_struct = createHRStruct(HR_Baseline_Features, participant, experiment);
    EDA_Baseline_Features_struct = createEDAStruct(EDA_Baseline_Features, participant, experiment);
    %% 8 - Extract Features Per Task (If Task Events Exist)
    
    % If task events are present, extract features for each task separately
    Task_IBI_Features_struct = [];
    Task_HR_Features_struct = [];
    Task_EDA_Features_struct = [];
    num_tasks=[];
    
    if width(tags_timetable)>5

        num_tasks = (width(tags_timetable)-5)/2;  % Get the number of tasks (assuming each row is a task)
        
        % Initialize cell arrays to store task-specific features
        Task_IBI_Features = cell(num_tasks, 1);
        Task_HR_Features = cell(num_tasks, 1);
        Task_EDA_Features = cell(num_tasks, 1);
        
        % Extract features for each task
        for task_idx = 1:num_tasks

            IBI_data_currentTask= IBI_data.task_data{1,task_idx};
            HR_data_currentTask= HR_data.task_data{1,task_idx};
            EDA_data_currentTask= EDA_data.task_data{1,task_idx};
  
            % Extract task-specific data and features
            [IBI_task_features, HR_task_features, EDA_task_features] = extractPhysiologicalFeatures(IBI_data_currentTask, HR_data_currentTask, EDA_data_currentTask);
            
            % Store task features in cell arrays
            % Task_IBI_Features{task_idx} = IBI_task_features;
            % Task_HR_Features{task_idx} = HR_task_features;
            % Task_EDA_Features{task_idx} = EDA_task_features;
            
            % Create task-specific structured data (including Participant ID)
            Task_IBI_Features_struct = [Task_IBI_Features_struct; createIBIStruct(IBI_task_features, participant, experiment)];
            Task_HR_Features_struct = [Task_HR_Features_struct; createHRStruct(HR_task_features, participant, experiment)];
            Task_EDA_Features_struct = [Task_EDA_Features_struct; createEDAStruct(EDA_task_features, participant, experiment)];
            
            % Add Participant ID for each task
            Task_IBI_Features_struct(end).participantID = participant;
            Task_HR_Features_struct(end).participantID = participant;
            Task_EDA_Features_struct(end).participantID = participant;
        end
    end
    
    %% 9 - Calculate Differences Between Test and Baseline Features
    % Calculate differences between test and baseline features
    IBI_Feature_Diffs = calculateFeatureDifferences(IBI_Test_Features_struct, IBI_Baseline_Features_struct);
    HR_Feature_Diffs = calculateFeatureDifferences(HR_Test_Features_struct, HR_Baseline_Features_struct);
    EDA_Feature_Diffs = calculateFeatureDifferences(EDA_Test_Features_struct, EDA_Baseline_Features_struct);
    
    %% 10 - Prepare and Save All Features
    % Prepare structures with labels for test, baseline, and difference data
    Test_PhysiologicalFeatures_struct = struct('metrics_type', 'test', 'IBI', IBI_Test_Features, 'HR', HR_Test_Features, 'EDA', EDA_Test_Features);
    Baseline_PhysiologicalFeatures_struct = struct('metrics_type', 'baseline', 'IBI', IBI_Baseline_Features, 'HR', HR_Baseline_Features, 'EDA', EDA_Baseline_Features);
    Difference_PhysiologicalFeatures_struct = struct('metrics_type', 'difference', 'IBI', IBI_Feature_Diffs, 'HR', HR_Feature_Diffs, 'EDA', EDA_Feature_Diffs);
    
    % If task-specific features exist, add them to the structure
    if ~isempty(Task_IBI_Features_struct)
        Task_PhysiologicalFeatures_struct = struct('metrics_type', 'task', 'IBI', {Task_IBI_Features_struct}, 'HR', {Task_HR_Features_struct}, 'EDA', {Task_EDA_Features_struct});
    else
        Task_PhysiologicalFeatures_struct = struct();  % Empty structure if no tasks
    end
    
    % Save the features and synchronized tables to a .mat file
    savePhysiologicalFeatures(experiment, participant, synchronizedNumericTestTable, synchronizedNumericBaselineTable, ...
                              Test_PhysiologicalFeatures_struct, Baseline_PhysiologicalFeatures_struct, ...
                              Difference_PhysiologicalFeatures_struct, Task_PhysiologicalFeatures_struct, processedTablesDir);
end


%% Local Functions 

function participantData = getParticipantData(physiologicalData, experiment, participant)
    try
        participantData = physiologicalData.(makeValidFieldName(experiment)).(makeValidFieldName(participant)).e4;
    catch
        participantData = [];
    end
end

function [IBI_timetable, HR_timetable, EDA_timetable] = loadData(participantData, participant)
    IBI_timetable = loadTimetable(participantData, 'IBI_csv', participant);
    HR_timetable = loadTimetable(participantData, 'HR_csv', participant);
    EDA_timetable = loadTimetable(participantData, 'EDA_csv', participant);
end

function timetable = loadTimetable(participantData, field, participant)
    if isfield(participantData, field)
        filePath = participantData.(field);
        fprintf('%s file path: %s\n', field, filePath);
        % Use dynamic function call based on the field
        switch field
            case 'IBI_csv'
                timetable = readingIBI(filePath, participant);
            case 'HR_csv'
                timetable = readingHR(filePath, participant);
            case 'EDA_csv'
                timetable = readingEDA(filePath, participant);
            otherwise
                fprintf('Unknown field: %s. Timetable not processed.\n', field);
                timetable = [];
        end
    else
        fprintf('Field %s not found for participant.\n', field);
        timetable = [];
    end
end

function tags_timetable = loadTagsFile(participantData, participant)
    if isfield(participantData, 'tags_csv')
        tags_file_path = participantData.tags_csv;
        fprintf('Tags file path: %s\n', tags_file_path);
        tags_timetable = readingTags(tags_file_path, participant);
    else
        tags_timetable = [];
    end
end

function [time_ranges, task_ranges] = defineTimeRanges(tags_timetable)
    % Default parameter values
    summerTimeAdjust = 1;         % Default summer time adjustment (hours)

      % Initialize time ranges for test and baseline
    time_ranges = struct();
    task_ranges = struct();
    
    % Extract and adjust start times
    start_test = table2array(tags_timetable(1, 2)) + hours(summerTimeAdjust);
    end_test = table2array(tags_timetable(1, 3)) + hours( summerTimeAdjust);
    start_baseline = table2array(tags_timetable(1, 4)) + hours(summerTimeAdjust);
    end_baseline = table2array(tags_timetable(1,5)) + hours(summerTimeAdjust);

    % Define timeranges
    % test_range = timerange(start_test, end_test);
    % baseline_range = timerange(start_baseline, end_baseline);

     % Store test and baseline ranges
    time_ranges.test = timerange(start_test, end_test);
    time_ranges.baseline = timerange(start_baseline, end_baseline);
    
    % Dynamically handle multiple tasks (if present)
    num_columns = size(tags_timetable, 2); % Get the number of columns in the timetable
    task_count = 0; % Task counter
    
    % Loop through columns to find task start and end times
    for i = 6:2:num_columns % Starting from the 6th column (TASK1_START), iterate every 2 columns
        if i + 1 <= num_columns
            task_start_col = i;   % Start time column for task
            task_end_col = i + 1; % End time column for task
            
            if ~isempty(tags_timetable{1, task_start_col}) && ~isempty(tags_timetable{1, task_end_col})
                % Adjust task start and end times
                start_task = table2array(tags_timetable(1, task_start_col)) + hours(summerTimeAdjust);
                end_task = table2array(tags_timetable(1, task_end_col)) + hours(summerTimeAdjust);
                
                task_count = task_count + 1;
                task_ranges.(['task' num2str(task_count)]) = timerange(start_task, end_task); % Store task range
            end
        end
    end

end


function processed_data = processTimetableData(timetable, time_ranges, task_ranges)
  
    % Default empty value
    processed_data = struct();
    
    if isempty(timetable)
        return;
    end
    
    timetable = sortrows(timetable, 'Time'); % Sort timetable by time
    
    % Process test and baseline data based on the defined ranges
    processed_data.test_data = timetable(time_ranges.test, :);
    processed_data.baseline_data = timetable(time_ranges.baseline, :);
    
    % Convert times to datetime with millisecond precision
    processed_data.test_data.Time = datetime(processed_data.test_data.Time, 'Format', 'yyyy-MM-dd HH:mm:ss.SSS');
    processed_data.baseline_data.Time = datetime(processed_data.baseline_data.Time, 'Format', 'yyyy-MM-dd HH:mm:ss.SSS');
    
    % Process task data based on task ranges
    task_count = length(fieldnames(task_ranges));
    processed_data.task_data = cell(1, task_count);
    
    for i = 1:task_count
        task_name = ['task' num2str(i)];
        if isfield(task_ranges, task_name)
            processed_data.task_data{i} = timetable(task_ranges.(task_name), :); % Extract task data for each task
            % Convert times to datetime with millisecond precision for each task
            processed_data.task_data{i}.Time = datetime(processed_data.task_data{i}.Time, 'Format', 'yyyy-MM-dd HH:mm:ss.SSS');
        end
    end

    
end

function synchronizedTable = synchronizeData(IBI_timetable, HR_timetable, EDA_timetable)
    
    % Synchronize numeric variables using 'mean' for overlapping periods        
    synchronizedNumericTable = synchronize(IBI_timetable(:, setdiff(IBI_timetable.Properties.VariableNames, ...
        {'Sample_ID'})), HR_timetable(:, setdiff(HR_timetable.Properties.VariableNames, {'Sample_ID'})), ...
        EDA_timetable(:, setdiff(EDA_timetable.Properties.VariableNames, {'Sample_ID'})), ...
                                                           'union', 'mean');

    % Extract non-numeric variables from each timetable for test and baseline periods
    IBI_nonNumeric = IBI_timetable(:, ~varfun(@(x) isnumeric(x) || isdatetime(x) || isduration(x), IBI_timetable, 'OutputFormat', 'uniform'));
    HR_nonNumeric = HR_timetable(:, ~varfun(@(x) isnumeric(x) || isdatetime(x) || isduration(x), HR_timetable, 'OutputFormat', 'uniform'));
    EDA_nonNumeric = EDA_timetable(:, ~varfun(@(x) isnumeric(x) || isdatetime(x) || isduration(x), EDA_timetable, 'OutputFormat', 'uniform'));

    % Synchronize the non-numeric variables using 'previous' method for missing data
    synchronizedNonNumericTable = synchronize(IBI_nonNumeric, HR_nonNumeric, EDA_nonNumeric, 'union', 'previous');

    % Combine synchronized tables for test and baseline periods
    synchronizedTable = [synchronizedNonNumericTable, synchronizedNumericTable(:, 2:end)];
    
end

function [IBI_Features, HR_Features, EDA_Features] = extractPhysiologicalFeatures(IBI_timetable, HR_timetable, EDA_timetable)
    % Extract features from the provided timetables
    [IBI_Features, HR_Features] = extractingIBIFeatures(IBI_timetable);
    EDA_Features = extractEDAFeatures(EDA_timetable);
end


function IBI_Struct = createIBIStruct(features, participant, experiment)
    IBI_Struct = struct('participantID', participant, 'experimentID', experiment, ...
                        'meanIBI', features(1), 'sdnn', features(2), 'rmssd', features(3), ...
                        'nn50', features(4), 'pnn50', features(5));
end

function HR_Struct = createHRStruct(features, participant, experiment)
    HR_Struct = struct('participantID', participant, 'experimentID', experiment, ...
                       'meanHR', features(1), 'maxHR', features(2), 'minHR', features(3), ...
                       'hrRange', features(4), 'sdHR', features(5));
end

function EDA_Struct = createEDAStruct(features, participant, experiment)
    EDA_Struct = struct('participantID', participant, 'experimentID', experiment, ...
                        'meanSCRAmplitude', features(1), 'scrCount', features(2), 'meanSCL', features(3), ...
                        'meanSCRRiseTime', features(4), 'meanSCRRecoveryTime', features(5), ...
                        'F0SC', features(6), 'F1SC', features(7), 'F2SC', features(8), ...
                        'F3SC', features(9), 'meanFirstDerivative', features(10), 'meanSecondDerivative', features(11));
end


function featureDiffs = calculateFeatureDifferences(testStruct, baselineStruct)
    % Calculate the differences between test and baseline feature structs
    featureDiffs = struct();
    featureFields = fieldnames(testStruct);
    
    for i = 1:length(featureFields)
        featureField = featureFields{i};
        featureDiffs.(featureField) = testStruct.(featureField) - baselineStruct.(featureField);
    end
end


function savePhysiologicalFeatures(experiment, participant, synchronizedNumericTestTable, synchronizedNumericBaselineTable, ...
                                   Test_PhysiologicalFeatures_struct, Baseline_PhysiologicalFeatures_struct, ...
                                   Difference_PhysiologicalFeatures_struct, Task_PhysiologicalFeatures_struct, processedTablesDir)
    % Save the features for test, baseline, and differences along with task data if present
    save(fullfile(processedTablesDir, sprintf('%s_%s_PhysiologicalFeatures.mat', experiment, participant)), ...
        'synchronizedNumericTestTable', 'synchronizedNumericBaselineTable', ...
        'Test_PhysiologicalFeatures_struct', 'Baseline_PhysiologicalFeatures_struct', ...
        'Difference_PhysiologicalFeatures_struct', 'Task_PhysiologicalFeatures_struct');
end

