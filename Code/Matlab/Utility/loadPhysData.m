function curTable=loadPhysData(fn,curTable,varargin)
%Load physiological recordings into a Matlab table. 
%Assumes data file as output by the NIH PriME system, 
%specifically 6-lead ECG, 2 channels of invasive blood pressure (IBP),
%and 3 gradients signals
%Table consists of following variables:
%   RA - Right Arm electrode data, prior to adaptive filter
%   LA - Left Arm electrode data, prior to adaptive filter
%   LL - Left Leg electrode data, prior to adaptive filter
%   Vn - V electrode data, prior to adaptive filter, n=[1,2,3]
%   leadX - lead I data, prior to adaptive filter, X=I,II,III
%   afXX - electrode data after adaptive filter, XX='RA','LA',etc
%   IBP1 - First IBP channel
%   IBP2 - Second IBP channel
%   X,Y,Z - X,Y,Z gradient signals as acquired from the MRI control 
%           signals, after low pass filtering
%Parameters:
%   curTable - existing table to add data. If empty, a new table is created
%   fn    - a string containg filename of the data
%   Variable inputs:
%       'Fs' - sampling freq of data, assumed to be 1kHz if not specified
%       'comment' - string containing comments on this specific data set
%       'range' - 2 element uint32 array specifying start and stop indices of data
%                to store in table, 
%       'range_s' - 2 element double array specifying start and stop times of data
%                to store in table,
%
%% Input parsing
p=inputParser;
p.CaseSensitive=true;
p.FunctionName='loadPhysData';

errorStr='Invalid filename or path';
valfnFcn=@(x) assert(ischar(x) && ~isempty(x) && exist(x,'file'),errorStr);
p.addRequired('fn',valfnFcn);

errorStr='Table is not properly formatted';
%valTableFcn=@(x) assert(istable(x),errorStr);
valTableFcn=@(x) assert(istable(x) && checkTableFormat(x),errorStr);
p.addRequired('curTable',valTableFcn);
    function same=checkTableFormat(tab1)
        dummyTable=createPhysSigTable('dummy');
        same=isequal(tab1.Properties.VariableNames,dummyTable.Properties.VariableNames);
    end

valFsFcn=@(x) validateattributes(x,{'numeric'},{'nonempty','postive'});
p.addParameter('Fs',1e3,valFsFcn);

valCommentFcn=@(x) validateattributes(x,{'char'},{'nonempty'});
p.addParameter('comment','',valCommentFcn);

valRangeFcn=@(x) validateattributes(x,{'numeric'},{'numel',2,'increasing','positive'});
p.addParameter('range',[0 0],valRangeFcn);

valRangeSFcn=@(x) validateattributes(x,{'double'},{'numel',2,'increasing'});
p.addParameter('range_s',[0,0],valRangeSFcn);

p.parse(fn,curTable,varargin{:});
inputs=p.Results;

%% Loading data from text file
%must read in full file as it is impossible to predict legal bounds
data=dlmread(fn,'\t');
if (~isequal([0,0],inputs.range))
    data=data(inputs.range(1):inputs.range(2),:);
elseif (~isequal([0,0],inputs.range_s))
    inputs.range=inputs.range_s.*inputs.Fs;
    inputs.range(1)=inputs.range(1)+1;
    
    data=data(inputs.range(1):inputs.range(2),:);
else
    inputs.range=[1 length(data)];
end
t=(inputs.range(1):inputs.range(2))'./inputs.Fs;

physSig.time=t;
if (size(data,2)==17)
    ecgCh=6;
    physSig.RA=data(:,1);
    physSig.LA=data(:,2);
    physSig.LL=data(:,3);
    physSig.V1=data(:,4);
    physSig.V2=data(:,5);
    physSig.V3=data(:,6);

    physSig.afRA=data(:,1+ecgCh);
    physSig.afLA=data(:,2+ecgCh);
    physSig.afLL=data(:,3+ecgCh);
    physSig.afV1=data(:,4+ecgCh);
    physSig.afV2=data(:,5+ecgCh);
    physSig.afV3=data(:,6+ecgCh);    
    physSig.X=data(:,13);
    physSig.Y=data(:,14);
    physSig.Z=data(:,15);
    physSig.IBP1=data(:,17);
    physSig.IBP2=data(:,16);
    
else
    ecgCh=5;
    physSig.RA=data(:,1);
    physSig.LA=data(:,2);
    physSig.LL=data(:,3);
    physSig.V1=data(:,4);
    physSig.V2=data(:,5);
    physSig.V3=zeros(size(physSig.V2));   

    physSig.afRA=data(:,1+ecgCh);
    physSig.afLA=data(:,2+ecgCh);
    physSig.afLL=data(:,3+ecgCh);
    physSig.afV1=data(:,4+ecgCh);
    physSig.afV2=data(:,5+ecgCh);
    physSig.afV3=zeros(size(physSig.afV2));    

    physSig.X=data(:,11);
    physSig.Y=data(:,12);
    physSig.Z=data(:,13);
    physSig.IBP1=data(:,14);
    physSig.IBP2=data(:,15);
end

physSig.leadI=physSig.LA-physSig.RA;
physSig.leadII=physSig.LL-physSig.RA;
physSig.leadIII=physSig.LL-physSig.LA;
physSig.afleadI=physSig.afLA-physSig.afRA;
physSig.afleadII=physSig.afLL-physSig.afRA;
physSig.afleadIII=physSig.afLL-physSig.afLA;

%% Conversion to table 
physSig.Comment=inputs.comment;
physSig.OrigFilename=inputs.fn;
physSig.Fs=inputs.Fs;
physSig=struct2table(physSig,'AsArray',true);

curTable=[curTable;physSig];

    
end %loadPhysData