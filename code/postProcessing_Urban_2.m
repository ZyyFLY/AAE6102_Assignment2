%% Initialization =========================================================
addpath include
addpath common
disp ('Starting processing...');

settings = initSettings_urban();

% % 添加天空遮罩数据读取
% skymask_data = readmatrix('skymask_A1_urban.csv');
% settings.skymask.azimuth = skymask_data(:,1);  % 方位角
% settings.skymask.elevation = skymask_data(:,2); % 仰角

% 设置参考点坐标
settings.refLat = 22.3198722;          % 纬度 [度]
settings.refLon = 114.209101777778;    % 经度 [度]
settings.refAlt = 3.0;                 % 高度 [米]

% WGS84椭球体参数
a = 6378137.0;              % 长半轴 [米]
f = 1/298.257223563;        % 扁率
e = sqrt(2*f - f^2);        % 第一偏心率

% 计算卯酉圈曲率半径
N = a / sqrt(1 - e^2 * sin(deg2rad(settings.refLat))^2);

% 计算参考点ECEF坐标
settings.refX = (N + settings.refAlt) * cos(deg2rad(settings.refLat)) * cos(deg2rad(settings.refLon));
settings.refY = (N + settings.refAlt) * cos(deg2rad(settings.refLat)) * sin(deg2rad(settings.refLon));
settings.refZ = (N * (1-e^2) + settings.refAlt) * sin(deg2rad(settings.refLat));

[fid, message] = fopen(settings.fileName, 'rb');
probeData(settings);

% 添加天空遮罩数据读取
skymask_data = readmatrix('skymask_A1_urban.csv');
settings.skymask.azimuth = skymask_data(:,1);  % 方位角
settings.skymask.elevation = skymask_data(:,2); % 仰角

% 初始化数据类型调整系数
if (settings.fileType==1) 
    dataAdaptCoeff=1;
else
    dataAdaptCoeff=2;
end

% 成功打开文件后处理数据
if (fid > 0)
    % 移动到处理起始点
    fseek(fid, dataAdaptCoeff*settings.skipNumberOfBytes, 'bof'); 

    %% Acquisition ============================================================
    if ((settings.skipAcquisition == 0) || ~exist('acqResults', 'var'))
        samplesPerCode = round(settings.samplingFreq / ...
                           (settings.codeFreqBasis / settings.codeLength));
        
        data = fread(fid, dataAdaptCoeff*11*samplesPerCode, settings.dataType)';
    
        if (dataAdaptCoeff==2)    
            data1=data(1:2:end);    
            data2=data(2:2:end);    
            data=data1 + 1i .* data2;    
        end

        disp ('   Acquiring satellites...');
        acqResults = acquisition(data, settings);
        plotAcquisition(acqResults);
    end

    %% Initialize channels and prepare for the run ============================
    if (any(acqResults.carrFreq))
        channel = preRun(acqResults, settings);
        showChannelStatus(channel, settings);
    else
        disp('No GNSS signals detected, signal processing finished.');
        trackResults = [];
        return;
    end

    %% Track the signal ====================================================
    if ~exist('trackingResults.mat', 'file')
        startTime = now;
        disp (['   Tracking started at ', datestr(startTime)]);
        
        [trackResults, channel] = tracking(fid, channel, settings);
        
        fclose(fid);
        
        disp(['   Tracking is over (elapsed time ', ...
            datestr(now - startTime, 13), ')'])
        
        save('trackingResults', ...
            'trackResults', 'settings', 'acqResults', 'channel');
        
    else
        load('trackingResults.mat');
    end

    %% Calculate navigation solutions =========================================
    disp('   Calculating navigation solutions...');
    [navSolutions, eph] = postNavigation(trackResults, settings);

    %% Process satellite visibility and multipath ===========================
    disp('   Processing satellite visibility and multipath...');
    
    % 处理每个通道
    for channelNr = 1:settings.numberOfChannels
        if ~isempty(trackResults(channelNr).status) && ...
           trackResults(channelNr).status == 'T'
            
            % 获取当前卫星的星历
            satID = trackResults(channelNr).PRN;
            
            % 获取时间信息
            if isfield(navSolutions, 'transmitTime')
                transmitTime = navSolutions.transmitTime;
            else
                continue;
            end
            
            % 计算卫星位置和可见性
            if ~isempty(eph) && isfield(eph, num2str(satID))
                satEph = eph.(num2str(satID));
                [satPos, satClkCorr] = satpos(transmitTime, satEph);
                
                % 计算方位角和仰角
                [az, el] = calculateSatelliteAngles(satPos, [settings.refX; settings.refY; settings.refZ]);
                
                % 检查卫星可见性
                [~, idx] = min(abs(settings.skymask.azimuth - az));
                mask_elevation = settings.skymask.elevation(idx);
                is_visible = (el > mask_elevation);
                
                % 设置权重
                weights = ones(size(trackResults(channelNr).I_P));
                if ~is_visible
                    weights = zeros(size(weights));
                else
                    weights = weights .* sin(deg2rad(el)).^2;
                    
                    % SNR权重
                    if isfield(trackResults(channelNr), 'cn0')
                        SNR = trackResults(channelNr).cn0;
                        SNR_threshold = 30;
                        weights(SNR < SNR_threshold) = 0;
                    end
                end
                
                % 保存权重
                trackResults(channelNr).weightFactor = weights;
            end
        end
    end

    %% Recalculate navigation solutions with updated weights ===============
    disp('   Recalculating navigation solutions with updated weights...');
    [navSolutions, eph] = postNavigation(trackResults, settings);

    %% Plot results =====================================================
    disp ('   Plotting results...');
    
    % 确保参考坐标设置正确
    if ~isfield(settings, 'refX')
        % WGS84椭球体参数
        a = 6378137.0;              % 长半轴 [米]
        f = 1/298.257223563;        % 扁率
        e = sqrt(2*f - f^2);        % 第一偏心率
    
        % 设置参考点坐标
        settings.refLat = 22.3198722;          % 纬度 [度]
        settings.refLon = 114.209101777778;    % 经度 [度]
        settings.refAlt = 3.0;                 % 高度 [米]
    
        % 计算卯酉圈曲率半径
        N = a / sqrt(1 - e^2 * sin(deg2rad(settings.refLat))^2);
    
        % 计算参考点ECEF坐标
        settings.refX = (N + settings.refAlt) * cos(deg2rad(settings.refLat)) * cos(deg2rad(settings.refLon));
        settings.refY = (N + settings.refAlt) * cos(deg2rad(settings.refLat)) * sin(deg2rad(settings.refLon));
        settings.refZ = (N * (1-e^2) + settings.refAlt) * sin(deg2rad(settings.refLat));
    end
    
    % Plot tracking results if enabled
    if isfield(settings, 'plotTracking') && settings.plotTracking
        plotTracking(1:settings.numberOfChannels, trackResults, settings);
    end
    
    % Plot navigation results
    Task5_2(trackResults, navSolutions);
    plotNavigation(navSolutions, settings);
    
    % Plot urban analysis results
    plotUrbanResults(trackResults, navSolutions, settings, skymask_data);
    
    disp('Post processing of the signal is over.');

else
    % Error while opening the data file.
    error('Unable to read file %s: %s.', settings.fileName, message);
end