clc; clear; close all

measured  = readmatrix("PATH_TO_RESULTS.xlsx", "Sheet","LAB,RGB,XYZ values", 'Range', 'B4:D15');

a = measured(:,2);
b = measured(:,3);

L = 10;

mean_a = mean(a);
mean_b = mean(b);

[m,n] = size(a);

for i = 1:m
    LAB_measured(i,:) = [L, a(i), b(i)];
    LAB_estimate(i,:) = [L, mean_a, mean_b];
    
    
end
color_dif = ciede2000(LAB_measured, LAB_estimate, [1.5,1.2,0.8]);

MCDM_DE2000 = mean(color_dif)



%%

MCDM_ = mean(sqrt((a - mean(a)).^2 + (b - mean(b)).^2))

%%
clc;clear;close all


% Parent directory containing all sample folders
parentDir = 'PATH_TO_RESULTS';  % Change to your parent directory if needed
% Name of the Excel file in each sample folder
excelFileName = 'RESULTS.xlsx';

% Specify the sheet and range to read the a*b* values.

readSheet = 'LAB,RGB,XYZ values';   
readRange = 'C4:D15'; 

% Specify the sheet and cell where the computed MCDM will be written.
writeSheet = 'LAB,RGB,XYZ values';
writeRange = 'K5';

% Get List of Sample Folders
% List all subdirectories in the parent directory (excluding '.' and '..')
sampleFolders = dir(parentDir);
sampleFolders = sampleFolders([sampleFolders.isdir]);
sampleFolders = sampleFolders(~ismember({sampleFolders.name}, {'.','..'}));
% Loop through Each Sample Folder
for i = 1:length(sampleFolders)
    folderPath = fullfile(parentDir, sampleFolders(i).name);
    filePath   = fullfile(folderPath, excelFileName);

    % Check if the Excel file exists in this folder
    if exist(filePath, 'file')
        try
            % Read the data from the Excel file
            % It is assumed that the data range contains two columns:
            % first column is a* and second column is b*.
            data = readmatrix(filePath, 'Sheet', readSheet, 'Range', readRange);

            % Extract a and b vectors
            a = data(:, 1);
            b = data(:, 2);

            L = 50;

            mean_a = mean(a);
            mean_b = mean(b);

            [m,n] = size(a);

            for j = 1:m
                LAB_measured(j,:) = [L, a(j), b(j)];
                LAB_estimate(j,:) = [L, mean_a, mean_b];
            end
            color_dif = ciede2000(LAB_measured, LAB_estimate, [1.5,1.2,0.8]);

            MCDM_DE2000 = mean(color_dif);

            % Write the MCDM value back to the Excel file at the specified sheet and range
            writematrix(MCDM_DE2000, filePath, 'Sheet', writeSheet, 'Range', writeRange);

            fprintf('Processed sample "%s": MCDM = %.2f\n', sampleFolders(i).name, MCDM_DE2000);
        catch ME
            fprintf('Error processing folder "%s": %s\n', sampleFolders(i).name, ME.message);
        end
    else
        fprintf('Excel file not found in folder: %s\n', sampleFolders(i).name);
    end
end


