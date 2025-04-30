function plotNavigation(navSolutions, settings)
%Functions plots variations of coordinates over time and a 3D position
%plot. It plots receiver coordinates in UTM system or coordinate offsets if
%the true UTM receiver coordinates are provided.  
%
%plotNavigation(navSolutions, settings)
%
%   Inputs:
%       navSolutions    - Results from navigation solution function. It
%                       contains measured pseudoranges and receiver
%                       coordinates.
%       settings        - Receiver settings. The true receiver coordinates
%                       are contained in this structure.

%--------------------------------------------------------------------------
%                           SoftGNSS v3.0
% 
% Copyright (C) Darius Plausinaitis
% Written by Darius Plausinaitis
%--------------------------------------------------------------------------
%This program is free software; you can redistribute it and/or
%modify it under the terms of the GNU General Public License
%as published by the Free Software Foundation; either version 2
%of the License, or (at your option) any later version.
%
%This program is distributed in the hope that it will be useful,
%but WITHOUT ANY WARRANTY; without even the implied warranty of
%MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%GNU General Public License for more details.
%
%You should have received a copy of the GNU General Public License
%along with this program; if not, write to the Free Software
%Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301,
%USA.
%--------------------------------------------------------------------------

% CVS record:
% $Id: plotNavigation.m,v 1.1.2.25 2006/08/09 17:20:11 dpl Exp $

%% Plot results in the necessary data exists ==============================
if (~isempty(navSolutions))

    %% If reference position is not provided, then set reference position
    %% to the average postion
    if isnan(settings.truePosition.E) || isnan(settings.truePosition.N) ...
                                      || isnan(settings.truePosition.U)

        %=== Compute mean values ========================================== 
        % Remove NaN-s or the output of the function MEAN will be NaN.
        refCoord.E = mean(navSolutions.E(~isnan(navSolutions.E)));
        refCoord.N = mean(navSolutions.N(~isnan(navSolutions.N)));
        refCoord.U = mean(navSolutions.U(~isnan(navSolutions.U)));

        %Also convert geodetic coordinates to deg:min:sec vector format
        meanLongitude = dms2mat(deg2dms(...
            mean(navSolutions.longitude(~isnan(navSolutions.longitude)))), -5);
        meanLatitude  = dms2mat(deg2dms(...
            mean(navSolutions.latitude(~isnan(navSolutions.latitude)))), -5);

        refPointLgText = ['Mean Position\newline  Lat: ', ...
                            num2str(meanLatitude(1)), '{\circ}', ...
                            num2str(meanLatitude(2)), '{\prime}', ...
                            num2str(meanLatitude(3)), '{\prime}{\prime}', ...
                         '\newline Lng: ', ...
                            num2str(meanLongitude(1)), '{\circ}', ...
                            num2str(meanLongitude(2)), '{\prime}', ...
                            num2str(meanLongitude(3)), '{\prime}{\prime}', ...
                         '\newline Hgt: ', ...
                            num2str(mean(navSolutions.height(~isnan(navSolutions.height))), '%+6.1f')];
    else
        refPointLgText = 'Reference Position';
        refCoord.E = settings.truePosition.E;
        refCoord.N = settings.truePosition.N;
        refCoord.U = settings.truePosition.U;        
    end    
     
    figureNumber = 300;
    % The 300 is chosen for more convenient handling of the open
    % figure windows, when many figures are closed and reopened. Figures
    % drawn or opened by the user, will not be "overwritten" by this
    % function if the auto numbering is not used.
 
    %=== Select (or create) and clear the figure ==========================
    figure(figureNumber);
    clf   (figureNumber);
    set   (figureNumber, 'Name', 'Navigation solutions');
 
    %--- Draw axes --------------------------------------------------------
    handles(1, 1) = subplot(1, 1 ,1);
%     handles(3, 1) = subplot(4, 2, [5, 7]);
%     handles(3, 2) = subplot(4, 2, [6, 8]);    
 
%% Plot all figures =======================================================

% Extract latitude/longitude coordinates
llongitude = navSolutions.longitude;
llatitude  = navSolutions.latitude;
height= navSolutions.height;
po = [llatitude', llongitude',height'];
% po = [llatitude', llongitude'];  % 两列数据：纬度 | 经度

% 找出所有行中不含 0 的索引
non_zero_rows = all(po ~= 0, 2);  % 按行检查是否全非零

% 提取非零行
po = po(non_zero_rows, :);
% Reference point (true position)
truePosition = [22.328444770087565, 114.1713630049711,3];  % Position 1
% truePosition = [22.3198722, 114.209101777778];          % Position 2 (used)
 po=po';
% Calculate lat/lon/height differences
deltaLat = po(1,:) - truePosition(1);
deltaLon = po(2,:) - truePosition(2);
deltaHeight = po(3,:) - truePosition(3);

% Convert differences to meters
latMeters = deltaLat * 111320;  % 1 degree latitude ≈ 111,320 m
lonMeters = deltaLon * 111320 .* cosd(truePosition(1));  % Account for longitude convergence

% Calculate planar error
planeError = sqrt(lonMeters.^2 + latMeters.^2);

% Calculate 3D error
threeDError = sqrt(planeError.^2 + deltaHeight.^2);

% Save and output results
save('planeError.mat', 'planeError');
save('threeDError.mat', 'threeDError');  % Save 3D error
meanPlaneError = mean(planeError);
mean3DError = mean(threeDError);  % Calculate mean 3D error

fprintf('Mean Planar Error: %.2f meters\n', meanPlaneError);
fprintf('Mean 3D Error: %.2f meters\n', mean3DError);  % Output mean 3D error


load PL10.txt

time = 1:length(threeDError); % Time or fix number

% Plotting the Stanford Chart
figure;
plot(time, threeDError, 'b-', 'LineWidth', 1.5);
hold on;
yline(50, 'r--', 'Alarm Limit (50m)', 'LabelOrientation', 'horizontal');
xlabel('Time / GNSS Fix Number');
ylabel('Positioning Error (meters)');
title('GNSS Integrity Monitoring - Stanford Chart');
grid on;

% Analyze integrity performance
integrity_violations = sum(errors > 50);
total_fixes = length(errors);
integrity_rate = (total_fixes - integrity_violations) / total_fixes * 100;
disp(['Integrity Rate: ', num2str(integrity_rate), '%']);




plot(time, PL(:,1:size(time)), 'b-', 'LineWidth', 1.5);

% 加载保护水平数据
PL = load('PL10.txt'); 

% 定义警报限
AL = 50; % 警报限制

% 示例数据，替换为您的实际数据
PE = threeDError; % 3D误差数据
PL = PL(:, 1:size(PE, 2)); % 保护水平数据

% 初始化状态计数器
state_counts = zeros(6, 1);

% 状态分类逻辑
for i = 1:length(PE)
    pe = PE(i); 
    pl = PL(i);
    
    if pe < pl && pl < AL
        state_counts(1) = state_counts(1) + 1; % 正常操作
    elseif pe < AL && AL < pl
        state_counts(2) = state_counts(2) + 1; % 系统不可用1
    elseif AL < pe && pe < pl
        state_counts(3) = state_counts(3) + 1; % 系统不可用2
    elseif AL < pl && pl < pe
        state_counts(4) = state_counts(4) + 1; % 误导信息1
    elseif pl < pe && pe < AL
        state_counts(5) = state_counts(5) + 1; % 误导信息2
    elseif pl < AL && AL < pe
        state_counts(6) = state_counts(6) + 1; % 危险性误导
    end
end

% 创建图形
figure;
hold on;
M= 70;

% 绘制其他区域
fill([-1, AL, AL, -1], [-1, -1, AL, AL], [0.7, 0.9, 0.7], 'FaceAlpha', 0.5); % 正常操作上半部分
fill([-1, AL, AL, -1], [AL, AL, M, M], 'm', 'FaceAlpha', 0.5); % 系统不可用1
fill([AL, M, M, AL], [AL, AL, M, M], 'r', 'FaceAlpha', 0.5); % 系统不可用2
fill([AL, M, M, AL], [-1, -1, AL, AL], 'c', 'FaceAlpha', 0.5); % 误导信息1
fill([-1, M, M, -1], [-1, -1, AL, AL], [0.5, 0.8, 0.9], 'FaceAlpha', 0.5); % 误导信息2
fill([-1, AL, AL, -1], [-1, -1, AL, AL], [0.5, 0.5, 0.5], 'FaceAlpha', 0.5); % 危险性误导
% 绘制三角区域
fill([0, 50, 50], [0, 0, 50], [0.7, 0.9, 0.7], 'FaceAlpha', 0.5); % 填充三角区域
% 填充指定的三角区域
fill([50, 70, 70], [50, 50, 70], [0.7, 0.9, 0.7], 'FaceAlpha', 0.5); % 填充三角区域
% 绘制对角线
plot([0 M], [0 M], 'k--'); % 对角线，PE=PL的线

% 绘制警报限线
yline(AL, 'r--', 'Alert Limit (AL)', 'LabelOrientation', 'horizontal');
xline(AL, 'r--');

% 设置图形属性
xlabel('Position Error (PE) [m]');
ylabel('Protection Level (PL) [m]');
title('Stanford Chart Analysis');
xlim([0 M]);
ylim([0 M]);
grid on;

% 添加状态计数到图中
text(10, 10, sprintf('%d', state_counts(1)), 'Color', 'black', 'FontSize', 12); % 正常操作
text(10, 60, sprintf('%d', state_counts(2)), 'Color', 'black', 'FontSize', 12); % 系统不可用1
text(60, 60, sprintf('%d', state_counts(3)), 'Color', 'black', 'FontSize', 12); % 系统不可用2
text(60, 10, sprintf('%d', state_counts(4)), 'Color', 'black', 'FontSize', 12); % 误导信息1
text(10, 30, sprintf('%d', state_counts(5)), 'Color', 'black', 'FontSize', 12); % 误导信息2
text(60, 30, sprintf('%d', state_counts(6)), 'Color', 'black', 'FontSize', 12); % 危险性误导

% 添加区域标注
text(20, 20, 'Nominal Operations', 'Color', 'black', 'FontSize', 12);
text(20, 80, 'System Unavailable 1', 'Color', 'black', 'FontSize', 12);
text(70, 80, 'System Unavailable 2', 'Color', 'black', 'FontSize', 12);
text(70, 20, 'Misleading Info 1', 'Color', 'black', 'FontSize', 12);
text(20, 40, 'Misleading Info 2', 'Color', 'black', 'FontSize', 12);
text(70, 40, 'Hazardously Misleading', 'Color', 'black', 'FontSize', 12);

hold off;

% 附加分析: 计算各状态下平均PE/PL
PE_mean = zeros(6,1); PL_mean = zeros(6,1);
for s = 1:6
    mask = false(size(time));
    % 重建各状态的逻辑条件
    switch s
        case 1, mask = (PE < PL) & (PL < AL);
        case 2, mask = (PE < AL) & (AL < PL);
        case 3, mask = (AL < PE) & (PE < PL);
        case 4, mask = (AL < PL) & (PL < PE);
        case 5, mask = (PL < PE) & (PE < AL);
        case 6, mask = (PL < AL) & (AL < PE);
    end
    PE_mean(s) = mean(PE(mask));
    PL_mean(s) = mean(PL(mask));
end

% 显示各状态下的平均误差
disp('===== 各状态下平均数值 =====');
fprintf('%-35s %-10s %-10s\n', '状态', '平均PE', '平均PL');
for s = 1:6
    fprintf('%-35s %-10.2f %-10.2f\n', state_names{s}(1:35), PE_mean(s), PL_mean(s));
end




% 创建一个新的图形窗口
figure;

% 绘制散点图，颜色表示平面误差
scatter(po(1,:), po(2,:), 50, planeError, 'filled');
hold on;
plot(truePosition(1), truePosition(2), 'ro', 'MarkerSize', 10, 'DisplayName', 'True Position');
% 添加颜色条
colorbar;
colormap('jet'); % 使用 'jet' 颜色映射

% 添加图例和标签
xlabel('East Error (meters)');
ylabel('North Error (meters)');
title('Scatter Plot of ENU Errors with Plane Error Color');
legend('Location', 'best');
grid on;
hold off;


% 提取东、北、天坐标
EE = navSolutions.E;
NN = navSolutions.N;
UU = navSolutions.U;

% 计算速度
% 速度 = 位置差 / 时间差
% 由于时间间隔为 1 秒，速度就是相邻位置的差异
vE = diff(EE); % 东向速度
vN = diff(NN); % 北向速度
vU = diff(UU); % 天向速度

% 创建时间向量，注意速度向量比位置向量少一个元素
time = 1:length(vE);

% 创建一个新的图形窗口
figure;

% 绘制东向速度
subplot(3, 1, 1); % 3行1列的第1个子图
plot(time, vE, 'b');
xlabel('Time (s)');
ylabel('East Velocity (m/s)');
title('East Velocity Over Time');
grid on;

% 绘制北向速度
subplot(3, 1, 2); % 3行1列的第2个子图
plot(time, vN, 'g');
xlabel('Time (s)');
ylabel('North Velocity (m/s)');
title('North Velocity Over Time');
grid on;

% 绘制天向速度
subplot(3, 1, 3); % 3行1列的第3个子图
plot(time, vU, 'r');
xlabel('Time (s)');
ylabel('Up Velocity (m/s)');
title('Up Velocity Over Time');
grid on;



end