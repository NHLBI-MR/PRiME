function plotAllSignals(sigTable,row2plot,varargin)

%% input argument validation
p=inputParser;
p.CaseSensitive=true;
p.FunctionName='plotAllSignals';

errorStr='Table is not properly formatted';
valTableFcn=@(x) assert(istable(x) && checkTableFormat(x),errorStr);
p.addRequired('sigTable',valTableFcn);
    function same=checkTableFormat(tab1)
        dummyTable=createPhysSigTable('dummy');
        same=isequal(tab1.Properties.VariableNames,dummyTable.Properties.VariableNames);
    end

valRowFcn=@(x) validateattributes(x,{'numeric'},{'positive','<=',height(sigTable)});
p.addRequired('row2plot',valRowFcn);

valPauseFcn=@(x) validateattributes(x,{'numeric'},{'positive'});
p.addParameter('pauseSec',1,valPauseFcn);

valRangeFcn=@(x) validateattributes(x,{'numeric'},{'numel',2,'increasing','positive'});
p.addParameter('range',[0 0],valRangeFcn);

valRangeSFcn=@(x) validateattributes(x,{'double'},{'numel',2});
p.addParameter('range_s',[0,0],valRangeSFcn);

p.parse(sigTable,row2plot,varargin{:});
inputs=p.Results;

if (isequal([0,0],inputs.range))
    if (~isequal([0,0],inputs.range_s))
        inputs.range=inputs.range_s.*testTable.Fs(row2plot);
    else
        inputs.range=[1 numel(sigTable.time{row2plot})];
    end
end

%% plot each channel

%plot only numeric values and eliminate the time vector as signal to plot
vars=sigTable.Properties.VariableNames;
%only plot columns which are 
numericVars=varfun(@(x) iscell(x) && isnumeric(x{:}) && isvector(x{:}),... 
                        sigTable(row2plot,:), 'OutputFormat','uniform');
vars=vars(numericVars);
timeVar=cellfun(@(x) isequal(x,'time'),vars);
vars(timeVar)=[];

for v=vars
    plot(sigTable.time{row2plot}(inputs.range(1):inputs.range(2)),...
        sigTable{row2plot,v}{:}(inputs.range(1):inputs.range(2)));
    title(v);
    xlabel(sigTable.Properties.VariableUnits('time'))
    ylabel(sigTable.Properties.VariableUnits(v))
    if (inputs.pauseSec==inf)
        pause
    else
        pause(inputs.pauseSec)
    end
end

end
