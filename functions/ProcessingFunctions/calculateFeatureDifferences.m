% Function to calculate differences between two feature structures
% This function computes the differences between corresponding fields in 
% the test_features and baseline_features structures and returns a new 
% structure with the differences.
function feature_diffs = calculateFeatureDifferences(test_features, baseline_features)
    % Extract field names from the test_features structure
    fields = fieldnames(test_features);
    
    % Initialize a new structure to store the differences
    feature_diffs = struct();
    
    % Iterate over each field in the structures
    for i = 1:numel(fields)
        field = fields{i};
        % Check if the field exists in both test_features and baseline_features
        if isfield(test_features, field) && isfield(baseline_features, field)
            % Get the values from both structures for the current field
            test_value = test_features.(field);
            baseline_value = baseline_features.(field);
            % Special handling for 'participantID' and 'experimentID' fields
            if strcmp(field, 'participantID') || strcmp(field, 'experimentID')
                % Keep the values unchanged for these fields
                feature_diffs.(field) = test_value;
            elseif isnumeric(test_value) && isnumeric(baseline_value)
                % Calculate the difference for numeric fields, handling NaNs
                feature_diffs.(field) = test_value - baseline_value;
            else
                % For non-numeric or missing fields, set the difference to NaN
                feature_diffs.(field) = NaN;
            end
        else
            % If the field is missing in either structure, set the difference to NaN
            feature_diffs.(field) = NaN;
        end
    end
end