function [] = SingleGeneBarPlots(ACC)
%% Plotting bar charts for single gene activity accuracy 
fig1 = figure();
subplot(2,1,1);
hold on;
tb = struct2table(ACC);
acc = (tb.acc);
name = string(tb.gene);
label = string(tb.datapt);
[sorted_acc,indx] = sort(acc);
sorted_name = [];
sorted_label =[];
for i=1:length(acc)
    sorted_name = [sorted_name name(indx(i))];
    sorted_label = [sorted_label label(indx(i))];
end
sorted_name = categorical(sorted_name);
sorted_name = reordercats(sorted_name,indx);
b = bar(sorted_name,sorted_acc,'FaceColor','red','FaceAlpha',0.4,'EdgeColor','black');
xtips1 = b(1).XEndPoints;
ytips1 = b(1).YEndPoints;
labels1 = sorted_label;
text(xtips1,ytips1,labels1,'HorizontalAlignment','center','VerticalAlignment','bottom')
hold on
subplot(2,1,2);
scatter(sorted_name,sorted_label,'*','r');
xlabel("Genes",'FontSize',15,'Interpreter','latex');
ylabel("Number of data points",'FontSize',15,'Interpreter','latex');
saveas(fig1,"ACCBarChart.png");
end