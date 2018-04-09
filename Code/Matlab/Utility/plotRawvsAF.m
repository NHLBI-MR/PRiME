function plotRawvsAF(sigTable,row2plot,sig,varargin)

%% input argument validation
p=inputParser;
p.CaseSensitive=true;
p.FunctionName='plotRawvsAF';

errorStr='Table is not properly formatted';
valTableFcn=@(x) assert(istable(x) && checkTableFormat(x),errorStr);
p.addRequired('sigTable',valTableFcn);
    function same=checkTableFormat(tab1)
        dummyTable=createPhysSigTable('dummy');
        same=isequal(tab1.Properties.VariableNames,dummyTable.Properties.VariableNames);
    end

valRowFcn=@(x) validateattributes(x,{'numeric'},{'positive','<=',height(sigTable)});
p.addRequired('row2plot',valRowFcn);

valSigFcn=@(x) assert(ischar(sig) && sum(ismember(sigTable.Properties.VariableNames,x)));
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
vars=sigTable.Properties.VariableNames;
numericVars=varfun(@(x) isnumeric(x),sigTable(row2plot,:), ... 
    'OutputFormat','uniform');
vars=vars(numericVars);
timeVar=cellfun(@(x) isequal(x,'time'),vars);
vars(timeVar)=[];

time=sigTable.time{row2plot}(inputs.range(1):inputs.range(2));
ax(1)=subplot(211);
sigStr={sig,strcat('af',sig)};
sigs=cell2mat(sigTable{row2plot,sigStr});
plot(time, sigs(inputs.range(1):inputs.range(2),:));
title(sig);
legend(sigStr)
xlabel(sigTable.Properties.VariableUnits('time'))
ylabel(sigTable.Properties.VariableUnits(sig))
ax(2)=subplot(212);

sigStr={'X','Y','Z'};
grad=cell2mat(sigTable{row2plot,sigStr});
plot(time, grad(inputs.range(1):inputs.range(2),:));
legend(sigStr);
linkaxes(ax);



end