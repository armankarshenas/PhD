function [] = SingleGeneBarPlots(ACC)
%% Plotting bar charts for single gene activity accuracy 
fig1 = figure();
hold on;
tb = struct2table(ACC);
acc = (tb.acc);
name = string(tb.gene);
[sorted_acc,indx] = sort(acc);
sorted_name = [];
for i=1:length(acc)
    sorted_name = [sorted_name name(indx(i))];
end
sorted_name = categorical(sorted_name);
sorted_name = reordercats(sorted_name,indx);
bar(sorted_name,sorted_acc,'FaceColor','red','FaceAlpha',0.4,'EdgeColor','black')
end