% Select the main folder
rootFolder = uigetdir('', 'Select the main folder');
if rootFolder == 0
    disp('No folder selected. Exiting...');
    return;
end

% Your chosen font sizes
newAxesFontSize   = 26;   
newTextFontSize   = 26;  
newLegendFontSize = 22; 

% Find all .fig files (including subfolders)
figFiles = dir(fullfile(rootFolder, '**', '*.fig'));

for k = 1:numel(figFiles)
    % Path to the .fig
    figPath = fullfile(figFiles(k).folder, figFiles(k).name);

    % Open invisibly
    figHandle = openfig(figPath, 'invisible');

    % -----------------------
    % 1) Axes (ticks, titles, labels)
    axesHandles = findall(figHandle, 'Type', 'axes');
    set(axesHandles, 'FontSize', newAxesFontSize);
    % Make sure titles and axis‐labels also get resized
    set([axesHandles.Title],  'FontSize', newAxesFontSize);
    set([axesHandles.XLabel], 'FontSize', newAxesFontSize);
    set([axesHandles.YLabel], 'FontSize', newAxesFontSize);

    % 2) Any free‐standing text objects
    textHandles = findall(figHandle, 'Type', 'text');
    set(textHandles, 'FontSize', newTextFontSize);

    % 3) Legends
    legendHandles = findall(figHandle, 'Type', 'Legend');
    set(legendHandles, 'FontSize', newLegendFontSize);
    % -----------------------

    % Ensure printed size matches on‐screen size
    set(figHandle, 'PaperPositionMode', 'auto');

    % Build the .eps filename
    [~, baseName, ~] = fileparts(figFiles(k).name);
    outputFile = fullfile(figFiles(k).folder, [baseName, '.eps']);

    % Export as vector EPS with no rasterizing
    print(figHandle, outputFile, '-depsc2', '-r0');

    close(figHandle);
end

disp('All .fig files have been converted to high‑quality .eps with updated fonts.');
