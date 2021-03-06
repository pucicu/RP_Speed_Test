%% compare calculation speed different implementations

%% load data
files = dir('time_*.csv');
clear x
for i = 1:length(files)
   x{i} = load(files(i).name);
   txt{i} = strrep(strrep(files(i).name,'.csv',''),'time_','');
end

%% set line properties
props(1).Color = [0 .45 .74]; props(1).LineWidth = 3; props(1).LineStyle = ':';
props(2).Color = [.85 .33 .1]; props(2).LineWidth = 2; props(2).LineStyle = '--';
props(3).Color = [.93 .7 .13]; props(3).LineWidth = 2; props(3).LineStyle = '-';
props(4).Color = [.5 .18 .56]; props(4).LineWidth = 2; props(4).LineStyle = ':';
props(5).Color = [.47 .67 .19]; props(5).LineWidth = 1; props(5).LineStyle = '-';
props(6).Color = [.3 .75 .93]; props(6).LineWidth = 2; props(6).LineStyle = '--';
props(7).Color = [.64 .08 .18]; props(7).LineWidth = 2; props(7).LineStyle = '-.';
props(8).Color = [.0 .0 .0]; props(8).LineWidth = 2; props(8).LineStyle = '-.';
props(9).Color = [.9 .3 .0]; props(9).LineWidth = 1; props(9).LineStyle = ':';


%% create figure
clf
set(gcf, 'pos', [1487 537 1200 230])


%% plot calculation time for calculation of RP
ha1 = nexttile; hold on
for i = 1:length(files)
   if size(x{i},2) == 3
       h1(i) = semilogy(x{i}(:,1), (x{i}(:,2)), props(i));
   end
end

%% plot calculation time for calculation of RQA
ha2 = nexttile; hold on
for i = 1:length(files)
   if size(x{i},2) == 3
       h2(i) = semilogy(x{i}(:,1), (x{i}(:,3)), props(i));
   end
end

%% plot total calculation time
ha3 = nexttile; hold on
for i = 1:length(files)
   semilogy(x{i}(:,1), sum(x{i}(:,2:end),2), props(i));
end

%% beautify the plots
xlabel(ha1,'Length'), ylabel(ha1,'Time (sec)')
xlabel(ha2,'Length'), ylabel(ha2,'Time (sec)')
xlabel(ha3,'Length'), ylabel(ha3,'Time (sec)')
ha1.YAxis.Scale='log'; ha2.YAxis.Scale='log'; ha3.YAxis.Scale='log';
ha1.XAxis.Scale='log'; ha2.XAxis.Scale='log'; ha3.XAxis.Scale='log';
ha1.XLim = [100 100000]; ha2.XLim = [100 100000]; ha3.XLim = [100 100000];
ha1.YLim = [0.00005 100]; ha2.YLim = [0.00005 100]; ha3.YLim = [0.00005 100];
ha1.XTick = 10.^(2:5);
ha2.XTick = 10.^(2:5);
ha3.XTick = 10.^(2:5);
ha1.XTickLabel = num2str(ha1.XAxis.TickValues(:));
ha2.XTickLabel = num2str(ha2.XAxis.TickValues(:));
ha3.XTickLabel = num2str(ha2.XAxis.TickValues(:));
ha1.YAxis.TickValues = [.0001 .001 .01 .1 1 10 100];
ha2.YAxis.TickValues = [.0001 .001 .01 .1 1 10 100];
ha3.YAxis.TickValues = [.0001 .001 .01 .1 1 10 100];
ha1.YTickLabel = num2str(ha1.YAxis.TickValues(:));
ha2.YTickLabel = num2str(ha2.YAxis.TickValues(:));
ha3.YTickLabel = num2str(ha2.YAxis.TickValues(:));
grid(ha1,'on'), grid(ha2,'on'), grid(ha3,'on') 
box(ha1,'on'), box(ha2,'on'), box(ha3,'on') 
title(ha1, 'Calculation time RP')
title(ha2, 'Calculation time RQA')
title(ha3, 'Calculation time total')

ha4 = nexttile; axis off
h = legend(ha3,strrep(txt,'_','\_'), 'location', 'layout');
h.Layout.Tile=4;
h.Box = 'off';

