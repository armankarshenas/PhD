function [] = PlotSalientMap(Image,cmap,seq)
    heatmap(Image,'Colormap',cmap,'XDisplayLabels',seq,'YDisplayLabels',["A","T","C","G"]);
end
