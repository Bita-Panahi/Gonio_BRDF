clc;clear;close all;

% These are the obtained results in this paper -- change them to your own
% results.
DeltaE_Original = [12.856, 16.986, 2.423, 3.200, 19.662, 14.776, 12.557, 15.303, 23.649, 5.635, 6.008, 7.172];
DeltaE_Estimate = [7.971, 12.243, 4.387, 2.919, 13.751,10.820, 10.228, 10.712, 16.777, 2.885, 4.606, 5.215];
MCDM = [14.14, 17.76, 7.67, 8.08, 19.87, 16.51, 16.12, 4.53, 19.21, 5.60, 8.18, 9.57];


Y1 = [MCDM', DeltaE_Estimate'];
figure(1);
figure('Units','normalized','OuterPosition',[0.1,0.1,0.8,0.9]);
bar(Y1, 1 ,'grouped');
colororder("default")
xticks(1:12);
xtickangle(25)
xticklabels ({'Gonio01', 'Gonio02', 'Gonio03', 'Gonio04', 'Gonio05', 'Gonio06', 'Gonio07', 'Gonio08', 'Cham011', 'Pritned Gonio Gold', 'Printed Gonio Red', 'Blue Green'});
xlabel('Samples','FontSize', 16);
ylabel('\DeltaE_2_0_0_0','FontSize', 16);
title('Relation between MCDM and CIEDE_2_0_0_0 color difference using our model','FontSize', 26);
ax = gca;
ax.FontSize = 30;
legend({'Our Model', 'MCDM'}, 'Location','best', 'FontSize',20);
grid on
ax.GridLineWidth = 2;
box on

corelation = corrcoef(MCDM, DeltaE_Estimate);
figure(2)
figure('Units','normalized','OuterPosition',[0.1,0.1,0.8,0.9]);
scatter(MCDM, DeltaE_Estimate, 250,'black', 'filled')
xlabel('MCDM','FontSize', 16);
ylabel('\DeltaE_2_0_0_0','FontSize', 16);
ylim([0 20])
title('Correlation between MCDM and CIEDE_2_0_0_0 color difference using our model','FontSize', 26);
ax = gca;
ax.FontSize = 30;

grid on
grid minor
ax.GridLineWidth = 2;
box on
hold on
% 2. Compute best-fit line (linear regression)
p = polyfit(MCDM, DeltaE_Estimate, 1);  
yfit = polyval(p, MCDM); 

% Plot the best-fit line
figure(3)
plot(MCDM, yfit, 'b--', 'LineWidth', 4);

[R, p_value, RL, RU] = corrcoef(MCDM, DeltaE_Estimate);
r_value = R(1,2); 
%%
X = MCDM;
Y = DeltaE_Estimate;
n = length(X);            % number of data points
yResid = Y - yfit;        % residuals
SSresid = sum(yResid.^2); % sum of squared residuals
df = n - 2;               % degrees of freedom (for linear fit)
MSE = SSresid / df;       % mean squared error of residuals

xbar = mean(X);           
Sxx  = sum((X - xbar).^2);

% Generate a dense set of x-values to plot the smooth CI region
xfit = linspace(min(X), max(X), 100);
yfit_line = polyval(p, xfit);

% t-critical for (1 - alpha/2) with df degrees of freedom
alpha = 0.05; 
tval = tinv(1 - alpha/2, df);

% Standard error of the predicted y-value at each xfit

SE = sqrt(MSE * (1/n + (xfit - xbar).^2 / Sxx));
delta = tval * SE;

% Compute the upper and lower confidence bounds
yfit_upper = yfit_line + delta;
yfit_lower = yfit_line - delta;

% Instead of fill(), just plot upper and lower CI lines
plot(xfit, yfit_upper, 'r:', 'LineWidth', 2.5);
plot(xfit, yfit_lower, 'r:', 'LineWidth', 2.5);

legend('Data Points', 'Fitted Line','95% CI','Location','best');


% Replot the regression line on top of the CI lines
% plot(xfit, yfit_line, 'r--', 'LineWidth', 2);