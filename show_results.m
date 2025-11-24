%% compare calculation speed different implementations

%% load data
files = dir('Results/time_*.csv');
clear x
for i = 1:length(files)
   x{i} = load(['Results/',files(i).name]);
   txt{i} = strrep(strrep(files(i).name,'.csv',''),'time_','');
end

% remove some results
idx = []
for i = 1:length(files)
   if strcmpi(txt{i}, 'RQA_HPC') || strcmpi(txt{i}, 'RQA_OpenMP_gcc')
      idx = [idx, i];
   end
end
x(idx) = []; txt(idx) = [];

%% set line properties
c_matlab = [.47 .67 .19];
c_R = [0 0 0];
c_julia = [.13 .7 .93];
c_julia2 = [0 .45 .74];
c_C = [.85 .33 .1];
c_python = [.9 .5 .0];
c_misc =[.93 .7 .13]; % [.7 .0 .0] [.1 .8 .0] [.3 .3 .8] [.6 .3 .1] [0 .1 .8]
props(1).Color = c_R; props(1).LineWidth = 2; props(1).LineStyle = ':';
props(2).Color = c_C; props(2).LineWidth = 3; props(2).LineStyle = '-';
props(3).Color = c_julia2; props(3).LineWidth = 3; props(3).LineStyle = ':';
props(4).Color = c_julia; props(4).LineWidth = 2; props(4).LineStyle = '--';
props(5).Color = c_julia; props(5).LineWidth = 1; props(5).LineStyle = '-';
props(6).Color = c_julia; props(6).LineWidth = 1; props(6).LineStyle = '-.';
props(7).Color = c_matlab; props(7).LineWidth = 3; props(7).LineStyle = ':';
props(8).Color = c_python; props(8).LineWidth = 1; props(8).LineStyle = '-';
props(9).Color = c_python; props(9).LineWidth = 2; props(9).LineStyle = '-.';
props(10).Color = c_python; props(10).LineWidth = 2; props(10).LineStyle = ':';
props(11).Color = c_python; props(11).LineWidth = 1; props(11).LineStyle = '--';
props(12).Color = c_python; props(12).LineWidth = 2; props(12).LineStyle = '--';
props(13).Color = [.6 .3 .1]; props(13).LineWidth = 2; props(13).LineStyle = '-.';
props(14).Color = [0 .1 .8]; props(14).LineWidth = 2; props(14).LineStyle = ':';


%% create figure
clf
set(gcf, 'pos', [87 537 950 230])


%% plot calculation time for calculation of RP
ha1 = nexttile; hold on
for i = 1:length(x)
   if size(x{i},2) == 3
       h1(i) = loglog(x{i}(:,1), (x{i}(:,2)), props(i));
   end
end

%% plot calculation time for calculation of RQA
ha2 = nexttile; hold on
for i = 1:length(x)
   if size(x{i},2) == 3
       h2(i) = loglog(x{i}(:,1), (x{i}(:,3)), props(i));
   end
end

%% plot total calculation time
ha3 = nexttile; hold on
for i = 1:length(x)
   loglog(x{i}(:,1), sum(x{i}(:,2:end),2), props(i));
   idx = find(x{i}(:,2)); idx(isnan(x{i}(idx,2))) = []; idx(1:floor(length(idx)/2)) = [];
   p_ = polyfit(log10(x{i}(idx,1)), log10(x{i}(idx,2)),1);
   p(i) = p_(1);
end

%% beautify the plots
xlabel(ha1,'Length'), ylabel(ha1,'Time (sec)')
xlabel(ha2,'Length'), ylabel(ha2,'Time (sec)')
xlabel(ha3,'Length'), ylabel(ha3,'Time (sec)')
ha1.YAxis.Scale='log'; ha2.YAxis.Scale='log'; ha3.YAxis.Scale='log';
ha1.XAxis.Scale='log'; ha2.XAxis.Scale='log'; ha3.XAxis.Scale='log';
ha1.XLim = [100 1000000]; ha2.XLim = [100 1000000]; ha3.XLim = [100 1000000];
ha1.YLim = [0.00005 600]; ha2.YLim = [0.00005 600]; ha3.YLim = [0.00005 600];
ha1.XTick = 10.^(2:6);
ha2.XTick = 10.^(2:6);
ha3.XTick = 10.^(2:6);
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
h.FontSize=11;
h.Parent.Position = [0.06 0.15 0.95 0.76]

%% export figure as SVG
print(gcf,'rp_rqa_speed-test.svg', '-dsvg')
