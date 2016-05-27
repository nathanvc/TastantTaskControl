% Plot raw data

function plotrawdata_detlick_nodataproc(data, rate)

ts=1000/rate;
tv=0:ts:(length(data)-1)*ts;

plot(tv,data(:,[1:6 8 9]))
hold on
plot(tv,data(:,7),'color','black')
%hold on
%plot(dataproc.timevect(dataproc.elick_ind.all), 2*ones(size(dataproc.elick_ind.all)),'*','color','magenta','markersize',10);
xlabel('Time(sec)','fontsize',12)
ylabel('Voltage','fontsize',12)
ylim([-0.5 5.5])

