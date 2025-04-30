% --- Compare with the skymask and adjust weight ----------------
%  az_index = round(az(i)); % 将方位角四舍五入为整数
% if az_index >= 0 && az_index <= 360
%     skymask_el = skymask(az_index + 1, 2); % 获取对应的高度角
%     if el(i) < skymask_el
%         weight(i) = weight(i) / 1; % 如果计算出的高度角小于天幕高度角，权重减半
%         
%         % 打印信息以标记权重减半
%         fprintf('Weight for satellite %d reduced. Azimuth: %d, Elevation: %.4f < Skymask Elevation: %.4f\n', ...
%                 i, az_index, el(i), skymask_el);
%     end
% end

% 
% if az_index >= 0 && az_index < 360
%     skymask_el = skymask(az_index + 1, 2); % Get corresponding skymask elevation
%     if el(i) < skymask_el
%         % Calculate elevation difference
%         el_diff = skymask_el - el(i);
%         
%         reduction_factor = floor(el_diff/10)+1;
%         
%         % Apply dynamic weight adjustment
%         weight(i) = weight(i) / reduction_factor;
%         
%         % Optional debug output
%         fprintf('Sat %d: Az=%d°, El=%.2f° < Skymask=%.2f° (Diff=%.2f°), Weight reduced by %.0f%%\n', ...
%                i, az_index, el(i), skymask_el, el_diff, reduction_factor*100);
%     end
% end
function [pos, el, az, dop, PL] = leastSquarePos(satpos, obs, settings)
    load skymask.mat;

    %=== 初始化 ========================================================
    nmbOfIterations = 100;  % 定位迭代次数
    dtr = pi/180;
    min_sats = 7;           % 最小所需卫星数
    max_raim_iter = 10;     % 最大RAIM迭代次数
    
    % 卡方检测阈值表（自由度 dof = n-4）
    chi2_table = [5 2.576; 6 3.035; 7 3.368; 8 3.644; 
                 9 3.884; 10 4.100; 11 4.298; 12 4.482];
    alpha = 0.01;           % 显著性水平

    %=== RAIM主循环 ===================================================
    raim_iter = 0;
    current_sats = 1:size(satpos, 2);  % 当前使用的卫星索引
    faulty_sats = [];                  % 已排除的故障卫星
    
    while length(current_sats) >= min_sats && raim_iter < max_raim_iter
        raim_iter = raim_iter + 1;
        fprintf('\n--- RAIM迭代 %d: 使用 %d 颗卫星 ---\n', raim_iter, length(current_sats));
        
        %=== 定位解算 ================================================
        pos = zeros(4, 1);  % 每次重新初始化位置
        for iter = 1:nmbOfIterations
            pos_prev = pos;
            A = zeros(length(current_sats), 4);
            omc = zeros(length(current_sats), 1);
            weight = zeros(length(current_sats), 1);
            az = zeros(1, length(current_sats));
            el = az;
            
            % 构建观测方程
            for i = 1:length(current_sats)
                sat_idx = current_sats(i);
                Rot_X = satpos(:, sat_idx);
                
                if iter >= 1
                    % 地球自转校正
                    rho2 = sum((Rot_X - pos(1:3)).^2);
                    traveltime = sqrt(rho2) / settings.c;
                    Rot_X = e_r_corr(traveltime, Rot_X);
                    
                    % 计算仰角/方位角
                    [az(i), el(i), ~] = topocent(pos(1:3), Rot_X - pos(1:3));
                    
                    % 对流层延迟校正
                    if settings.useTropCorr == 1
                        trop = tropo(sin(el(i)*dtr), 0.0, 1013.0, 293.0, 50.0, 0.0, 0.0, 0.0);
                    else
                        trop = 0;
                    end
                    
                    % 权重计算（基于仰角）
                    weight(i) = sin(el(i)*dtr);
                else
                    trop = 2;  % 初始对流层估计
                end
                
                % 观测残差
                omc(i) = obs(sat_idx) - norm(Rot_X - pos(1:3)) - pos(4) - trop;
                
                % 设计矩阵
                A(i,:) = [-(Rot_X(1)-pos(1))/norm(Rot_X-pos(1:3)), ...
                          -(Rot_X(2)-pos(2))/norm(Rot_X-pos(1:3)), ...
                          -(Rot_X(3)-pos(3))/norm(Rot_X-pos(1:3)), ...
                          1];
            end
            
            % 加权最小二乘解算
            W = diag(weight);
            C = W'*W;
            x = (A'*C*A) \ (A'*C*omc);
            pos = pos + x;
            
            % 检查收敛
            if iter > 1 && norm(x(1:3)) < 0.01
                break;
            end
        end
        
        %=== RAIM故障检测 ============================================
        r = omc - A*x;
        sse = sqrt(r' * C * r);
        dof = length(current_sats) - 4;
        
        % 获取卡方阈值
        idx = find(chi2_table(:,1) == length(current_sats), 1);
        if isempty(idx)
            chi2_threshold = chi2inv(1-alpha, dof);
        else
            chi2_threshold = chi2_table(idx,2);
        end
        
        % 故障判断
        if sse > chi2_threshold
            % 找出故障卫星
            normalized_res = abs(r) ./ sqrt(diag(inv(C)));
            [~, worst_sat_idx] = max(normalized_res);
            worst_sat = current_sats(worst_sat_idx);
            
            fprintf('检测到故障 (SSE=%.3f > 阈值=%.3f)\n', sse, chi2_threshold);
            fprintf('排除卫星 %d (归一化残差=%.3f)\n', worst_sat, max(normalized_res));
            
            % 更新卫星列表
            faulty_sats = [faulty_sats, worst_sat];
            current_sats = setdiff(current_sats, worst_sat);
        else
            fprintf('RAIM验证通过 (SSE=%.3f <= 阈值=%.3f)\n', sse, chi2_threshold);
            break;  % 退出RAIM循环
        end
    end
    
    %=== 结果输出 ====================================================
    nnn = size(satpos, 2);  % Number of satellites in current epoch

    % Initialize empty arrays if not existing
    if ~exist('el','var') || isempty(el)
        el = zeros(1, nnn);
    end
    if ~exist('az','var') || isempty(az)
        az = zeros(1, nnn);
    end

    % Pad arrays if needed
    if size(el,2) < nnn
        el = [el, zeros(1, nnn - size(el,2))];
    end
    if size(az,2) < nnn
        az = [az, zeros(1, nnn - size(az,2))];
    end

    if length(current_sats) < min_sats
        fprintf('警告: 仅剩 %d 颗卫星，不足最小要求!\n', length(current_sats));
        pos = zeros(1,4);
        dop = inf(1,5);
        PL = inf;  % Protection Level set to infinity if insufficient satellites
    else
        pos = pos';
        if nargout == 4
            Q = inv(A'*A);
            dop = [sqrt(trace(Q)),                     % GDOP
                   sqrt(Q(1,1)+Q(2,2)+Q(3,3)),        % PDOP
                   sqrt(Q(1,1)+Q(2,2)),               % HDOP 
                   sqrt(Q(3,3)),                     % VDOP
                   sqrt(Q(4,4))];                     % TDOP
        end
    end   
        %=== Protection Level Calculation =============================
       % Input: Design matrix G, weight matrix W_s, satellite count m, threshold T_D

%=== Protection Level Calculation =============================

    % 1. 计算投影矩阵 (使用当前A矩阵和权重)
    m = size(A,1);
    S = (A' * C * A) \ (A' * C);
    P = A*S;
    % 2. 计算每颗卫星的3D斜率
    Slope_3D = zeros(m, 1);
    for i = 1:m
        Slope_3D(i) = sqrt((S(1,i)^2 + S(2,i)^2 + S(3,i)^2) / P(i,i));
    end
    Slope_3D_max = max(Slope_3D);
    
    % 3. 获取卡方阈值（与RAIM检测使用相同的阈值表）
    idx = find(chi2_table(:,1) == m, 1);
    if isempty(idx)
        T = chi2inv(1-alpha, m-4);
    else
        T = chi2_table(idx,2);
    end
    
    % 4. 计算位置误差的RMS
    cov_xyz = inv(A' * C * A);
    RMS_3D = sqrt(cov_xyz(1,1) + cov_xyz(2,2) + cov_xyz(3,3));

    % Step 2: Compute k_md (Gaussian inverse)
    P_md=1e-7;
    k_md = norminv(1 - P_md/2);   % ≈ 5.33 for P_md=1e-7

    % 5. 计算3D保护等级（保守系数k=3.0）
    k_3D = 3.0;  
    PL = Slope_3D_max * T + k_3D * k_md ;
    
    fprintf('保护等级计算: PL_3D = %.2f 米 (最大斜率=%.2f, RMS=%.2f)\n',...
            PL, Slope_3D_max, RMS_3D);
  
    fprintf('计算保护等级: PL = %.2f 米\n', PL);

    % 写入文本文件
            fid = fopen('PL10.txt', 'a');
            if fid == -1
                error('无法打开日志文件！');
            end
            fprintf(fid, ' %.2f ', PL);
            fclose(fid);

end