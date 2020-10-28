function existTbl=loadCaseData(existTbl,leadName,basepath,outParams,inParams,scanParams,segLen,varargin)
%Load ECG lead data into table for analysis
%Assumes data file as output by the NIH PriME system, 
%specifically 6-lead ECG, 2 channels of invasive blood pressure (IBP),
%and 3 gradients signals
%Table consists of following variables:

%Parameters:
%   tbl -       existing table to add data.
%   leadName -  leadName for all 3 files
%   basepath -  basepath for all 3 files
%   OutParams - a cell containing out-of-bore filename and start sample
%   InParams - a cell containing in-bore filename and start sample
%   scanParams - a cell containing real-time scan  filename and start sample
%   segLen -       Length of segments to use in samples
%   Variable inputs:
%       'Fs' - sampling freq of data, assumed to be 1kHz if not specified

%% Input parsing



%% Loading data from text file
tbl=createAnalysisTable();
tmpStruct.basePath=basepath;
tmpStruct.fileNames={outParams{1},inParams{1},scanParams{1}};
tmpStruct.leadName=leadName;
tmpStruct.startTimes={outParams{2},inParams{2},scanParams{2}};

aflead=[];
if ~isempty(outParams{1})
    [lead,aflead,grad]=getSegment(fullfile(basepath,outParams{1}),leadName,outParams{2});
    tmpStruct.outOfBore=aflead;
end

aflead=[];
if ~isempty(inParams{1})
    [lead,aflead,grad]=getSegment(fullfile(basepath,inParams{1}),leadName,inParams{2});
    tmpStruct.inBore=aflead;
end

lead=[];
aflead=[];
grad=[];
if ~isempty(scanParams{1})
    [lead,aflead,grad]=getSegment(fullfile(basepath,scanParams{1}),leadName,scanParams{2});
    tmpStruct.rtScanPreAF=lead;
    tmpStruct.rtScanPostAF=aflead;
    tmpStruct.gradientSum=grad;
end

tbl=struct2table(tmpStruct,'AsArray',true);
existTbl=[existTbl;tbl];

function [lead,aflead,grad]=getSegment(fn,leadName,startIdx)
%read full file to ensure specified indices and lengths are valid
%assumes no header
    data=dlmread(fn,'\t');
    fullLen=size(data,1);
    if (startIdx+segLen>fullLen)
        lead=[];aflead=[];
        return;
    end
    data=data(startIdx:startIdx+segLen,:);

    if (strcmpi(leadName,'leadI')) 
        cols=[1 2];
    elseif (strcmpi(leadName,'leadII'))
        cols=[1 3];
    elseif (strcmpi(leadName,'leadIII'))
        cols=[2 3];
    end
    lead=data(:,cols(2))-data(:,cols(1));
    if (size(data,2)==17)
        ecgCh=6; 
        gradCols=13:15;
    else
        ecgCh=5;
        gradCols=11:13;
    end
    aflead=data(:,cols(2)+ecgCh)-data(:,cols(1)+ecgCh);
    
    %compensate for 21 sample delay of adaptive filter
    delay=21;
    lead(end-delay+1:end)=[];
    aflead(1:delay)=[];
    grad=sum(data(1:end-delay,gradCols),2);
end %getSegment

    
end %loadCaseData