function curTable=createAnalysisTable()

names={'basePath','caseName','fileNames','leadName','comment','startTimes',... 
        'Fs','outOfBore','inBore','rtScanPreAF','rtScanPostAF',... 
        'gradientSum','afDiffPower','gradPower'};
curTable=array2table(zeros(1,numel(names)));
curTable.Properties.VariableNames=names;
curTable.Properties.VariableDescriptions=... 
    {... 
    'Base pathname where the 3 original data files were stored',... 
    'Case name (not linked to patient data, just for easy reference)',... 
    'Filenames for all three files in case',... 
    'The name of the lead (e.g. leadI) used for the case', ... 
    'General comment on the data',... 
    'The start times for the ECG data', ... 
    'The sampling rate', ... 
    'Data for out-of-bore recording',... 
    'Data for in-bore, but no scanning recording',... 
    'Data for real-time scanning, before adaptive filtering',... 
    'Data for real-time scanning, after adaptive filtering',... 
    'Sum of all the gradient signals during real-time scanning',... 
    'Power (sum of squares of samples) of the difference between pre- and post- adaptive filtering',... 
    'Power (sum of squares of samples) of the sum of the gradients'
    };
curTable.Properties.VariableUnits=... 
    {... 
    'string',... 
    'string',... 
    'cell array of strings',... 
    'string',... 
    'string',... 
    'sample',... 
    'samples per second',... 
    'ADC counts',... 
    'ADC counts',... 
    'ADC counts',... 
    'ADC counts',... 
    'ADC counts',... 
    '',... 
    ''... 
    };
%delete the dummy data
curTable(1,:)=[];