function [] = PlotSalientMap(Image,cmap,seq,Path_to_save,name)
    cd(Path_to_save);
    name = name +".fig";
    figure()
    heatmap(Image,'Colormap',cmap,'XDisplayLabels',seq,'YDisplayLabels',["A","T","C","G"]);
    saveas(gcf,name);
    close
end
