%% compare calculation speed different implementations

%% load data
files = dir('Results/time_*.csv');
clear x
for i = 1:length(files)
   x{i} = load(['Results/',files(i).name]);
   txt{i} = strrep(strrep(files(i).name,'.csv',''),'time_','');
end

files = dir('Results/rqa_*.csv');
clear y
for i = 1:length(files)
   y{i} = load(['Results/',files(i).name]);
end

% remove some results
idx = []
for i = 1:length(files)
   if strcmpi(txt{i}, 'RQA_OpenMP_gcc') || strcmpi(txt{i}, 'matlab_crp')
      idx = [idx, i];
   end
end
x(idx) = []; y(idx) = []; txt(idx) = [];

%% set line properties
c_matlab = [.2 .9 .0];
c_R = [0 0 0];
c_C = [.4 .6 .1];
c_C2 = [.2 .9 .0];
c_julia2 = [.13 .7 .93];
c_julia = [.75 .45 .74];
c_python = [.95 .6 .0];
c_python2 = [.75 .33 .1];
c_misc =[.63 .7 .13]; % [.7 .0 .0] [.3 .3 .8] [.6 .3 .1] [0 .1 .8]
props(1).Color = c_R; props(1).LineWidth = 3; props(1).LineStyle = ':';
props(2).Color = c_C; props(2).LineWidth = 2; props(2).LineStyle = '--';
props(3).Color = c_julia; props(3).LineWidth = 2; props(3).LineStyle = '--';
props(4).Color = c_julia; props(4).LineWidth = 2; props(4).LineStyle = ':';
props(5).Color = c_julia2; props(5).LineWidth = 1; props(5).LineStyle = '-.';
props(6).Color = c_julia2; props(6).LineWidth = 3; props(6).LineStyle = ':';
props(7).Color = c_matlab; props(7).LineWidth = 2; props(7).LineStyle = '--';
props(8).Color = c_matlab; props(8).LineWidth = 1; props(8).LineStyle = '-';
props(9).Color = c_python2; props(9).LineWidth = 2; props(9).LineStyle = '--';
props(10).Color = c_python2; props(10).LineWidth = 2; props(10).LineStyle = '-.';
props(11).Color = c_python; props(11).LineWidth = 2; props(11).LineStyle = '-.';
props(12).Color = c_python; props(12).LineWidth = 2; props(12).LineStyle = ':';
props(13).Color = c_python; props(13).LineWidth = 1; props(13).LineStyle = '-';
props(14).Color = c_misc; props(14).LineWidth = 2; props(14).LineStyle = ':';
props(15).Color = c_python; props(15).LineWidth = 1; props(15).LineStyle = '-';


%% create figure
clf
set(gcf, 'pos', [87 537 950 230])


%% plot calculation time for calculation of RP
ha1 = nexttile; hold on
for i = 1:length(x)
   h1(i) = loglog(x{i}(:,1), (x{i}(:,2)), props(i));
end

%% plot calculation time for calculation of RQA
ha2 = nexttile; hold on
for i = 1:length(x)
   h2(i) = loglog(x{i}(:,1), (x{i}(:,3)), props(i));
end


%% beautify the plots
xlabel(ha1,'Length'), ylabel(ha1,'Time (sec)')
xlabel(ha2,'Length'), ylabel(ha2,'Time (sec)')
ha1.YAxis.Scale='log'; ha2.YAxis.Scale='log';
ha1.XAxis.Scale='log'; ha2.XAxis.Scale='log';
ha1.XLim = [100 500000]; ha2.XLim = [100 500000];
ha1.YLim = [0.00005 600]; ha2.YLim = [0.00005 600];
ha1.XTick = 10.^(2:6);
ha2.XTick = 10.^(2:6);
ha1.XTickLabel = num2str(ha1.XAxis.TickValues(:));
ha2.XTickLabel = num2str(ha2.XAxis.TickValues(:));
ha1.YAxis.TickValues = [.0001 .001 .01 .1 1 10 100];
ha2.YAxis.TickValues = [.0001 .001 .01 .1 1 10 100];
ha1.YTickLabel = num2str(ha1.YAxis.TickValues(:));
ha2.YTickLabel = num2str(ha2.YAxis.TickValues(:));
grid(ha1,'on'), grid(ha2,'on')
box(ha1,'on'), box(ha2,'on') 
title(ha1, 'Calculation time RP')
title(ha2, 'Calculation time RQA')

ha4 = nexttile; axis off
h = legend(ha2,strrep(txt,'_','\_'), 'location', 'layout');
h.Layout.Tile=4;
h.Box = 'off';
h.FontSize=11;
h.Parent.Position = [0.06 0.15 0.95 0.76];
h.Location = 'none';
h.Position = [0.7329 0.1532 0.1415 0.7535];

%% export figure as SVG
print(gcf,'rp_rqa_speed-test.svg', '-dsvg')




% %% plot RQA results for comparison
% clf
% ha1 = nexttile; hold on
% 
% i_meas = 2;
% for i = 1:length(y)
%    h1(i) = plot(y{i}(:,1), (y{i}(:,i_meas)), props(i));
% end
% 
% h = legend(ha1,strrep(txt,'_','\_'));


