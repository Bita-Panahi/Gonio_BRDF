% This code is for the MAT12 measurements. The separation method is used
% here. Near-specular part is trained with the NS measurements and the
% model itself with CWRMSE, and the diffuse part is trained with the
% diffuse measurements using the model and the LOG of the measured and
% estiamted in the cost function which is CWRMSE. This means that, the log
% of the measurements and estimations are used in the cost function for the
% diffuse part. 
% In this code, the leave-one-out method is being used.

clc; clear; close all;

% Get the BRDF of the samples measured by MA-T12 and their angles.

sample_data = readmatrix("PATH_TO_EXCEL.xlsx", "Sheet","ALL", 'Range', 'E3:AI14');
angles = readmatrix("PATH_TO_EXCEL.xlsx", "Sheet","ALL", 'Range', 'B3:C14');

alpha = 0.045;
wavelength = 400:10:700;
luminance_threshold = 2000;


%% Set the threshold for diffuse and near-specular

tolerance = 15;
indices = [];  

% Loop to find indices where detector angle is within tolerance of source angle
for i = 1:length(angles)
    if ((angles(i,1) - tolerance) <= angles(i,2)) && (angles(i,2) <= (angles(i,1) + tolerance))
        indices(end+1) = i;  
    end
end

% Create a logical mask with all elements set to true
mask = true(size(sample_data, 1), 1); 

% Set the specified indices to false (rows to exclude)
mask(indices) = false;

% Create new arrays with only the remaining rows (excluding the specified indices)
D_data = sample_data(mask, :);
D_angles = angles(mask, :);

NS_data = sample_data(indices,:);
NS_angles = angles(indices,:);

%% GA for near specular

problem.CostFunction = @objectivefun_NS;
problem.nVar = 62;
problem.VarMin = ones(1,62)*0.5;
problem.VarMax = ones(1,62)*6;

params.MaxIt = 1000;
params.nPop = 3000;

params.beta = 1;
params.pC = 1;
params.gamma = 0.1;
params.mu = 0.02;
params.sigma = 0.3;

out_NS = RunGAa(problem, params);

%% GA for diffuse
problem.CostFunction = @objectivefun_D;
problem.nVar = 62;
problem.VarMin = ones(1,62)*0.5;
problem.VarMax = ones(1,62)*6;

params.MaxIt = 1000;
params.nPop = 3000;

params.beta = 1;
params.pC = 1;
params.gamma = 0.1;
params.mu = 0.02;
params.sigma = 0.3;

out_D = RunGAa(problem, params);

%% Leave-One-Out Cross-Validation for Near-Specular
% Leave-One-Out for near-specular angles
num_NS = size(NS_data, 1);


for i = 1:num_NS
    % Exclude one measurement
    train_data_NS = NS_data([1:i-1, i+1:end], :);
    train_angles_NS = NS_angles([1:i-1, i+1:end], :);
    test_data_NS = NS_data(i, :);
    test_angle_NS = NS_angles(i, :);

    % Perform optimization on training data
    problem.CostFunction = @objectivefun_NS;
    x0 = out_NS.bestsol.Position; % Initial guess
    LB = [zeros(1, 31), ones(1, 31) * -10];
    UB = [ones(1, 31) * 40, ones(1, 31) * 40];
    options = optimoptions('lsqnonlin', 'MaxIterations', 1e10);

    [NS_param, ~] = lsqnonlin(problem.CostFunction, x0, LB, UB, options);

    % Test the excluded measurement
    New_NS(i, :) = MAT12_gonio_brdf(test_angle_NS, alpha, NS_param);
end

x0_NS = out_NS.bestsol.Position; % Initial guess
LB_NS = [zeros(1, 31), ones(1, 31) * -8];
UB_NS = [ones(1, 31) * 40, ones(1, 31) * 40];
options_NS = optimoptions('lsqnonlin', 'MaxIterations', 1e10);
[NS_param_final, NS_fval] = lsqnonlin(@objectivefun_NS, x0_NS, LB_NS, UB_NS, options_NS);


%% Leave-One-Out Cross-Validation for Diffuse
num_D = size(D_data, 1); % Number of diffuse measurements


for i = 1:num_D
    % Exclude one diffuse measurement
    train_data_D = sample_data; 
    train_angles_D = angles;   
   
    % Remove the current diffuse measurement from training
    train_data_D(i, :) = [];
    train_angles_D(i, :) = [];
    
    % The excluded diffuse measurement for testing
    test_data_D = D_data(i, :);
    test_angle_D = D_angles(i, :);

    % Perform optimization on training data (all measurements excluding the current diffuse one)
    problem.CostFunction = @objectivefun_D;
    x0 = out_D.bestsol.Position; 
    LB = [zeros(1, 31), ones(1, 31) * -20]; % Lower bounds
    UB = [ones(1, 31) * 1500, ones(1, 31) * 50]; % Upper bounds
    options = optimoptions('lsqnonlin', 'MaxIterations', 1e10);

    % Optimize parameters for training data
    [D_param, ~] = lsqnonlin(problem.CostFunction, x0, LB, UB, options);

    % Predict for the excluded measurement
    New_D(i, :) = MAT12_gonio_brdf(test_angle_D, alpha, D_param);

end


x0_D = out_D.bestsol.Position; % Initial guess
LB_D = [zeros(1, 31), ones(1, 31) * -20];
UB_D = [ones(1, 31) * 1500, ones(1, 31) * 50];
options_D = optimoptions('lsqnonlin', 'MaxIterations', 1e10);
[D_param_final, D_fval] = lsqnonlin(@objectivefun_D, x0_D, LB_D, UB_D, options_D);

%% All the measurements and estimations

Final_measured = cat(1, NS_data, D_data);
Final_angles   = cat(1, NS_angles, D_angles);
Final_estimated= cat(1, New_NS, New_D);

%% Plot the near-specular and diffuse parameters 

figure(1);
set(gcf, 'Units', 'normalized', 'Position', [0.2 0.2 0.4 0.6]);
plot(wavelength, NS_param_final(1:31), 'Color','b','LineWidth',1.5, 'DisplayName','Optimized rho\_NS');
hold on;
plot(wavelength, NS_param_final(32:end), 'Color','r','LineWidth',1.5, 'DisplayName','Optimized c\_NS');
xlabel("Wavelength",'FontSize',14)
ylabel("Parameter",'FontSize',14)
title("Optimized parameters for near-specular angles",'FontSize',14)
grid("on");
box on
lgd = legend;
lgd.FontSize = 14;
set(gca, 'FontSize',14); 


figure(2);
set(gcf, 'Units', 'normalized', 'Position', [0.2 0.2 0.4 0.6]);
plot(wavelength, D_param_final(1:31), 'Color','b', 'LineWidth',1.5,'DisplayName','Optimized rho\_D');
hold on;
plot(wavelength, D_param_final(32:end), 'Color','r','LineWidth',1.5, 'DisplayName','Optimized c\_D');
xlabel("Wavelength",'FontSize',14)
ylabel("Parameter",'FontSize',14)
title("Optimized parameters for diffuse angles",'FontSize',14)
grid("on");
box on
lgd = legend;
lgd.FontSize = 14; 
set(gca, 'FontSize',14);

%% Plot the measured and estimated
angle_labels = arrayfun(@(i) sprintf('%d/%d', Final_angles(i, 1), Final_angles(i, 2)), 1:size(Final_angles, 1), 'UniformOutput', false);
markers = {'o', '+', '*', 's', 'd', 'x', '^', 'v', '>', '<', 'p', 'h'};


figure(3);
set(gcf, 'Units', 'normalized', 'Position', [0.1 0.1 0.5 0.7]);
hold on;
for i = 1:size(Final_angles, 1)
    plot(wavelength, Final_measured(i, :), 'Marker', markers{mod(i-1, length(markers)) + 1}, ...
         'LineWidth', 1.2,'MarkerSize',7,'DisplayName', angle_labels{i}, 'LineStyle', '-');
end
title('Measured BRDF, All');
xlabel('Wavelength');
ylabel('BRDF');
legend('show', 'Location', 'best');
grid("on");
box on
lgd = legend;
lgd.FontSize = 14; 
set(gca, 'FontSize',14);
hold off;


figure(4);
set(gcf, 'Units', 'normalized', 'Position', [0.1 0.1 0.5 0.7]);
hold on;
for i = 1:size(Final_angles, 1)
    plot(wavelength, Final_estimated(i, :), 'Marker', markers{mod(i-1, length(markers)) + 1}, ...
         'LineWidth', 1.2,'MarkerSize',7,'DisplayName', angle_labels{i}, 'LineStyle', '-');
end
title('Estimated BRDF, All');
xlabel('Wavelength');
ylabel('BRDF');
legend('show', 'Location', 'best');
grid("on");
box on
lgd = legend;
lgd.FontSize = 14;
set(gca, 'FontSize',14); 
hold off;

%%
% XYZ and RGB calculations

D65 = readmatrix("D65_10nm.xlsx", 'Range', 'B4:B34')/100;
xbar = readmatrix("CMF_2deg_5nm.xlsx", 'Range', 'B10:B70');
xbar = xbar(1:2:end);
ybar = readmatrix("CMF_2deg_5nm.xlsx", 'Range', 'C10:C70');
ybar = ybar(1:2:end);
zbar = readmatrix("CMF_2deg_5nm.xlsx", 'Range', 'D10:D70');
zbar = zbar(1:2:end);

k = 100 / sum (D65' * ybar);


%% XYZ RGB All

[m,n] = size(Final_measured);

for i = 1:m
    XYZ_measured(i,1) = k * sum (D65 .* xbar .* Final_measured(i,:)');
    XYZ_measured(i,2) = k * sum (D65 .* ybar .* Final_measured(i,:)');
    XYZ_measured(i,3) = k * sum (D65 .* zbar .* Final_measured(i,:)');
end

for i = 1:m
    XYZ_estimated(i,1) = k * sum (D65 .* xbar .* Final_estimated(i,:)');
    XYZ_estimated(i,2) = k * sum (D65 .* ybar .* Final_estimated(i,:)');
    XYZ_estimated(i,3) = k * sum (D65 .* zbar .* Final_estimated(i,:)');
end


% sRGB of the measured sample
for x = 1:m
    RGB_measured(x,:) = xyz2srgb(XYZ_measured(x,:));
end

% sRGB of the fitted sample
for b = 1:m
    RGB_estimated(b,:) = xyz2srgb(XYZ_estimated(b,:));
end


%% RGB patches ALL
figure(7)
set(gcf, 'Units', 'normalized', 'Position', [0.5 0.5 0.9 1]);
showpatchgrid(RGB_measured(:,:)/255, [2 6], 60) 
hold on  

% Add the corresponding angles as text on each patch
for i = 1:m
    col = ceil(i / 2);
    row = mod(i-1, 2) + 1;  

    % Coordinates for placing the text in the middle of the patch
    x_pos = (col - 0.5) * 60; 
    y_pos = (row - 0.5) * 60; 

    % Get the corresponding angles for the current patch
    source_angle = Final_angles(i, 1);
    detector_angle = Final_angles(i, 2);

    % Format the text as 'source_angle/detector_angle'
    angle_text = sprintf('%d/%d', source_angle, detector_angle);

    % Get the background color of the current patch 
    patch_color_measured = RGB_measured(i, :);
    
    % Calculate the luminance of the background color
    luminance_M = calculate_luminance(patch_color_measured * 255); 

    % Choose text color based on luminance
    if luminance_M < luminance_threshold
        text_color = 'white';  % Use light text on dark backgrounds
    else
        text_color = 'black';  % Use dark text on light backgrounds
    end
    % Add the text to the figure with appropriate size and formatting
    text(x_pos, y_pos, angle_text, 'HorizontalAlignment', 'center', ...
        'VerticalAlignment', 'middle', 'FontSize', 8, 'Color', 'white', 'FontWeight', 'bold');
end
title("Measured")
set(gca, 'FontSize',12);
hold off  
figure(8)
set(gcf, 'Units', 'normalized', 'Position', [0.5 0.5 0.9 1]);
showpatchgrid(RGB_estimated(:,:)/255, [2 6], 60) 

hold on  
% Add the corresponding angles as text on each patch
for i = 1:m
    % Compute the row and column for the current patch (since we want to fill columns first)
    col = ceil(i / 2);  
    row = mod(i-1, 2) + 1;  

    % Coordinates for placing the text in the middle of the patch
    x_pos = (col - 0.5) * 60;  
    y_pos = (row - 0.5) * 60; 
    % Get the corresponding angles for the current patch
    source_angle = Final_angles(i, 1);
    detector_angle = Final_angles(i, 2);

    % Format the text as 'source_angle/detector_angle'
    angle_text = sprintf('%d/%d', source_angle, detector_angle);

    % Get the background color of the current patch (assumed to be RGB values in 0-255 range)
    patch_color_Estimated = RGB_estimated(i, :);
    
    % Calculate the luminance of the background color
    luminance_E = calculate_luminance(patch_color_Estimated * 255); 
    % Choose text color based on luminance
    if luminance_E < luminance_threshold
        text_color = 'white';  % Use light text on dark backgrounds
    else
        text_color = 'black';  % Use dark text on light backgrounds
    end
    % Add the text to the figure with appropriate size and formatting
    text(x_pos, y_pos, angle_text, 'HorizontalAlignment', 'center', ...
        'VerticalAlignment', 'middle', 'FontSize', 8, 'Color', 'white', 'FontWeight', 'bold');
end
title("Estimated")
set(gca, 'FontSize',12);
hold off 

%% LAB All

% LAB measured
for z = 1:m
    LAB_measured(z,:) = xyz2lab(XYZ_measured(z,:));
end

% LAB fitted
for l = 1:m
    LAB_estimated(l,:) = xyz2lab(XYZ_estimated(l,:));
end

% CIEDE2000 color difference
del_E2000_LAB = ciede2000(LAB_measured,LAB_estimated,[1.5,1.2,0.8]);

% Mean delta E for the diffuse angles since we are using the log function.

mean_delE = mean(del_E2000_LAB);


%% To save all the figures

% Open a folder selection dialog
outputFolder = uigetdir('','Select a folder to save the figures');
if outputFolder == 0
    disp('No folder selected. Exiting...');
    return;
end

% Get all open figure handles
figHandles = findall(0, 'Type', 'figure');

% Loop through each figure and save it to the selected folder
for i = 1:length(figHandles)
    % Set the current figure
    fig = figHandles(i);
    
    % Create a filename for each figure
    filename = fullfile(outputFolder, sprintf('Figure_%d.fig', i));
    
    % Save the figure as a PNG file
    saveas(fig, filename);
end

disp(['Figures saved to: ', outputFolder]);


%% To save in Excel
% Open a file selection dialog to choose the Excel file for saving
[filename, pathname] = uiputfile('*.xlsx', 'Select Excel file to save results');
if isequal(filename,0)
    disp('User canceled file selection.');
else
    fullFileName = fullfile(pathname, filename);
    
    % Write Final_estimated to sheet "New - Estimations" in range B4:AF15
    xlswrite(fullFileName, Final_estimated, 'New - Estimations', 'B4:AF15');
    
    % Write Final_angles to sheet "General" in range C5:D16
    xlswrite(fullFileName, Final_angles, 'General', 'C5:D16');
    
    % --- LAB, RGB, XYZ values in sheet "LAB,RGB,XYZ values" ---
    % LAB values: LAB_measured_final in B4:D15, LAB_estimated_final in G4:I15
    xlswrite(fullFileName, LAB_measured, 'LAB,RGB,XYZ values', 'B4:D15');
    xlswrite(fullFileName, LAB_estimated, 'LAB,RGB,XYZ values', 'G4:I15');
    
    % RGB values: RGB_measured_final in B19:D30, RGB_estimated_final in G19:I30
    xlswrite(fullFileName, RGB_measured, 'LAB,RGB,XYZ values', 'B19:D30');
    xlswrite(fullFileName, RGB_estimated, 'LAB,RGB,XYZ values', 'G19:I30');
    
    % XYZ values: XYZ_measured_final in B33:D44, XYZ_estimated_final in G33:I44
    xlswrite(fullFileName, XYZ_measured, 'LAB,RGB,XYZ values', 'B34:D45');
    xlswrite(fullFileName, XYZ_estimated, 'LAB,RGB,XYZ values', 'G34:I45');
    
    % --- NS_param_final in sheet "General" ---
    % Assuming NS_param_final is a vector of 62 values:
    NS_param_first31 = NS_param_final(1:31);  % first 31 values
    NS_param_next31  = NS_param_final(32:62); % next 31 values
    xlswrite(fullFileName, NS_param_first31, 'General', 'J4:AN4');
    xlswrite(fullFileName, NS_param_next31, 'General', 'J6:AN6');
    
    % D param final
    D_param_first31 = D_param_final(1:31);  % first 31 values
    D_param_next31  = D_param_final(32:62); % next 31 values
    xlswrite(fullFileName, D_param_first31, 'General', 'J9:AN9');
    xlswrite(fullFileName, D_param_next31, 'General', 'J11:AN11');
    
    % --- del_E2000_LAB_final in sheet "General" ---
    xlswrite(fullFileName, del_E2000_LAB, 'General', 'F5:F16');
    xlswrite(fullFileName, mean_delE, 'General', 'F18');

    % --- Name of the sample
    folderParts = strsplit(strtrim(pathname), filesep);
    folderParts = folderParts(~cellfun('isempty', folderParts));  % remove empty cells
    sampleName = folderParts{end};  % last non-empty folder name
    xlswrite(fullFileName, {sampleName}, 'General', 'A1');

    
    disp(['Results saved to ', fullFileName]);
end


%% Cost functions

function f = objectivefun_NS(x)
    angles = evalin('base','NS_angles'); % Angles for near specular
    R = evalin('base', 'NS_data');       % BRDF for near specular
    alpha = evalin('base', 'alpha');
    g = MAT12_gonio_brdf(angles, alpha, x); % The main model and formula

    Rcos = R .* cos(deg2rad(angles(:,1)));
    gcos = g .* cos(deg2rad(angles(:,1)));

    sum_cos = mean((Rcos - gcos).^2, "all");
    f = sqrt(sum_cos);
    % for i = 1:length(angles)
    %     f_value(i,:) = sqrt(sum(((R(i,:).*cos(deg2rad(angles(i,1))) - g(i,:).*cos(deg2rad(angles(i,1)))).^2))/length(R));
    % end
    % f = mean(f_value,"all");

end


function f = objectivefun_D(x)
    angles = evalin('base','angles');
    R = evalin("base", 'sample_data');
    % angles = evalin('base','D_angles');
    % R = evalin("base", 'D_data');
    alpha = evalin('base', 'alpha');
    g = MAT12_gonio_brdf(angles, alpha, x);

    Rcos = log(R) .* cos(deg2rad(angles(:,1)));
    gcos = log(g) .* cos(deg2rad(angles(:,1)));

    sum_cos = mean((Rcos - gcos).^2, "all");
    f = sqrt(sum_cos);


    % Cosine weighted RMSE
    % for i = 1:length(angles)
    %     f_value(i,:) = sqrt(sum(((log(R(i,:)).*cos(deg2rad(angles(i,1))) - log(g(i,:)).*cos(deg2rad(angles(i,1)))).^2))/length(R));
    % end
    % f = mean(f_value,"all");

end


% Function to calculate luminance of an RGB color
function luminance = calculate_luminance(rgb_color)
    R = rgb_color(1);
    G = rgb_color(2);
    B = rgb_color(3);
    luminance = 0.299 * R + 0.587 * G + 0.114 * B;  % Calculate luminance
end