function plotUrbanResults(trackResults, navSolutions, settings, skymask_data)
    % plotUrbanResults - 绘制城市环境下GNSS结果的分析图
    
    %% 1. 计算ENU位置误差
    % 检查必要的字段是否存在
    if ~isfield(settings, 'refX') || ~isfield(settings, 'refY') || ~isfield(settings, 'refZ')
        error('Reference coordinates not found in settings');
    end
    
    if ~isfield(navSolutions, 'X') || ~isfield(navSolutions, 'Y') || ~isfield(navSolutions, 'Z')
        error('Position solutions not found in navSolutions');
    end

    % 计算ENU误差
    numEpochs = length(navSolutions.X);
    E = zeros(1, numEpochs);
    N = zeros(1, numEpochs);
    U = zeros(1, numEpochs);
    
    for i = 1:numEpochs
        % ECEF坐标差值
        dX = navSolutions.X(i) - settings.refX;
        dY = navSolutions.Y(i) - settings.refY;
        dZ = navSolutions.Z(i) - settings.refZ;
        
        % 转换到ENU坐标系
        [E(i), N(i), U(i)] = ecef2enu(dX, dY, dZ, settings.refLat, settings.refLon);
    end

    %% 2. 创建位置误差图
    figure('Name', 'Urban GNSS Results - Position');
    
    % East误差
    subplot(3,1,1)
    plot(1:length(E), E, 'b.', 'MarkerSize', 3);
    grid on;
    xlabel('Epochs');
    ylabel('East Error (m)');
    title('Position Error in East Direction');
    
    % North误差
    subplot(3,1,2)
    plot(1:length(N), N, 'g.', 'MarkerSize', 3);
    grid on;
    xlabel('Epochs');
    ylabel('North Error (m)');
    title('Position Error in North Direction');
    
    % Up误差
    subplot(3,1,3)
    plot(1:length(U), U, 'r.', 'MarkerSize', 3);
    grid on;
    xlabel('Epochs');
    ylabel('Up Error (m)');
    title('Position Error in Up Direction');

    %% 3. 创建DOP和卫星数量图
    figure('Name', 'Urban GNSS Results - Satellites & DOP');
    
    % DOP值
    subplot(2,1,1)
    if isfield(navSolutions, 'DOP')
        % 检查DOP数据结构
        if isstruct(navSolutions.DOP)
            t = 1:length(navSolutions.DOP.GDOP);
            plot(t, navSolutions.DOP.GDOP, 'b-', ...
                 t, navSolutions.DOP.PDOP, 'g-', ...
                 t, navSolutions.DOP.HDOP, 'r-', ...
                 t, navSolutions.DOP.VDOP, 'k-');
        else
            % 如果DOP是矩阵形式
            t = 1:size(navSolutions.DOP,1);
            plot(t, navSolutions.DOP);
        end
        grid on;
        legend('GDOP', 'PDOP', 'HDOP', 'VDOP');
        xlabel('Epochs');
        ylabel('DOP Values');
        title('Dilution of Precision');
    end
    
    % 可用卫星数量
    subplot(2,1,2)
    if isfield(navSolutions, 'numSats')
        plot(1:length(navSolutions.numSats), navSolutions.numSats, 'b.-');
        grid on;
        xlabel('Epochs');
        ylabel('Number of Satellites');
        title('Number of Available Satellites');
    end

    %% 4. 创建天空图
    figure('Name', 'Urban GNSS Results - Skyplot');
    
    % 创建极坐标图
    polaraxes;
    hold on;
    
    % 绘制天空遮罩
    polarplot(deg2rad(skymask_data(:,1)), 90-skymask_data(:,2), 'r-', 'LineWidth', 2);
    
    % 设置极坐标图的属性
    rlim([0 90]);
    rticks([0 15 30 45 60 75 90]);
    rticklabels({'90°','75°','60°','45°','30°','15°','0°'});
    thetaticks(0:30:330);
    thetaticklabels({'N','30°','60°','E','120°','150°','S','210°','240°','W','300°','330°'});
    title('Satellite Skyplot with Urban Mask');
    grid on;

    %% 5. 创建误差统计图
    figure('Name', 'Urban GNSS Results - Error Statistics');
    
    % 计算水平误差和3D误差
    error2D = sqrt(E.^2 + N.^2);
    error3D = sqrt(E.^2 + N.^2 + U.^2);
    
    % 水平误差分布
    subplot(2,1,1)
    histogram(error2D, min(30,ceil(sqrt(length(error2D)))), 'Normalization', 'probability');
    grid on;
    xlabel('Horizontal Error (m)');
    ylabel('Probability');
    title('Horizontal Error Distribution');
    
    % 3D误差分布
    subplot(2,1,2)
    histogram(error3D, min(30,ceil(sqrt(length(error3D)))), 'Normalization', 'probability');
    grid on;
    xlabel('3D Error (m)');
    ylabel('Probability');
    title('3D Error Distribution');

    %% 6. 打印统计信息
    fprintf('\nPosition Error Statistics:\n');
    fprintf('East Error (m)  - Mean: %.2f, Std: %.2f, RMS: %.2f\n', ...
        mean(E), std(E), rms(E));
    fprintf('North Error (m) - Mean: %.2f, Std: %.2f, RMS: %.2f\n', ...
        mean(N), std(N), rms(N));
    fprintf('Up Error (m)    - Mean: %.2f, Std: %.2f, RMS: %.2f\n', ...
        mean(U), std(U), rms(U));
    fprintf('2D Error (m)    - Mean: %.2f, Std: %.2f, RMS: %.2f\n', ...
        mean(error2D), std(error2D), rms(error2D));
    fprintf('3D Error (m)    - Mean: %.2f, Std: %.2f, RMS: %.2f\n', ...
        mean(error3D), std(error3D), rms(error3D));
    
    if isfield(navSolutions, 'numSats')
        fprintf('Average number of satellites: %.1f\n', mean(navSolutions.numSats));
    end
    
    if isfield(navSolutions, 'DOP')
        if isstruct(navSolutions.DOP)
            fprintf('Average HDOP: %.2f\n', mean(navSolutions.DOP.HDOP));
            fprintf('Average PDOP: %.2f\n', mean(navSolutions.DOP.PDOP));
        else
            fprintf('Average HDOP: %.2f\n', mean(navSolutions.DOP(:,3)));
            fprintf('Average PDOP: %.2f\n', mean(navSolutions.DOP(:,2)));
        end
    end
end

function [E, N, U] = ecef2enu(dX, dY, dZ, refLat, refLon)
    % 转换ECEF坐标差值到ENU坐标系
    
    % 转换参考经纬度到弧度
    phi = deg2rad(refLat);
    lambda = deg2rad(refLon);
    
    % 计算旋转矩阵
    R = [-sin(lambda), cos(lambda), 0;
         -sin(phi)*cos(lambda), -sin(phi)*sin(lambda), cos(phi);
         cos(phi)*cos(lambda), cos(phi)*sin(lambda), sin(phi)];
    
    % 计算ENU坐标
    enu = R * [dX; dY; dZ];
    
    % 输出结果
    E = enu(1);
    N = enu(2);
    U = enu(3);
end