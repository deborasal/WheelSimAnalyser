function analysePhysiologicalDatav2(physiologicalData, experiment, participant, processedTablesDir, phaseStartOffsets, phaseDurations, specificTestPhases)
    % Display message about the processing
    fprintf('Processing data for %s - %s\n', experiment, participant);

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

    %% 4 - Define time ranges for baseline, test, and specific tasks (phases)
    [test_ranges, baseline_ranges] = definePhaseTimeRanges(tags_timetable, phaseStartOffsets, phaseDurations);

    % If specific test phases are provided, extract task periods
    task_ranges = {};
    if ~isempty(specificTestPhases)
        task_ranges = defineTaskRanges(tags_timetable, specificTestPhases);
    end

    %% 5 - Process data for baseline, test, and task-specific periods
    % Process baseline and test features for the entire test period
    [IBI_test_timetable, IBI_baseline_timetable] = processTimetableData(IBI_timetable, test_ranges{1}, baseline_ranges{1});
    [HR_test_timetable, HR_baseline_timetable] = processTimetableData(HR_timetable, test_ranges{1}, baseline_ranges{1});
    [EDA_test_timetable, EDA_baseline_timetable] = processTimetableData(EDA_timetable, test_ranges{1}, baseline_ranges{1});

    % Process features for specific test phases if available (e.g., Task 1, Task 2)
    task_features = {};
    for i = 1:length(task_ranges)
        task_ibi_timetable = IBI_timetable(task_ranges{i}, :);
        task_hr_timetable = HR_timetable(task_ranges{i}, :);
        task_eda_timetable = EDA_timetable(task_ranges{i}, :);
        
        % Extract task-specific features for IBI, HR, and EDA
        task_features{i} = extractTaskSpecificFeatures(task_ibi_timetable, task_hr_timetable, task_eda_timetable);
    end

    %% 6 - Synchronize the timetables for each period
    synchronizedNumericTestTable = synchronizeData(IBI_test_timetable, HR_test_timetable, EDA_test_timetable);
    synchronizedNumericBaselineTable = synchronizeData(IBI_baseline_timetable, HR_baseline_timetable, EDA_baseline_timetable);

    % Synchronize task-specific data if tasks exist
    synchronizedTaskTables = cell(1, length(task_features));
    for i = 1:length(task_features)
        task_data = task_features{i};
        synchronizedTaskTables{i} = synchronizeData(task_data{1}, task_data{2}, task_data{3});
    end

    %% 7 - Extract Features 
    % Features for the test and baseline
    [IBI_Test_Features, HR_Test_Features, EDA_Test_Features] = extractPhysiologicalFeatures(IBI_test_timetable, HR_test_timetable, EDA_test_timetable);
    [IBI_Baseline_Features, HR_Baseline_Features, EDA_Baseline_Features] = extractPhysiologicalFeatures(IBI_baseline_timetable, HR_baseline_timetable, EDA_baseline_timetable);
    
    % Calculate difference features (test - baseline)
    IBI_Difference_Features = IBI_Test_Features - IBI_Baseline_Features;
    HR_Difference_Features = HR_Test_Features - HR_Baseline_Features;
    EDA_Difference_Features = EDA_Test_Features - EDA_Baseline_Features;
    
    % Task-specific features can be stored in a structure
    task_structs = {};
    for i = 1:length(task_features)
        task_structs{i} = task_features{i};
    end

    %% 8 - Save Results for Each Phase and Task
    savePhaseResults(experiment, participant, synchronizedNumericTestTable, synchronizedNumericBaselineTable, ...
        IBI_Test_Features, HR_Test_Features, EDA_Test_Features, IBI_Baseline_Features, HR_Baseline_Features, EDA_Baseline_Features, ...
        IBI_Difference_Features, HR_Difference_Features, EDA_Difference_Features, processedTablesDir);

    % If tasks exist, save their respective features
    if ~isempty(task_features)
        for i = 1:length(task_structs)
            saveTaskResults(experiment, participant, synchronizedTaskTables{i}, task_structs{i}, processedTablesDir, i);
        end
    end

    %% 9 - Final Message
    fprintf('Processing complete for %s.\n', participant);
end


%% Helper Functions

function [test_ranges, baseline_ranges] = definePhaseTimeRanges(tags_timetable, phaseStartOffsets, phaseDurations)
    % Define time ranges for baseline and test periods dynamically
    numPhases = length(phaseStartOffsets);
    test_ranges = cell(1, numPhases);
    baseline_ranges = cell(1, numPhases);
    
    for phaseIdx = 1:numPhases
        start_test = table2array(tags_timetable(1, 2)) + hours(phaseStartOffsets(phaseIdx));
        end_test = start_test + hours(phaseDurations(phaseIdx));
        start_baseline = table2array(tags_timetable(1, 4)) + hours(phaseStartOffsets(phaseIdx));
        end_baseline = start_baseline + hours(phaseDurations(phaseIdx));
        
        test_ranges{phaseIdx} = timerange(start_test, end_test);
        baseline_ranges{phaseIdx} = timerange(start_baseline, end_baseline);
    end
end

function task_ranges = defineTaskRanges(tags_timetable, specificTestPhases)
    % Define task-specific ranges based on user input (Task 1, Task 2, etc.)
    task_ranges = cell(1, length(specificTestPhases));
    for i = 1:length(specificTestPhases)
        task_start_time = table2array(tags_timetable(1, 2)) + hours(specificTestPhases{i}.startOffset);
        task_end_time = task_start_time + hours(specificTestPhases{i}.duration);
        task_ranges{i} = timerange(task_start_time, task_end_time);
    end
end

function savePhaseResults(experiment, participant, synchronizedNumericTestTable, synchronizedNumericBaselineTable, ...
    IBI_Test_Features, HR_Test_Features, EDA_Test_Features, IBI_Baseline_Features, HR_Baseline_Features, EDA_Baseline_Features, ...
    IBI_Difference_Features, HR_Difference_Features, EDA_Difference_Features, processedTablesDir)
    % Save the results for baseline, test, and difference features
    save(fullfile(processedTablesDir, [experiment '_' participant '_synchronizedTestData.mat']), 'synchronizedNumericTestTable');
    save(fullfile(processedTablesDir, [experiment '_' participant '_synchronizedBaselineData.mat']), 'synchronizedNumericBaselineTable');
    save(fullfile(processedTablesDir, [experiment '_' participant '_Test_Features.mat']), 'IBI_Test_Features', 'HR_Test_Features', 'EDA_Test_Features');
    save(fullfile(processedTablesDir, [experiment '_' participant '_Baseline_Features.mat']), 'IBI_Baseline_Features', 'HR_Baseline_Features', 'EDA_Baseline_Features');
    save(fullfile(processedTablesDir, [experiment '_' participant '_Difference_Features.mat']), 'IBI_Difference_Features', 'HR_Difference_Features', 'EDA_Difference_Features');
end

function saveTaskResults(experiment, participant, synchronizedTaskTable, task_features, processedTablesDir, taskIdx)
    % Save results for each specific task phase
    save(fullfile(processedTablesDir, [experiment '_' participant '_Task' num2str(taskIdx) '_SynchronizedData.mat']), 'synchronizedTaskTable');
    save(fullfile(processedTablesDir, [experiment '_' participant '_Task' num2str(taskIdx) '_Features.mat']), 'task_features');
end

function [IBI_timetable, HR_timetable, EDA_timetable] = loadData(participantData, participant)
    % Load the IBI, HR, and EDA timetables
    IBI_timetable = loadTimetable(participantData, 'IBI');
    HR_timetable = loadTimetable(participantData, 'HR');
    EDA_timetable = loadTimetable(participantData, 'EDA');
end

function timetable = loadTimetable(participantData, signalType)
    % Helper function to load a specific signal type timetable
    timetable = participantData.(signalType);
end
