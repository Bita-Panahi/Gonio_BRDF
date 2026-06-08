% This code is for the evaluation part where we use different metrics to
% evaluate the performance of the Gonio BRDF model. The reference paper for
% this code is: Techniques for BRDF evaluation // 10.1007/s00371-020-02035-9

clc; clear; close all;

measured_data = readmatrix("PATH_TO_MEASUREMENTS.xlsx", "Sheet","ALL", 'Range', 'E3:AI14');
estimated_data = readmatrix("PATH_TO_RESULTS.xlsx", "Sheet","New - Estimations", 'Range',"B4:AF15");
data = readmatrix("PATH_TO_RESULTS.xlsx", "Sheet","LAB,RGB,XYZ values");
angles = readmatrix("PATH_TO_MEASUREMENTS.xlsx", "Sheet","ALL", 'Range', 'B3:C14');

XYZ_measured  = data(31:end, 1:3);
XYZ_estimated = data(31:end, 6:8);

LAB_measured  = data(1:12, 1:3);
LAB_estimated = data(1:12, 6:8);

RGB_measured  = data(16:27, 1:3);
RGB_estimated = data(16:27, 6:8);


%% Least square error (LSE)
[m, n] = size(measured_data);

LSE = sum(sum((measured_data - estimated_data).^2));

%% Mean absolute error (MAE)

MAE = mean(abs(measured_data - estimated_data), 'all');

%% Mean square error (MSE)


MSE = mean(((measured_data - estimated_data).^2), "all");

%% Root mean square error (RMSE)

RMSE = sqrt(mean(((measured_data - estimated_data).^2),"all"));


%% Cosine-weighted RMSE

M_cos = measured_data .* cos(deg2rad(angles(:,1)));
E_cos = estimated_data.* cos(deg2rad(angles(:,1)));

sum_cos = mean((M_cos - E_cos).^2, "all");
RMSE_cos = sqrt(sum_cos);

%% PSNR


MSE_RGB = mean(((RGB_measured - RGB_estimated).^2), "all");

PSNR = 10 * log10((255^2) / MSE_RGB );


%% MAEPSNR

Mrgb_cos = RGB_measured .* cos(deg2rad(angles(:,1)));
Ergb_cos = RGB_estimated .* cos(deg2rad(angles(:,1)));

MAE_RGB = mean(abs(Mrgb_cos - Ergb_cos), "all");

MAEPSNR = 10 * log10 ((255^2) / MAE_RGB);

%% Delta E2000

del_E2000 = ciede2000(LAB_measured, LAB_estimated ,[1.5,1.2,0.8]);

mean_delE_D = mean(del_E2000);


%% To save the data

[filename, pathname] = uigetfile('*.xlsx', 'Select Excel File to Save Metrics');
if isequal(filename, 0)
    disp('User canceled file selection.');
else
    % Full path of the Excel file
    excelFullPath = fullfile(pathname, filename);
    
    %---------------------------
    % Extract sample name from the folder path
    % For example, if pathname is 'C:\Data\Blue Green\', sampleName will be 'Blue Green'
    folderParts = strsplit(strtrim(pathname), filesep);
    folderParts = folderParts(~cellfun('isempty', folderParts)); 
    sampleName = folderParts{end}; 

    %---------------------------
    % Prepare cell array with metric names and values
    % Row 1: sample name in A1.
    % Row 3: Headers ("Parameter" in column B and "Value" in column C).
    % Row 4 onward: Metric names in column B, corresponding values in column C.
    dataCell = {
        sampleName,      '',           '';       % Row 1: sample name in A1
        '',              '',           '';       % Row 2: blank
        '',         'Parameter',    'Value';     % Row 3: headers
        '',         'LSE',          LSE;         % Row 4
        '',         'MAE',          MAE;         % Row 5
        '',         'MSE',          MSE;         % Row 6
        '',         'RMSE',         RMSE;        % Row 7 (linear RMSE)
        '',         'CW_RMSE',      RMSE_cos;    % Row 8 (cosine-weighted RMSE)
        '',         'PSNR',         PSNR;        % Row 9
        '',         'MAEPSNR',      MAEPSNR;     % Row 10
        '',         'MeanDeltaE2000',   mean_delE_D; % Row 11
        '',         'AllDeltaE2000',   del_E2000;% Row 12
    };

    %---------------------------
    % Write the cell array to the chosen Excel file starting at cell A1
    writecell(dataCell, excelFullPath, 'Range','A1');
    
    disp('Metrics successfully saved to Excel file.');
end