% ALIGNCOLUMNS - Aligns the columns of a table to match a target set 
% of column names, ensuring consistency across multiple tables.
% Inputs:
%   table (table) - The table to be aligned.
%   targetColumnNames (cell array of strings) - The target column names that the table should match.
% Outputs:
%   alignedTable (table) - The table with columns aligned to the target column names, with missing columns added as NaNs.
%
% Operation:
%   - Adds missing columns to the table with NaN values.
%   - Reorders columns to match the target set of column names.
function alignedTable = alignColumns(table, targetColumnNames)
    % Add missing columns with NaN values
    for col = setdiff(targetColumnNames, table.Properties.VariableNames)
        table.(col) = nan(height(table), 1);
    end
    % Reorder columns to match the target
    alignedTable = table(:, targetColumnNames);
end