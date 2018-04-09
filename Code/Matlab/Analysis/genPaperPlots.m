function genPaperPlots(tbl,otherScans)
close all
figure
plot(tbl.afDiffPower)
title('Power of scan noise')
xlabel('Case #')
ylabel('Power (counts^2/Hz') 
saveFolder='./figures';
fileType='emf';
if (~exist(saveFolder,'dir'))
    mkdir(saveFolder);
end

%% Number of detected Noise Peaks
figure
nPksPreAF=cellfun(@length,tbl.NoisePks_preAF);
nPksPostAF=cellfun(@length,tbl.NoisePks_postAF);
%plot(1:length(nPksPreAF),nPksPreAF,1:length(nPksPostAF),nPksPostAF)
%title('Number of Detected Noise Peaks During Real-Time Scans')
%legend({'Pre-Adaptive Filter','Post-Adaptive Filter'})
%ylabel('Number of Noise Peaks')
percentChange=100*(nPksPostAF-nPksPreAF)/nPksPreAF;
plot(1:length(nPksPreAF),percentChange);
title(sprintf('Percent Change in Number of Detected Noise Peaks\n During Real-Time Scans'),'Interpreter','none')
xlabel('Case #')
ylabel('% Change')
ax=gca;
ax.XTick=(1:length(nPksPreAF));
saveas(gcf,sprintf('%s/%s',saveFolder,'NoisePeaks'),fileType);

%% Max Height of Noise Peaks
figure
maxNPksPreAF=cell2mat(tbl.MaxNoisePks_preAF);
maxNPksPostAF=cell2mat(tbl.MaxNoisePks_postAF);
%plot(1:length(maxNPksPreAF),maxNPksPreAF,1:length(maxNPksPostAF),maxNPksPostAF)
%title('Max Height of Detected Noise Peaks During Real-Time Scans')
%legend({'Pre-Adaptive Filter','Post-Adaptive Filter'})
percentChange=100*(maxNPksPostAF-maxNPksPreAF)/maxNPksPreAF;
plot(1:length(maxNPksPreAF),percentChange);
title(sprintf('Percent Change in Max Height of Detected Noise Peaks\n During Real-Time Scans'),'Interpreter','none')
xlabel('Case #')
ylabel('ADC counts')
ax=gca;
ax.XTick=(1:length(maxNPksPreAF));
saveas(gcf,sprintf('%s/%s',saveFolder,'MaxHeight'),fileType);

%% Mean Height of Noise Peaks
figure
meanNPksPreAF=cell2mat(tbl.MeanNoisePks_preAF);
meanNPksPostAF=cell2mat(tbl.MeanNoisePks_postAF);
%plot(1:length(meanNPksPreAF),meanNPksPreAF,1:length(meanNPksPostAF),meanNPksPostAF)
%title('Mean Height of Detected Noise Peaks During Real-Time Scans')
%legend({'Pre-Adaptive Filter','Post-Adaptive Filter'})
percentChange=100*(meanNPksPostAF-meanNPksPreAF)/meanNPksPreAF;
plot(1:length(meanNPksPreAF),percentChange);
title(sprintf('Percent Change in Mean Height of Detected Noise Peaks\n During Real-Time Scans'),'Interpreter','none')
xlabel('Case #')
ylabel('ADC counts')
ax=gca;
ax.XTick=(1:length(meanNPksPreAF));
saveas(gcf,sprintf('%s/%s',saveFolder,'MeanHeight'),fileType);



%% Plot all Noise Peaks
%plotAllNoisePks(tbl)
%legend({'Pre-Adaptive Filter','Post-Adaptive Filter'})

%% plot example ECG out of bore, in bore, and scanning
figH=figure;
caseNum=4;
caseLen=2000;
t=(1:caseLen)./1000;
txtX=0.05;
txtY=0.9;

ax(1)=subplot(221);
plot(t,tbl.outOfBore{caseNum}(1:caseLen))
set(ax(1),'XTick',[])
set(ax(1),'YTick',[])
set(ax(1),'Position',[0.05 0.52 0.25 0.25])
text(txtX,txtY,'A','Units','normalized');

ax(2)=subplot(223);
plot(t,tbl.inBore{caseNum}(1:caseLen))
set(ax(2),'XTick',[])
set(ax(2),'YTick',[])
set(ax(2),'Position',[0.05 0.25 0.25 0.25])
text(txtX,txtY,'B','Units','normalized');

ax(3)=subplot(222);
plot(t,tbl.rtScanPreAF{caseNum}(1:caseLen))
set(ax(3),'XTick',[])
set(ax(3),'YTick',[])
set(ax(3),'Position',[0.32 0.52 0.25 0.25])
text(txtX,txtY,'C','Units','normalized');

ax(4)=subplot(224);
plot(t,tbl.rtScanPostAF{caseNum}(1:caseLen))
set(ax(4),'XTick',[])
set(ax(4),'YTick',[])
set(ax(4),'Position',[0.32 0.25 0.25 0.25])
text(txtX,txtY,'D','Units','normalized');

%annotations were done by hand, then used "Show Code" functionality to
%retrieve the following code to duplicate. If the above case is changed,
%the annotation will not match
annotation(figH,'ellipse',...
    [0.106357142857143 0.321428571428571 0.0400714285714286 0.157142857142858],...
    'Color',[0.929411764705882 0.694117647058824 0.125490196078431]);
annotation(figH,'ellipse',...
    [0.394642857142857 0.602380952380953 0.0303571428571427 0.0714285714285716],...
    'Color',[1 0 0]);
annotation(figH,'ellipse',...
    [0.396428571428571 0.340476190476193 0.0303571428571423 0.0714285714285718],...
    'Color',[1 0 0]);
saveas(gcf,sprintf('%s/%s',saveFolder,'ExampleECG'),fileType);

%% Plot image of gradients
figH=figure;
caseNum=4;
caseLen=2000;
t=(1:caseLen)./1000;
txtX=0.05;
txtY=0.9;

ax(1)=subplot(211);
plot(t,tbl.gradientSum{caseNum}(1:caseLen))
set(ax(1),'XTick',[])
set(ax(1),'YTick',[])
set(ax(1),'Position',[0.05 0.52 0.25 0.25])
text(txtX,txtY,'A','Units','normalized');

ax(2)=subplot(212);
plot(t,tbl.rtScanPreAF{caseNum}(1:caseLen))
set(ax(2),'XTick',[])
set(ax(2),'YTick',[])
set(ax(2),'Position',[0.05 0.25 0.25 0.25])
text(txtX,txtY,'B','Units','normalized');
saveas(gcf,sprintf('%s/%s',saveFolder,'Gradients'),fileType);
%% Plot final results of all cases
figH=figure;
caseLen=2000;
t=(1:caseLen)./1000;
txtX=0.05;
txtY=0.85;
graph.X1=0.1;
graph.X2=0.51;
graph.Y=0.75;
graph.H=0.1;
graph.W=0.4;
graph.Sep=0.1;
graph.Labels={'A','B','C','D','E','F'};
graph.Xlim=[-2500 2500];
totalCases=height(tbl);
hold on
for c=1:totalCases
    subplot('Position',[graph.X1 graph.Y-graph.H*(c)+graph.Sep graph.W graph.H])
    plot(t,tbl.rtScanPreAF{c}(1:caseLen))
    ax(c)=gca;
    set(ax(c),'YLim',graph.Xlim);
    set(ax(c),'XTick',[])
    set(ax(c),'YTick',[])
    text(txtX,txtY,graph.Labels{c},'Units','normalized');   
    
    subplot('Position',[graph.X2 graph.Y-graph.H*(c)+graph.Sep graph.W graph.H])
    plot(t,tbl.rtScanPostAF{c}(1:caseLen))
    ax(c)=gca;
    set(ax(c),'YLim',graph.Xlim);
    set(ax(c),'XTick',[])
    set(ax(c),'YTick',[])
    text(txtX,txtY,strcat(graph.Labels{c},''''),'Units','normalized');       
end
saveas(gcf,sprintf('%s/%s',saveFolder,'AllCases'),fileType);
hold off

%% Plot examples of non-RT scans
figH=figure;
%caseLen=length(otherScans.rtScanPreAF{1});
caseLen=2e3;
t=(1:caseLen)./1000;
totalCases=height(otherScans);
graph.Labels=num2cell(upper(char('a'+(0:totalCases-1))));

txtX=0.01;
txtY=0.85;
graph.H=0.15;
graph.W=0.25;
graph.YSep=0.1;
graph.XSep=0.01;
graph.Y=0.85;
graph.X1=0.1;
graph.X2=graph.X1+graph.W+graph.XSep;
graph.X3=graph.X2+graph.W+graph.XSep;

graph.Xlim=[-500 500];
scaling=5;

hold on
for c=1:totalCases
    subplot('Position',[graph.X1 graph.Y-graph.H*(c)+graph.YSep graph.W graph.H])
    plot(t,otherScans.rtScanPreAF{c}(1:caseLen))
    ax(c)=gca;
    set(ax(c),'YLim',graph.Xlim);
    set(ax(c),'XTick',[])
    set(ax(c),'YTick',[])
    text(txtX,txtY,graph.Labels{c},'Units','normalized');   
    
    subplot('Position',[graph.X2 graph.Y-graph.H*(c)+graph.YSep graph.W graph.H])
    plot(t,otherScans.rtScanPostAF{c}(1:caseLen)./scaling)
    ax(c)=gca;
    set(ax(c),'YLim',graph.Xlim);
    set(ax(c),'XTick',[])
    set(ax(c),'YTick',[])
    text(txtX,txtY,strcat(graph.Labels{c},''''),'Units','normalized');  
    
    subplot('Position',[graph.X3 graph.Y-graph.H*(c)+graph.YSep graph.W graph.H])
    tmp=otherScans.gradientSum{c}(1:caseLen);
    plot(t,tmp./max(tmp))
    ax(c)=gca;
    %set(ax(c),'YLim',graph.Xlim);
    set(ax(c),'XTick',[])
    set(ax(c),'YTick',[])
    text(txtX,txtY,strcat(graph.Labels{c},''''''),'Units','normalized');    
end
saveas(gcf,sprintf('%s/%s',saveFolder,'NonRTscans'),fileType);
hold off
