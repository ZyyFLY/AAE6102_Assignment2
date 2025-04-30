function Task5_2(trackResults, navSolutions)
%% Initialize Kalman Filter parameters
% State vector: [x, y, z, vx, vy, vz]
% 状态转移矩阵
dt = 1.0; % 时间步长
F = [1 0 0 dt 0 0;
     0 1 0 0 dt 0;
     0 0 1 0 0 dt;
     0 0 0 1 0 0;
     0 0 0 0 1 0;
     0 0 0 0 0 1];

% 初始化噪声参数
Q = diag([1e-6, 1e-6, 1e-6, 1e-8, 1e-8, 1e-8]); % 降低过程噪声
R = diag([15, 15, 30]); % 调整测量噪声，增加Up方向权重
P = diag([50, 50, 50, 0.5, 0.5, 0.5]); % 初始状态协方差

% 初始化状态向量
x = [navSolutions.X(1); navSolutions.Y(1); navSolutions.Z(1); 0; 0; 0];

% 存储滤波结果
filtered_pos = zeros(3, length(navSolutions.X));
filtered_vel = zeros(3, length(navSolutions.X));

% GDOP阈值
gdop_threshold = 7.0;

%% Kalman Filter Loop
for k = 1:length(navSolutions.X)
    % 初始化阶段特殊处理
    if k <= 8
        R_current = R * 0.3; % 增加测量权重
        Q_current = Q * 3;   % 增加过程噪声
    else
        R_current = R;
        Q_current = Q;
    end
    
    % DOP适应性调整
    if isfield(navSolutions, 'DOP') && ~isempty(navSolutions.DOP)
        if navSolutions.DOP(min(k,size(navSolutions.DOP,1)),1) > gdop_threshold
            weight_factor = (gdop_threshold / navSolutions.DOP(min(k,size(navSolutions.DOP,1)),1))^2;
            R_current = R_current * weight_factor;
        end
    end
    
    % Predict
    x_pred = F * x;
    P_pred = F * P * F' + Q_current;
    
    % Update
    z = [navSolutions.X(k); navSolutions.Y(k); navSolutions.Z(k)];
    H = [1 0 0 0 0 0;
         0 1 0 0 0 0;
         0 0 1 0 0 0];
    
    % 计算创新序列
    innovation = z - H * x_pred;
    
    % 自适应测量噪声
    R_adapted = adaptMeasurementNoise(R_current, innovation, H, P_pred);
    
    % 添加方向性权重
    R_direction = diag([1, 2, 1.5]); % North方向给予更高权重
    R_adapted = R_adapted .* R_direction;
    
    % 异常值检测
    if norm(innovation) > 3 * sqrt(trace(R_adapted))
        R_adapted = R_adapted * 2;
    end
    
    % Kalman Gain
    K = P_pred * H' / (H * P_pred * H' + R_adapted);
    
    % Update state and covariance
    x = x_pred + K * innovation;
    P = (eye(6) - K * H) * P_pred;
    
    % Store results
    filtered_pos(:,k) = x(1:3);
    filtered_vel(:,k) = x(4:6);
    
    % Convert ECEF to geodetic coordinates
    [lat, lon, h] = ecef2geodetic(x(1), x(2), x(3), referenceEllipsoid('WGS84'));
    navSolutions.latitude_kf(k) = lat;
    navSolutions.longitude_kf(k) = lon;
    navSolutions.VX_kf(k) = x(4);
    navSolutions.VY_kf(k) = x(5);
    navSolutions.VZ_kf(k) = x(6);
end

%% Plot Results
% Plot 1: Satellite View
figure(501);
open_gt = [22.3198722,114.209101777778 3]; % Urban gt

geoscatter(open_gt(1),open_gt(2),"*");
geobasemap satellite;

% 使用原始绘图方式
for i=1:size(navSolutions.latitude,2)
    geoplot(navSolutions.latitude_kf(i),navSolutions.longitude_kf(i),'r*', 'MarkerSize', 10);
    hold on;
end
geoplot(open_gt(1),open_gt(2),'o','MarkerFaceColor','y', 'MarkerSize', 10,'MarkerEdgeColor','y');
hold on;
title('Satellite View with Ground Track');

% Plot 2: Position Error
figure(502);
lla_gt = [22.3198722,114.209101777778 3]; % Urban gt
lla = [navSolutions.latitude_kf;navSolutions.longitude_kf;zeros(1,length(navSolutions.longitude))]';
xyzENU = lla2enu(lla,lla_gt,'flat');

% Calculate positioning error
err = zeros(1, length(xyzENU(:,1)));
for i = 1:length(xyzENU(:,1))
    err(i) = sqrt(xyzENU(i,1)^2 + xyzENU(i,2)^2);
end

% Save error results
PosErr_Urban_kf = err;
save("PosErr_Urban_kf.mat","PosErr_Urban_kf");

% Plot error with confidence bounds
t = 1:length(err);
errorbar(t, err, std(err)*ones(size(err)), 'b-', 'LineWidth', 1.5);
hold on;
plot(t, movmean(err, 5), 'r--', 'LineWidth', 1.5); % Moving average

title('Positioning Result with Error Bounds');
xlabel('Epoch');
ylabel('Error (m)');
grid on;
legend('Error with ±1σ', '5-point Moving Average');

% Add error statistics
mean_err = mean(err);
std_err = std(err);
rms_err = sqrt(mean(err.^2));
text(5, max(err)*0.9, sprintf('Mean Error: %.2f m\nStd Dev: %.2f m\nRMS Error: %.2f m', ...
    mean_err, std_err, rms_err), 'FontSize', 10, 'BackgroundColor', 'white');

% Plot 3: Velocity Estimation
figure(503);
v = [navSolutions.VX_kf', navSolutions.VY_kf', navSolutions.VZ_kf'];
v_Urban_kf = v;
save('v_Urban_kf.mat','v_Urban_kf');

% Plot velocity components with confidence bounds
t = 1:size(v,1);
subplot(2,1,1)
errorbar(t, v(:,1), std(v(:,1))*ones(size(v(:,1))), 'b-', 'LineWidth', 1.5);
hold on;
errorbar(t, v(:,2), std(v(:,2))*ones(size(v(:,2))), 'r-', 'LineWidth', 1.5);
title('Velocity Components with Error Bounds');
xlabel('Epoch');
ylabel('Velocity (m/s)');
legend('Vx ±1σ', 'Vy ±1σ', 'Location', 'best');
grid on;

% Plot velocity magnitude
subplot(2,1,2)
v_mag = sqrt(sum(v(:,1:2).^2, 2));
plot(t, v_mag, 'k-', 'LineWidth', 1.5);
title('Velocity Magnitude');
xlabel('Epoch');
ylabel('Speed (m/s)');
grid on;

% Add velocity statistics
mean_vx = mean(v(:,1));
mean_vy = mean(v(:,2));
std_vx = std(v(:,1));
std_vy = std(v(:,2));
text(5, max(v_mag)*0.9, sprintf('Mean |V|: %.2f m/s\nStd |V|: %.2f m/s', ...
    mean(v_mag), std(v_mag)), 'FontSize', 10, 'BackgroundColor', 'white');

% Display summary statistics
fprintf('\nKalman Filter Results Summary:\n');
fprintf('Position Error Statistics:\n');
fprintf('Mean Error: %.2f m\n', mean_err);
fprintf('Standard Deviation: %.2f m\n', std_err);
fprintf('RMS Error: %.2f m\n', rms_err);
fprintf('\nVelocity Statistics:\n');
fprintf('Mean Velocity X: %.2f m/s\n', mean_vx);
fprintf('Mean Velocity Y: %.2f m/s\n', mean_vy);
fprintf('Std Velocity X: %.2f m/s\n', std_vx);
fprintf('Std Velocity Y: %.2f m/s\n', std_vy);
fprintf('Mean Speed: %.2f m/s\n', mean(v_mag));
fprintf('Speed Std Dev: %.2f m/s\n', std(v_mag));
end

function R_adapted = adaptMeasurementNoise(R, innovation, H, P_pred)
    % 计算创新协方差
    S = H * P_pred * H' + R;
    % 计算实际创新
    C_actual = innovation * innovation';
    % 自适应因子
    alpha = trace(C_actual) / trace(S);
    % 限制自适应因子范围
    alpha = min(max(alpha, 0.1), 10);
    % 调整测量噪声
    R_adapted = alpha * R;
end

function [lat, lon, h] = ecef2geodetic(x, y, z, ellipsoid)
    % Convert ECEF coordinates to geodetic coordinates
    a = ellipsoid.SemimajorAxis;
    f = ellipsoid.Flattening;
    b = a * (1 - f);
    e = sqrt(1 - (b/a)^2);

    % Calculate longitude
    lon = atan2(y, x);

    % Initialize variables for iteration
    p = sqrt(x^2 + y^2);
    lat = atan2(z, p * (1 - e^2));

    for i = 1:5
        N = a / sqrt(1 - e^2 * sin(lat)^2);
        h = p / cos(lat) - N;
        lat = atan2(z, p * (1 - e^2 * N/(N + h)));
    end

    % Convert to degrees
    lat = rad2deg(lat);
    lon = rad2deg(lon);
end