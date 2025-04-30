function [azimuth, elevation] = calculateSatelliteAngles(satPos, receiverPos)
    % 计算卫星的方位角和仰角
    %
    % 输入:
    %   satPos      - 卫星ECEF坐标 [X, Y, Z]
    %   receiverPos - 接收机ECEF坐标 [X, Y, Z]
    %
    % 输出:
    %   azimuth   - 方位角(度)
    %   elevation - 仰角(度)

    % 计算接收机到卫星的向量
    vector = satPos - receiverPos;
    
    % 将接收机位置转换为大地坐标
    [recLat, recLon, recH] = ecef2geodetic(receiverPos(1), ...
                                          receiverPos(2), ...
                                          receiverPos(3));
    
    % 建立从ECEF到ENU的旋转矩阵
    rotMatrix = [-sin(recLon), cos(recLon), 0;
                 -sin(recLat)*cos(recLon), -sin(recLat)*sin(recLon), cos(recLat);
                 cos(recLat)*cos(recLon), cos(recLat)*sin(recLon), sin(recLat)];
    
    % 将向量转换到ENU坐标系
    enu = rotMatrix * vector';
    
    % 计算方位角和仰角
    azimuth = atan2(enu(1), enu(2));
    if azimuth < 0
        azimuth = azimuth + 2*pi;
    end
    azimuth = rad2deg(azimuth);
    
    horizontalDistance = sqrt(enu(1)^2 + enu(2)^2);
    elevation = atan2(enu(3), horizontalDistance);
    elevation = rad2deg(elevation);
end