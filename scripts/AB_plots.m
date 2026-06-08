clc; clear; close all

measured  = readmatrix("PATH_TO_RESULTS.xlsx", "Sheet","LAB,RGB,XYZ values", 'Range', 'B4:D15');
All_angles = readmatrix("PATH_TO_RESULTS.xlsx", "Sheet","General", 'Range', 'C5:D16');
a = measured(:,2);
b = measured(:,3);
lab_limits = [-100 100];

indices = find(All_angles(:,2) == 15);
mask = true(size(All_angles, 1), 1);
mask(indices) = false;

a_15 = a(indices);
b_15 = b(indices);

a_45 = a(mask);
b_45 = b(mask);


figure(1);
set(gcf, 'Position', [100, 100, 1200, 800]);
scatter(a_45, b_45, 180, 'filled', 'red', 'DisplayName', ['Viewing angle = 45', char(176)])
xlabel("a*", 'FontSize', 16, 'FontWeight', 'bold')
ylabel("b*", 'FontSize', 16, 'FontWeight', 'bold')
legend('Location', 'best', 'FontSize', 18) 
title("Measured LAB values", 'FontSize', 16, 'FontWeight', 'bold')
set(gca, 'FontSize', 20)
ax = gca;
ax.XAxisLocation = 'origin';
ax.YAxisLocation = 'origin';
xlim(lab_limits)
ylim(lab_limits)
box on
grid on

hold on
scatter(a_15, b_15, 180, 'filled', 'diamond','blue', 'DisplayName', ['Viewing angle = 15', char(176)])


% Separate the two groups based on the viewing angle in the second column
indices_15 = find(All_angles(:,2) == 15);  % Points with a 15° viewing angle
indices_45 = find(All_angles(:,2) == 45);  % Points with a 45° viewing angle

% Extract LAB values for each group
a_15 = a(indices_15);
b_15 = b(indices_15);
a_45 = a(indices_45);
b_45 = b(indices_45);

% Sort the 45° group in descending order (based on the first column)
[~, sortIdx_45] = sort(All_angles(indices_45, 1), 'descend');
a_45_sorted = a_45(sortIdx_45);
b_45_sorted = b_45(sortIdx_45);

% Sort the 15° group in descending order (based on the first column)
[~, sortIdx_15] = sort(All_angles(indices_15, 1), 'descend');
a_15_sorted = a_15(sortIdx_15);
b_15_sorted = b_15(sortIdx_15);

% Create the scatter plot
figure(2);
set(gcf, 'Position', [100, 100, 1200, 800]);

% Scatter and connect 45° points
% scatter(a_45, b_45, 150, 'filled', 'red', 'DisplayName', 'Viewing angle = 45°')
hold on
plot(a_45_sorted, b_45_sorted, '-o', 'Color', 'red', 'LineWidth', 3, 'DisplayName', ['Viewing angle = 45', char(176)])

% Scatter and connect 15° points
% scatter(a_15, b_15, 150, 'filled', 'diamond', 'blue', 'DisplayName', 'Viewing angle = 15°')
plot(a_15_sorted, b_15_sorted, '-diamond', 'Color', 'blue', 'LineWidth', 3, 'DisplayName', ['Viewing angle = 15', char(176)])

% Format the plot
xlabel("a*", 'FontSize', 16, 'FontWeight', 'bold')
ylabel("b*", 'FontSize', 16, 'FontWeight', 'bold')
legend('Location', 'best')
title("Measured LAB values", 'FontSize', 16, 'FontWeight', 'bold')
set(gca, 'FontSize', 20)
ax = gca;
ax.XAxisLocation = 'origin';
ax.YAxisLocation = 'origin';
xlim(lab_limits)
ylim(lab_limits)
box on
grid on

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
