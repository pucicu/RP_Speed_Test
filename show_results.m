%% compare calculation speed different implementations
%% load data
files = dir('time_*.csv');
clear x
for i = 1:length(files)
   x{i} = load(files(i).name);
   txt{i} = strrep(strrep(files(i).name,'.csv',''),'time_','');
end

%% plot data
clf
hold on
for i = 1:length(files)
   h(i) = semilogy(x{i}(:,1), (x{i}(:,2)));
end
xlabel('Length'), ylabel('Time (sec)')
legend(strrep(txt,'_','\_'), 'location', 'southeast')
ha = gca;
ha.YAxis.Scale='log';
ha.XAxis.Scale='log';
ha.XTickLabel = num2str(ha.XAxis.TickValues(:));
ha.YTickLabel = num2str(ha.YAxis.TickValues(:));
grid on, box on
axis([100 100000 0.001 30])

