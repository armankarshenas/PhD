function [] = PlotActivityDist(tb,OneHot)
genes = unique(tb.gene);
OH = struct2table(OneHot);
for i=1:length(genes)
    tb_gene = tb(string(tb.gene) == genes(i),:);
    OH_gene = OH(string(OH.gene))
    X = [tb_gene.ct_RNA tb_gene.ct_DNA];
    scatter(X(:,1),X(:,2),'Xscale','log')
  

end


end