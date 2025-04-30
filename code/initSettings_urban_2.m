function settings = initSettings_urban()
%Functions initializes and saves settings. Settings can be edited inside of
%the function, updated from the command line or updated using a dedicated
%GUI - "setSettings".  
%
%All settings are described inside function code.
%
%settings = initSettings()
%
%   Inputs: none
%
%   Outputs:
%       settings     - Receiver settings (a structure). 

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
% $Id: initSettings.m,v 1.9.2.31 2006/08/18 11:41:57 dpl Exp $

%% Processing settings ====================================================
% Number of milliseconds to be processed used 36000 + any transients (see
% below - in Nav parameters) to ensure nav subframes are provided
settings.msToProcess        = 40000;        %[ms]

% Number of channels to be used for signal processing
settings.numberOfChannels   = 12;

% Move the starting point of processing. Can be used to start the signal
% processing at any point in the data record (e.g. for long records). fseek
% function is used to move the file read point, therefore advance is byte
% based only. 
settings.skipNumberOfBytes     = 0; %1000;%7000*26000*2;

%% Raw signal file name and other parameter ===============================
% This is a "default" name of the data file (signal record) to be used in
% the post-processing mode
settings.fileName           = 'D:\浏览器下载文件\AAE6102_Assignment1-main\AAE6102_Assignment1-main\data\Urban.dat';

% 删除这部分重复的设置
% settings.SNR_threshold = 30;          % SNR阈值
% settings.phase_jump_threshold = 0.5;  % 相位跳变阈值
% settings.receiverPos.X = -2414267;    % 接收机初始位置X
% settings.receiverPos.Y = 5386768;     % 接收机初始位置Y
% settings.receiverPos.Z = 2407959;     % 接收机初始位置Z

%% Urban环境特定设置 ====================================================
% 信号质量相关参数
settings.urban.SNR_threshold = 30;          % SNR阈值 [dB-Hz]
settings.urban.phase_jump_threshold = 0.5;  % 相位跳变阈值 [cycles]

% 接收机初始位置（任务要求的地理坐标）
settings.initPos.lat = 22.3198722;          % 纬度 [度]
settings.initPos.lon = 114.209101777778;    % 经度 [度]
settings.initPos.alt = 3.0;                 % 高度 [米]

% WGS84椭球体参数
settings.wgs84.a = 6378137.0;              % 长半轴 [米]
settings.wgs84.f = 1/298.257223563;        % 扁率
settings.wgs84.e = sqrt(2*settings.wgs84.f - settings.wgs84.f^2);  % 第一偏心率

% 计算ECEF坐标
N = settings.wgs84.a / sqrt(1 - settings.wgs84.e^2 * ...
    sin(deg2rad(settings.initPos.lat))^2);

% ECEF坐标计算
settings.initPos.X = (N + settings.initPos.alt) * ...
    cos(deg2rad(settings.initPos.lat)) * ...
    cos(deg2rad(settings.initPos.lon));
settings.initPos.Y = (N + settings.initPos.alt) * ...
    cos(deg2rad(settings.initPos.lat)) * ...
    sin(deg2rad(settings.initPos.lon));
settings.initPos.Z = (N * (1-settings.wgs84.e^2) + settings.initPos.alt) * ...
    sin(deg2rad(settings.initPos.lat));

% 天空遮罩相关设置
settings.urban.skymask.enable = 1;          % 启用天空遮罩
settings.urban.skymask.fileName = 'skymask_A1_urban.xlsx';  % 天空遮罩文件名
settings.urban.visibility.minElev = 5;      % 最小仰角阈值 [度]
settings.urban.multipath.enable = 1;        % 启用多路径检测
% settings.fileName           = 'C:\Users\guoha\Desktop\GNSS_SDR\GPSSDR_vt\sample data\hackrf_try_1.dat';
% Data type used to store one sample
settings.dataType           = 'schar';  
 
% File Types
%1 - 8 bit real samples S0,S1,S2,...
%2 - 8 bit I/Q samples I0,Q0,I1,Q1,I2,Q2,...                      
settings.fileType           = 2;

% Intermediate, sampling and code frequencies
settings.IF                 = 0;%10e6;%1580e6-1575.42e6;     % [Hz]
settings.samplingFreq       = 26e6;%58e6;        % [Hz]
settings.codeFreqBasis      = 1.023e6;     % [Hz]

% Define number of chips in a code period
settings.codeLength         = 1023;

%% Acquisition settings ===================================================
% Skips acquisition in the script postProcessing.m if set to 1
settings.skipAcquisition    = 0;
% List of satellites to look for. Some satellites can be excluded to speed
% up acquisition
settings.acqSatelliteList   = 1:32;         %[PRN numbers]
% Band around IF to search for satellite signal. Depends on max Doppler.
% It is single sideband, so the whole search band is tiwce of it.
settings.acqSearchBand      = 7000;           %[Hz]
% Threshold for the signal presence decision rule
settings.acqThreshold       = 1.5; % Original: 1.8
% Sampling rate threshold for downsampling 
settings.resamplingThreshold    = 8e6;            % [Hz]
% Enable/dissable use of downsampling for acquisition
settings.resamplingflag         = 0;              % 0 - Off
                                                  % 1 - On
%% Tracking loops settings ================================================
% Code tracking loop parameters
settings.dllDampingRatio         = 0.707;%0.7;
settings.dllNoiseBandwidth       = 2;%1.5;       %[Hz]
settings.dllCorrelatorSpacing    = 0.5;     %[chips]

% Carrier tracking loop parameters
settings.pllDampingRatio         = 0.707;%0.7;
settings.pllNoiseBandwidth       = 20;      %[Hz]
% Integration time for DLL and PLL
settings.intTime                 = 0.001;      %[s]
%% Navigation solution settings ===========================================

% Period for calculating pseudoranges and position
settings.navSolPeriod       = 1000;%500;          %[ms]

% Elevation mask to exclude signals from satellites at low elevation
settings.elevationMask      = 5;           %[degrees 0 - 90]
% Enable/dissable use of tropospheric correction
settings.useTropCorr        = 1;            % 0 - Off
                                            % 1 - On

% True position of the antenna in UTM system (if known). Otherwise enter
% all NaN's and mean position will be used as a reference .
settings.truePosition.E     = nan;
settings.truePosition.N     = nan;
settings.truePosition.U     = nan;

%% Plot settings ==========================================================
% Enable/disable plotting of the tracking results for each channel
settings.plotTracking       = 1;            % 0 - Off
                                            % 1 - On
%% Constants ==============================================================
settings.c                  = 299792458;    % The speed of light, [m/s]
settings.startOffset        = 68.802;       %[ms] Initial sign. travel time

%% CNo Settings============================================================
% Accumulation interval in Tracking (in Sec)
settings.CNo.accTime=0.001;
% Accumulation interval for computing VSM C/No (in ms)
settings.CNo.VSMinterval = 40;


%% Multiple correlator
settings.multicorr=1;