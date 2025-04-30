function Task5(trackResults, navSolutions)
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

% 过程噪声协方差矩阵
Q = diag([1e-4, 1e-4, 1e-4, 1e-6, 1e-6, 1e-6]);

% 测量噪声协方差矩阵
R = diag([10, 10, 10]);

% 初始状态协方差矩阵
P = diag([100, 100, 100, 1, 1, 1]);

% 初始化状态向量
x = [navSolutions.X(1); navSolutions.Y(1); navSolutions.Z(1); 0; 0; 0];

% 存储滤波结果
filtered_pos = zeros(3, length(navSolutions.X));
filtered_vel = zeros(3, length(navSolutions.X));

%% Kalman Filter Loop
for k = 1:length(navSolutions.X)
    % Predict
    x_pred = F * x;
    P_pred = F * P * F' + Q;
    
    % Update
    z = [navSolutions.X(k); navSolutions.Y(k); navSolutions.Z(k)];
    H = [1 0 0 0 0 0;
         0 1 0 0 0 0;
         0 0 1 0 0 0];
    
    % Kalman Gain
    K = P_pred * H' / (H * P_pred * H' + R);
    
    % Update state and covariance
    x = x_pred + K * (z - H * x_pred);
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
open_gt = [22.3198722,114.209101777778 0]; % Urban gt

geoscatter(open_gt(1),open_gt(2),"*");
geobasemap satellite;

for i=1:size(navSolutions.latitude,2)
    geoplot(navSolutions.latitude_kf(i),navSolutions.longitude_kf(i),'r*', 'MarkerSize', 10);
    hold on;
end
geoplot(open_gt(1),open_gt(2),'o','MarkerFaceColor','y', 'MarkerSize', 10,'MarkerEdgeColor','y');
hold on;

% Plot 2: Position Error
figure(502);
lla_gt = [22.3198722,114.209101777778 0]; % Urban gt
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

% Plot error
plot(1:length(err), err, 'b-', 'LineWidth', 1.5);
title('Positioning Result');
xlabel('Epoch');
ylabel('Error (m)');
grid on;

% Add error statistics
mean_err = mean(err);
std_err = std(err);
rms_err = sqrt(mean(err.^2));
text(5, max(err)*0.9, sprintf('Mean Error: %.2f m\nStd Dev: %.2f m\nRMS Error: %.2f m', ...
    mean_err, std_err, rms_err), 'FontSize', 10);

% Plot 3: Velocity Estimation
figure(503);
v = [navSolutions.VX_kf', navSolutions.VY_kf', navSolutions.VZ_kf'];
v_Urban_kf = v;
save('v_Urban_kf.mat','v_Urban_kf');

% Plot velocity components
plot(1:size(v,1), v(:,1), 'b-', 'LineWidth', 1.5);
hold on;
plot(1:size(v,1), v(:,2), 'r-', 'LineWidth', 1.5);
hold off;

title('Velocity Estimation Result (ECEF)');
xlabel('Epoch');
ylabel('Velocity (m/s)');
legend('x (m/s)', 'y (m/s)', 'Location', 'best');
grid on;

% Add velocity statistics
mean_vx = mean(v(:,1));
mean_vy = mean(v(:,2));
std_vx = std(v(:,1));
std_vy = std(v(:,2));
text(5, max(max(v(:,1:2)))*0.9, sprintf('Mean Vx: %.2f m/s\nMean Vy: %.2f m/s\nStd Vx: %.2f m/s\nStd Vy: %.2f m/s', ...
    mean_vx, mean_vy, std_vx, std_vy), 'FontSize', 10);

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