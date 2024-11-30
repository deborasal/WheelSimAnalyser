% Function FLATTENSTRUCT - Converts nested structures into flat tables, adding 
% participant and experiment identifiers to each entry.
%
% Syntax: 
%   flatTable = flattenStruct(s, participantID, experiment)
%
% Inputs:
%   s (struct) - The nested structure to be flattened.
%   participantID (string) - The ID of the participant associated with the data.
%   experiment (string) - The experiment identifier associated with the data.
%
% Outputs:
%   flatTable (table) - Flattened table with nested structure fields expanded, including participant and experiment identifiers.
%
% Operation:
%   - Converts the main structure to a table.
%   - Handles scalar and non-scalar nested structures by expanding them into the main table.
%   - Adds participant and experiment identifiers to nested fields.
%   - Converts cell arrays to tables if necessary and integrates them into the main table.

function flatTable = flattenStruct(s, participantID, experiment)
    % Convert the main structure to a table
    flatTable = struct2table(s, 'AsArray', true);
    vars = flatTable.Properties.VariableNames;

    % Add participantID and experiment to the main structure fields
    flatTable.Participant = repmat(participantID, height(flatTable), 1);
    flatTable.Experiment = {repmat(experiment, height(flatTable), 1)};

    for i = 1:numel(vars)
        if isstruct(flatTable.(vars{i}))
            nestedStruct = flatTable.(vars{i});
            if isscalar(nestedStruct)
                % Add participantID and experiment to the nested structure
                nestedStruct.Participant = string(participantID);
                nestedStruct.Experiment = {experiment};

                nestedTable = struct2table(nestedStruct, 'AsArray', true);
                nestedVars = nestedTable.Properties.VariableNames;

                for j = 1:numel(nestedVars)
                    flatTable.([vars{i} '_' nestedVars{j}]) = nestedTable.(nestedVars{j});
                end
            else
                % Handle non-scalar nested structs
                for k = 1:numel(nestedStruct)
                    nestedStruct(k).Participant = participantID;
                    nestedStruct(k).Experiment = {experiment};

                    nestedTable = struct2table(nestedStruct(k), 'AsArray', true);
                    nestedVars = nestedTable.Properties.VariableNames;

                    for j = 1:numel(nestedVars)
                        flatTable.([vars{i} num2str(k) '_' nestedVars{j}]) = nestedTable.(nestedVars{j});
                    end
                end
            end
            flatTable.(vars{i}) = [];
        elseif iscell(flatTable.(vars{i}))
            % Convert cell array to table
            nestedCell = flatTable.(vars{i});
            for k = 1:numel(nestedCell)
                if isstruct(nestedCell{k})
                    nestedCell{k}.Participant = participantID;
                    nestedCell{k}.Experiment = {experiment};

                    nestedTable = struct2table(nestedCell{k}, 'AsArray', true);
                    nestedVars = nestedTable.Properties.VariableNames;

                    for j = 1:numel(nestedVars)
                        flatTable.([vars{i} num2str(k) '_' nestedVars{j}]) = nestedTable.(nestedVars{j});
                    end
                else
                    flatTable.([vars{i} num2str(k)]) = nestedCell{k};
                end
            end
            flatTable.(vars{i}) = [];
        end
    end
   
    % Rename the column
    currentName = 'metrics_type1';  % Original column name
    newName = 'Period';            % New concise nam
    % Update the table variable name
    flatTable.Properties.VariableNames{strcmp(flatTable.Properties.VariableNames, currentName)} = newName;
    flatTable.Period={flatTable.Period};

end
