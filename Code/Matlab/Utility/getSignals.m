function [signals]=getSignals(sigTable,row2plot,sig,varargin)

%% input argument validation
p=inputParser;
p.CaseSensitive=true;
p.FunctionName='getSignals';

errorStr='Table is not properly formatted';
valTableFcn=@(x) assert(istable(x) && checkTableFormat(x),errorStr);
p.addRequired('sigTable',valTableFcn);
    function same=checkTableFormat(tab1)
        dummyTable=createPhysSigTable('dummy');
        same=isequal(tab1.Properties.VariableNames,dummyTable.Properties.VariableNames);
    end

valRowFcn=@(x) validateattributes(x,{'numeric'},{'positive','<=',height(sigTable)});
p.addRequired('row2plot',valRowFcn);

valSigFcn=@(x) assert(iscell(sig) && sum(ismember(sigTable.Properties.VariableNames,x)));
p.addRequired('sig',valSigFcn);


valPauseFcn=@(x) validateattributes(x,{'numeric'},{'positive'});
p.addParameter('pauseSec',1,valPauseFcn);

valRangeFcn=@(x) validateattributes(x,{'numeric'},{'numel',2});
p.addParameter('range',[0 0],valRangeFcn);

valRangeSFcn=@(x) validateattributes(x,{'double'},{'numel',2});
p.addParameter('range_s',[0,0],valRangeSFcn);

p.parse(sigTable,row2plot,sig,varargin{:});
inputs=p.Results;

inputs.Fs=1/(sigTable.time{1}(2)-sigTable.time{1}(1));
if (isequal([0,0],inputs.range))
    if (~isequal([0,0],inputs.range_s))
        inputs.range=inputs.range_s.*inputs.Fs;
    else
        inputs.range=[1 numel(sigTable.time{row2plot})];
    end
end
%% plot requested channels raw vs after adaptive filter

%plot only numeric values and eliminate the time vector as signal to plot
signals=cell2mat(sigTable{row2plot,sig});



end