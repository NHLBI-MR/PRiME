%% test bad filenames
function 

end

function testNonCharFN(testcase)
    fn=1;
    testTable=createPhysSigTable('testing');
    testTable=loadPhysData(fn,testTable);
end