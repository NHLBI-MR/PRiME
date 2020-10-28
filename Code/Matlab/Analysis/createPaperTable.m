%%Create table for pediatric cases which will be used for analysis
% basepath='C:\Users\kakareka\projects\Lederman-NHLBI\DataForPaper\CNMC Data\';
% segLen=10e3;
% cnmcTable=loadCaseData([],'leadI',basepath,{'2016-05-31/inXRay',1},{'2016-05-31/inMR no scan',1},{'2016-05-31/inMR scan',105e3},segLen);
% cnmcTable=loadCaseData(cnmcTable,'leadI',basepath,{'2016-06-10/InXRay',1},{'2016-06-10/InMR_NoScan',1},{'2016-06-10/InMR_Scan',150e3},segLen);
% cnmcTable=loadCaseData(cnmcTable,'leadI',basepath,{'2016-06-14/XRay',1},{'2016-06-14/MRI_NoScan',1},{'2016-06-14/MRI_Scan',80e3},segLen);
% cnmcTable=loadCaseData(cnmcTable,'leadII',basepath,{'2016-06-24/2016-06-24_out-of-bore.txt',1},{'2016-06-24/2016-06-24_in-bore.txt',1},{'2016-06-24/2016-06-24_rt.txt',1},segLen);
% cnmcTable=loadCaseData(cnmcTable,'leadII',basepath,{'2016-06-28/data_Xray',1},{'2016-06-28/data_noScan',1},{'2016-06-28/data_realtime',50e3},segLen);
% cnmcTable=loadCaseData(cnmcTable,'leadI',basepath,{'2016-10-07/out-of-bore.txt',2e3},{'2016-10-07/inbore.txt',36e3},{'2016-10-07/rtscans.txt',150e3},segLen);
% save 'cnmcTable.mat' cnmcTable;
% clear cnmcTable segLen basepath;

%% Create table for plotting non-realtime scans
basepath='C:\Users\kakareka\projects\Lederman-NHLBI\DataForPaper\NIH Data\2016-03-01\';
segLen=10e3;
otherScans=loadCaseData([],'leadI',basepath,{'',1},{'',1},{'2016-3-1_patient_ms3plane.txt',1e3},segLen);
%otherScans=loadCaseData(otherScans,'leadI',basepath,{'',1},{'',1},{'2016-3-1_patient_binning.txt',10e3},segLen);
%otherScans=loadCaseData(otherScans,'leadI',basepath,{'',1},{'',1},{'2016-3-1_patient_aovenc.txt',89e3},segLen);
%otherScans=loadCaseData(otherScans,'leadI',basepath,{'',1},{'',1},{'2016-3-1_patient_lungwater.txt',27e3},segLen);
%otherScans=loadCaseData(otherScans,'leadI',basepath,{'',1},{'',1},{'2016-3-1_patient_lungperfusion.txt',9e3},segLen);
otherScans=loadCaseData(otherScans,'leadI',basepath,{'',1},{'',1},{'2016-3-1_patient_lungtt.txt',11e3},segLen);
otherScans=loadCaseData(otherScans,'leadI',basepath,{'',1},{'',1},{'2016-3-1_3chbinning.txt',5e3},segLen);
%otherScans=loadCaseData(otherScans,'leadI',basepath,{'',1},{'',1},{'2016-3-1_4chbinning.txt',33e3},segLen);
%otherScans=loadCaseData(otherScans,'leadI',basepath,{'',1},{'',1},{'2016-3-1_saxbinning.txt',34e3},segLen);
%otherScans=loadCaseData(otherScans,'leadI',basepath,{'',1},{'',1},{'2016-3-1_paflow2.txt',3e3},segLen);
otherScans=loadCaseData(otherScans,'leadI',basepath,{'',1},{'',1},{'2016-3-1_aoflow2.txt',1e3},segLen);
save 'otherScans.mat' otherScans;
clear otherScans segLen basepath;