clc; clear; close all;


% Get the BRDF of the samples measured by MA-T12 and their angles.
data = readmatrix("PATH_TO_RESULTS.xlsx", "Sheet","LAB,RGB,XYZ values", 'Range', 'B4:I21');
All_angles = readmatrix("PATH_TO_RESULTS.xlsx", "Sheet","LAB,RGB,XYZ values", 'Range', 'M4:N15');

%%

M_D = data(1:8, 1:3);
E_D = data(11:18, 1:3);

M_NS = data(1:4, 6:8);
E_NS = data(11:14, 6:8);


angles_NS  = All_angles(1:4, :);
angles_D = All_angles(5:end, :);
lab_limits = [-100 100];


%% To plot all the measurements

All_measured = cat(1, M_NS, M_D);
All_angles   = cat(1, angles_D, angles_NS);
num_points   = size(All_measured, 1);
markers = ['o', 's', 'd', '^', 'v', '>', '<', 'p', 'h', 'o', 's']; 
colors = lines(num_points);

figure(3);
set(gcf, 'Position', [100, 100, 1200, 800]);
hold on
scatter_handles = gobjects(num_points, 1);
for i = 1:num_points
    % Select marker and color for each point
    marker_style = markers(mod(i - 1, length(markers)) + 1); 
    color_style = colors(i, :); 

    % Scatter plot for each individual point
    scatter3(All_measured(i,2), All_measured(i,3), All_measured(i,1), ...
             250, color_style, marker_style, 'filled',...
             'DisplayName', sprintf('%d/%d', All_angles(i,1), All_angles(i,2)));
end

xlabel("a*", 'FontSize', 16, 'FontWeight', 'bold')
ylabel("b*", 'FontSize', 16, 'FontWeight', 'bold')
zlabel("L*", 'FontSize', 14, 'FontWeight', 'bold')
legend('Location', 'best') 
title("Measured LAB values: Gonio8", 'FontSize', 16, 'FontWeight', 'bold')
set(gca, 'FontSize', 16)
grid on
xlim(lab_limits)
ylim(lab_limits)
zlim([0 100])
ax = gca;
ax.XAxisLocation = 'origin';
ax.YAxisLocation = 'origin';
view([0, 90]) 
box on
hold off

%% To save all the figures

% % Open a folder selection dialog
% outputFolder = uigetdir('','Select a folder to save the figures');
% if outputFolder == 0
%     disp('No folder selected. Exiting...');
%     return;
% end
% 
% % Get all open figure handles
% figHandles = findall(0, 'Type', 'figure');
% 
% % Loop through each figure and save it to the selected folder
% for i = 1:length(figHandles)
%     % Set the current figure
%     fig = figHandles(i);
% 
%     % Create a filename for each figure
%     filename = fullfile(outputFolder, sprintf('Figure_%d.fig', i));
% 
%     % Save the figure as a PNG file
%     saveas(fig, filename);
% end
% 
% disp(['Figures saved to: ', outputFolder]);
