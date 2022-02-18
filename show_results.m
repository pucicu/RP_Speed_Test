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

txt2 = {}; k = 1;
for i = 1:length(files)
   if size(x{i},2) == 3
       ha1 = subplot(121); hold on
       h1(i) = semilogy(x{i}(:,1), (x{i}(:,2)));
       ha2 = subplot(122); hold on
       h2(i) = semilogy(x{i}(:,1), (x{i}(:,3)));
       txt2{k} = txt{i}; 
       k = k+1;
   end
end
xlabel(ha1,'Length'), ylabel(ha1,'Time (sec)')
xlabel(ha2,'Length'), ylabel(ha2,'Time (sec)')
legend(ha1,strrep(txt2,'_','\_'), 'location', 'southeast')
legend(ha2,strrep(txt2,'_','\_'), 'location', 'southeast')
ha1.YAxis.Scale='log'; ha2.YAxis.Scale='log';
ha1.XAxis.Scale='log'; ha2.XAxis.Scale='log';
ha1.XLim = [100 100000]; ha2.XLim = [100 100000];
ha1.YLim = [0.0001 30]; ha2.YLim = [0.0001 30];
ha1.XTickLabel = num2str(ha1.XAxis.TickValues(:));
ha2.XTickLabel = num2str(ha2.XAxis.TickValues(:));
ha1.YTickLabel = num2str(ha1.YAxis.TickValues(:));
ha2.YTickLabel = num2str(ha2.YAxis.TickValues(:));
grid(ha1,'on'), grid(ha2,'on') 
box(ha1,'on'), box(ha2,'on') 

