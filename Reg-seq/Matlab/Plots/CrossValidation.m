function [] = CrossValidation(ACC,Path_to_save)

fig = figure();
subplot(3,1,1);
kernel_sz = 3:1:10;
best_acc = zeros(1,length(ACC));
mean_acc = zeros(1,length(ACC));
names = [];
for i=1:length(ACC)
    plot(kernel_sz,ACC(i).acc,'DisplayName',ACC(i).gene);
    hold on;
    best_acc(i) = max(ACC(i).acc);
    mean_acc(i) = mean(ACC(i).acc);
    names = [names ACC(i).gene];
end
xlabel("Motif Size (bp)",'FontSize',14,'Interpreter','latex');
ylabel("Classification accuracy",'FontSize',14,'Interpreter','latex');
legend();
grid on;

[sorted_best_acc,indxbst] = sort(best_acc);
[sorted_mean_acc,indxmean] = sort(mean_acc);

sorted_name_best = categorical(cellstr(names));
sorted_name_mean = categorical(cellstr(names));

sorted_name_best = reordercats(sorted_name_best,indxbst);
sorted_name_mean = reordercats(sorted_name_mean,indxmean);

subplot(3,1,2)
scatter(sorted_name_best,sorted_best_acc);
xlabel("Genes",'FontSize',14,'Interpreter','latex');
ylabel("Best classification accuracy",'FontSize',14,'Interpreter','latex');

subplot(3,1,3);
scatter(sorted_name_mean,sorted_mean_acc);
xlabel("Genes",'FontSize',14,'Interpreter','latex');
ylabel("Mean classification accuracy",'FontSize',14,'Interpreter','latex');

cd(Path_to_save)
saveas(gca,"CrossValidation.fig")
end