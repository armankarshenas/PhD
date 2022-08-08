function [] = SingleGeneBarPlots(ACC)
%% Plotting bar charts for single gene activity accuracy 
fig1 = figure();
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
saveas(fig1,"ACCBarChart.png");
end