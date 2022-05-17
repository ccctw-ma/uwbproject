% For questions/comments contact: 
% leor.banin@intel.com, 
% ofer.bar-shalom@intel.com, 
% nir.dvorecki@intel.com,
% yuval.amizur@intel.com
% Copyright (C) 2018 Intel Corporation
% SPDX-License-Identifier: BSD-3-Clause

% function cfg = testFtmPeConfig(sessionFolder, selectSegment)
function cfg = testFtmPeConfig()
% cfg.sessionFolder = sessionFolder;

% cfg.name                  = cfg.sessionFolder;
% cfg.measFile              = [cfg.name,'.csv'];
% cfg.rPosFile              = [cfg.name,'_RSP_LIST.csv'];
% cfg.VenueFile             = [cfg.name,'_VenueFile.mat'];
% cfg.selectSegment         = selectSegment;
% %*************************************************************************
% cfg.UseSyntheticMeas      = 0; % 1 = Use synthetic measurements
%                                % 0 = Use real measured data
% if cfg.UseSyntheticMeas
%     cfg.measFile = [cfg.name,'_noisySynthRanges.csv'];
%     cfg.name = cfg.measFile(1:end-4);
% end
%*************************************************************************    
% set e.g., cfg.Rsp2remove = [1,6] to remove RSPs {1,6}. 
% Remove measurements from given AP, used to test performance of different number of APs.
cfg.Rsp2remove            = [];
cfg.scaleSigmaForBigRange = 0; % 1 = Enable STD scaling for range, otherwise set to 0 
cfg.outlierFilterEnable   = 1; % 1 = Enable Outlier Filtering, otherwise set to 0
cfg.MaxRangeFilter        = 8;  % filter out ranges above this threshold
cfg.OutlierRangeFilter    = 8;  % enable outlier range filtering above this threshold
cfg.gainLimit             = 3;   % EKF gain limit % 3
%*************************************************************************                               
cfg.knownZ                = 0; % Known client height [meter]   1.4  45.5
% if(contains(cfg.name, 'X'))
%     cfg.knownZ            = 45.5; % Known client height [meter]   1.4  45.5
% end
% cfg.rangeMeasNoiseStd     = 4.6; % Range measurement noise Std [meter].  % 1
cfg.rangeMeasNoiseStd     = 0.1; % Range measurement noise Std [meter].  % 1
cfg.zMeasNoiseStd         = 0.1; % Height measurement noise Std [meter].

cfg.posLatStd             = 0.1; % Q - sys. noise [meter per second]; ����ˮƽ����һ��ά�ȵ��˶�����
cfg.heightStd             = 0.1; % Q - sys. noise [meter per second]; �߶�ά���ϵ��˶�����
cfg.biasStd               = 0.01;% Q - sys. noise [meter per second];

cfg.velStd                = 0.1; % velocity standard deviation

cfg.init.posLatStd        = 1;   % P - state cov. [meter] 
cfg.init.velStd           = 1;   % P - state cov. [meter / second]
cfg.init.heightStd        = 1;   % P - state cov. [meter] 
cfg.init.biasStd          = 0.5; % P - state cov. [meter] 

% measurement type defines
cfg.MEAS_RANG             = 1;
cfg.MEAS_CONST_Z          = 2;


end