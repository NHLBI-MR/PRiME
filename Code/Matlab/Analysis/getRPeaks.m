function [preAF,postAF]=getRPeaks(outOfBore,inBore,rtScanPreAF,rtScanPostAF,varargin)
%Retrieve Rpeaks (and potentially noise peaks)from entry in PhysSigTable
%Uses builtin Matlab function findpeaks
%
%Parameters:
%   tbl - existing AnalysisTable containing a single row
%   sig - 'outOfBore','inBore','rtScanPreAF','rtScanPostAF'
%   Variable inputs:
%   showPlot - set to true to display plot with peaks and annotations
%           defaults to false
%
%Outside Dependencies:


%% Input parsing
p=inputParser;
p.CaseSensitive=true;
p.FunctionName='getRPeaks';

%p.addRequired('tbl',@istable);
p.addRequired('outOfBore',@isvector);
p.addRequired('inBore',@isvector);
p.addRequired('rtScanPreAF',@isvector);
p.addRequired('rtScanPostAF',@isvector);

valPlotFcn=@(x) validateattributes(x,{'logical'},{'scalar'});
p.addParameter('showPlot',false,valPlotFcn);

p.parse(outOfBore,inBore,rtScanPreAF,rtScanPostAF,varargin{:});
inputs=p.Results;

%% Peak detection
%The R peak height can vary from patient to patient and even lead to lead
%In the magnet, the T wave can dominate the R wave, so it cannot be assumed
%that the R wave is the largest peak
%It should be assumed there are some motion artifacts that will be larger
%than th R peak
%It should be assumed that at the start of a scan, there will be strong,
%but brief, noise.
%How to handle negative going R peaks?
% outOfBore=tbl.outOfBore{1};
% inBore=tbl.inBore{1};
% rtScanPreAF=tbl.rtScanPreAF{1};
% rtScanPostAF=tbl.rtScanPostAF{1};

if (inputs.showPlot), subplot(411), end
outOfBore=checkForInversion(outOfBore);
[pks,locs,widths,proms]=scanForRPeaks(outOfBore,10,75,250,std(outOfBore)*3);

maxPW=max(widths)*2;
minPD=min(diff(locs))*0.50;
minPP=min(proms)*0.5;

if (inputs.showPlot) subplot(412), end
[inBore,signChg]=checkForInversion(inBore);
[pks,locs,widths,proms]=scanForRPeaks(inBore,10,maxPW,minPD,minPP);
minPD=min(diff(locs))*0.50;
minPP=min(proms)*0.25;

if (inputs.showPlot), subplot(414), end
minPW=10;
maxPW=1.25*max(widths);
%[rpks{2},rlocs{2},rwidths{2},rproms{2}]=scanForRPeaks(signChg*rtScanPostAF,minPW,maxPW,minPD,minPP);
[~,post]=scanForRPeaks(signChg*rtScanPostAF,minPW,maxPW,minPD,minPP);

if (inputs.showPlot), subplot(413), end
% minPW=10;
% maxPW=1.25*max(rwidths{2});
% minPD=min(diff(rlocs{2}))*0.9;
% minPP=min(rproms{2})*0.9;
%[rpks{1},rlocs{1},rwidths{1},rproms{1}]=scanForRPeaks(signChg*rtScanPreAF,minPW,maxPW,minPD,minPP);  
[~,pre]=scanForRPeaks(signChg*rtScanPreAF,minPW,maxPW,minPD,minPP);  

preAF={pre};
postAF={post};
    function [pks,locs,widths,proms]=scanForRPeaks(sig,minPW,maxPW,minPD,minPP)    


        %R peaks are normally <0.01 seconds. Assume this data is not normal, so R
        %peaks may be wider due to patient health or abnormal placement of
        %electrodes
        %Assume out of bore data is very clean, we'll get parameters of what the
        %ECG looks like from that. Hemodynamic effects will alter it somewhat
        [pks,locs,widths,proms]=... 
            findpeaks(sig,... 
                'MinPeakWidth',minPW,... 
                'MaxPeakWidth',maxPW,...  
                'MinPeakDistance',minPD,... 
                'WidthReference','halfheight',...
                'MinPeakProminence',minPP ... 
                );    

        if (inputs.showPlot)
            plot(sig);
            hold on, plot(locs,pks,'x'),hold off
        end

    end

    function [sig,signChg]=checkForInversion(sig)
        %due to placement of electrodes, R peak can sometimes be negative
        %on X-ray, out-of-bore signals, assume max signal is Rpeak
        %if largest signal is negative, invert signal before processing
        signChg=1;
        if (abs(min(sig))>max(sig))
             sig=-sig;
             signChg=-1;
        end
    end
end