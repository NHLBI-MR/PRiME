function [preAF,postAF,gradPks]=getNoisePeaks(rtScanPreAF,rtScanPostAF,gradSum,varargin)
%Retrieve Rpeaks (and potentially noise peaks)from entry in PhysSigTable
%Uses builtin Matlab function findpeaks
%
%Parameters:
%   tbl - existing AnalysisTable
%   Variable inputs:
%   showPlot - set to true to display plot with peaks and annotations
%           defaults to false
%
%Outside Dependencies:
%   getSignals

%% Input parsing
p=inputParser;
p.CaseSensitive=true;
p.FunctionName='getNoisePeaks';

p.addRequired('rtScanPreAF',@isvector);
p.addRequired('rtScanPostAF',@isvector);
p.addRequired('gradSum',@isvector);

valPlotFcn=@(x) validateattributes(x,{'logical'},{'scalar'});
p.addParameter('showPlot',false,valPlotFcn);

p.parse(rtScanPreAF,rtScanPostAF,gradSum,varargin{:});
inputs=p.Results;

%%Gradient peaks
if (inputs.showPlot), subplot(311), end
[~,gradPks]=scanForRPeaks(gradSum,2,15,50,1500);

preAF=arrayfun(@(x) findMaxDev(rtScanPreAF,x,51),gradPks);
preAF(isnan(preAF))=[];
postAF=arrayfun(@(x) findMaxDev(rtScanPostAF,x,51),gradPks);
postAF(isnan(postAF))=[];

preAF={preAF};
postAF={postAF};
gradPks={gradPks};

function pkloc=findMaxDev(sig,loc,window)
    start=loc-floor(window/2);
    if (start<1)
        start=1;
    end
    stop=loc+floor(window/2);
    if (stop>length(sig))
        stop=length(sig);
    end
    tmpsig=sig(start:stop)-mean(sig(start:stop));
    
    warning('off','signal:findpeaks:largeMinPeakHeight');
    [pks,loc]=findpeaks(tmpsig,'MinPeakHeight',15,... 
        'MinPeakWidth',2);
    [~,idx]=max(pks);
    
    if (isempty(idx))
        pkloc=NaN;
    else
        pkloc=loc(idx)+start-1;
    end
    
end
% 
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
end