addpath include
addpath common
disp ('Starting processing...');

settings = initSettings_opensky();
[fid, message] = fopen(settings.fileName, 'rb');
probeData(settings);

if (settings.fileType==1) 
    dataAdaptCoeff=1;
else
    dataAdaptCoeff=2;
end

if (fid > 0)
    % ========== 信号处理与导航解算 ==========
    fseek(fid, dataAdaptCoeff*settings.skipNumberOfBytes, 'bof'); 

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

    if (any(acqResults.carrFreq))
        channel = preRun(acqResults, settings);
        showChannelStatus(channel, settings);
    else
        disp('No GNSS signals detected, signal processing finished.');
        trackResults = [];
        return;
    end

    if ~exist(['trackingResults','.mat'])
        startTime = now;
        disp (['   Tracking started at ', datestr(startTime)]);
        [trackResults, channel] = tracking(fid, channel, settings);
        fclose(fid);

        disp(['   Tracking is over (elapsed time ', ...
            datestr(now - startTime, 13), ')'])

        disp('   Saving Acq & Tracking results to file "trackingResults.mat"')
        save('trackingResults', ...
            'trackResults', 'settings', 'acqResults', 'channel');
    else
        load('trackingResults.mat');
    end

    disp('   Calculating navigation solutions...');
    [navSolutions, eph] = postNavigation(trackResults, settings);
    disp('   Processing is complete for this data block');

    % ========== RAIM 后处理主流程 ==========
    VPL_limit = 50; % APV-I警戒限(m)
    sigma = 3; % 伪距标准差
    numEpoch = size(navSolutions.rawP, 2);
    vpeVec = [];
    vplVec = [];
    alarmVec = [];
    errVec3d = [];
    raimPosMat = []; % 用于后面计算均值伪真值

    debug = true; % 是否输出调试信息

    for epochIdx = 1:numEpoch
        if epochIdx == 1 || mod(epochIdx,1)==0
            fprintf('Epoch %d:\n', epochIdx);
            disp('  Pseudoranges:');
            disp(pseudoranges');
            disp('  卫星坐标（前4颗）:');
            for j = 1:min(4,length(ephUsed))
                disp(ephUsed(j).satPos');
            end
            disp('  approxPos:');
            disp(approxPos');
        end
        prnIdx = find(~isnan(navSolutions.rawP(:,epochIdx)) & navSolutions.rawP(:,epochIdx) > 1e3);
        if numel(prnIdx) < 4
            continue;
        end
        pseudoranges = navSolutions.rawP(prnIdx, epochIdx);
        PRNs = navSolutions.PRN(prnIdx, epochIdx);

        ephUsed = eph(PRNs);  % 一次性批量取

        for ii = 1:length(PRNs)
            satColIdx = find(navSolutions.PRN(:,epochIdx) == PRNs(ii), 1);
            ephUsed(ii).satPos = navSolutions.satllitePosition{epochIdx}(:,satColIdx);
        end

        approxPos = [navSolutions.X(epochIdx); navSolutions.Y(epochIdx); navSolutions.Z(epochIdx)];
        [raimPos, usedSats, PL_3D, hpl, vpl, el, alarm] = WLS_RAIM(pseudoranges, ephUsed, approxPos, settings);

        % 先存下来，后面统一用均值伪真值
        raimPosMat(:,end+1) = raimPos(:);
        vplVec = [vplVec; vpl];
        alarmVec = [alarmVec; alarm];
    end

    % ========== 用解算结果均值做伪真值 ==========
    if isempty(raimPosMat)
        error('无有效解算结果！');
    end
    gtEcef = mean(raimPosMat,2);

    % 重新计算VPE和3D误差
    vpeVec = abs(raimPosMat(3,:)' - gtEcef(3));
    errVec3d = vecnorm(raimPosMat - gtEcef,2,1)';

    % ========== 输出调试信息 ==========
    debug = true;
    if debug
        disp('伪真值（均值）：');
        disp(gtEcef');
        wgs84 = wgs84Ellipsoid('meter');
        [lat,lon,h]=ecef2geodetic(wgs84,gtEcef(1),gtEcef(2),gtEcef(3));
        fprintf('伪真值地理坐标: lat=%.6f, lon=%.6f, h=%.2f\n',lat,lon,h);
        % 输出前几个历元的误差
        for k=1:min(5,length(vpeVec))
            [lat1,lon1,h1]=ecef2geodetic(wgs84,raimPosMat(1,k),raimPosMat(2,k),raimPosMat(3,k));
            fprintf('Epoch%2d: VPL=%.2f, VPE=%.2f, 3Derr=%.2f, lat=%.6f, lon=%.6f, h=%.2f\n',...
                k,vplVec(k),vpeVec(k),errVec3d(k),lat1,lon1,h1);
        end
    end

    % ========== 绘制Stanford Chart标准格式 ==========
    figure;
    maxV = 60; % 最大坐标范围
    edges = {0:1:maxV, 0:1:maxV};
    N = histcounts2(vpeVec, vplVec, edges{:});
    N = N';

    % 绘密度色散
    imagesc(edges{1}, edges{2}, log10([N;zeros(1,size(N,2))]));
    axis xy;
    hold on;
    plot([0 maxV], [0 maxV], 'k', 'LineWidth',1.5); % 45度线
    plot([0 maxV], [VPL_limit VPL_limit], 'k--', 'LineWidth',1); % VPL报警限
    plot([VPL_limit VPL_limit], [0 maxV], 'k--', 'LineWidth',1); % VPE报警限

    xlabel('VPE (m)','FontSize',11);
    ylabel('VPL (m)','FontSize',11);
    title('Stanford Chart (VPL/VPE)');

    colormap jet;
    c = colorbar; ylabel(c, 'log_{10}(N)');
    set(gca,'XLim',[0 maxV],'YLim',[0 maxV]);

    % 统计主要区域
    totalEpochs = numel(vplVec);
    availEpochs = sum((vplVec<=VPL_limit)&(vpeVec<=VPL_limit));
    availPercent = 100 * availEpochs / totalEpochs;
    alarmEpochs = sum(vplVec > VPL_limit);
    MI_epochs = sum((vplVec > VPL_limit) & (vpeVec <= VPL_limit));
    HMI_epochs = sum((vplVec <= VPL_limit) & (vpeVec > VPL_limit));
    sysUnavailEpochs = sum((vplVec > VPL_limit) & (vpeVec > VPL_limit));

    % 标注
    text(2, maxV-2, sprintf('APV-I\nEpochs: %d\n%.2f%%', availEpochs, availPercent),'Color','b','FontSize',12,'FontWeight','bold');
    text(2, maxV-8, sprintf('Alarm Epochs: %d', alarmEpochs),'Color','k','FontSize',10);
    text(maxV-25, maxV-5, sprintf('MI Epochs: %d', MI_epochs),'color','r','FontSize',10);
    text(maxV-25, maxV-10, sprintf('HMI Epochs: %d', HMI_epochs),'color','r','FontSize',10);
    text(maxV-25, maxV-15, sprintf('System Unavailable: %d', sysUnavailEpochs),'color','k','FontSize',10);

    % ========== 其它结果展示 ==========
    disp ('   Plotting additional navigation results...');
    if settings.plotTracking
        % plotTracking(1:settings.numberOfChannels, trackResults, settings);
    end

    plotNavigation(navSolutions, settings);
    disp('Post processing of the signal is over.');

else
    error('Unable to read file %s: %s.', settings.fileName, message);
end