%% Activation maps 
% This script generates saliency maps for models and inputs 

%% Specifications 
Path_to_data = "/media/zebrafish/Data2/Arman/Data/LB_dataset/0.20/imgs";
Path_to_model = "/media/zebrafish/Data2/Arman/Data/LB_dataset/0.20/Model/Single_genes";
%% Main code 
cd(Path_to_model)
Genes = dir(pwd);
for i=4:length(Genes)
cd(Path_to_model+"/"+Genes(i).name);
net = load(Genes(i).name+"_trained_network.mat");
net = net.net;
imds = imageDatastore(Path_to_data+"/Test/"+Genes(i).name,'IncludeSubfolders',true);
[YPred,scores] = classify(net,imds);
edges = 0:0.1:1;
h1 = histcounts(scores(:,1),edges);
h2 = histcounts(scores(:,2),edges);
h3 = histcounts(scores(:,3),edges);
fig1 = figure();
bar1 = bar(edges(1:end-1),[h1;h2;h3],'grouped');
set(bar1(3),'DisplayName','-1');
set(bar1(2),'DisplayName','0');
set(bar1(1),'DisplayName','1');
legend();
grid on;
saveas(fig1,"ScoresHistogram.fig");
close fig1

% Activation visualisation - does not work well 
%{
act = activations(net,imds,"fc_1");
sz = size(act);
act = reshape(act,[sz(1) sz(2) 1 sz(3)]);
%}

% Gradient visualization 
cd(Path_to_data)
cd ..
load("Test_sequences.fa")
OneHot = struct2table(OneHot);
tb = OneHot(contains(string(OneHot.index),Genes(i).name),:);

inputsz = net.Layers(1).InputSize;
gradcamMap = zeros(inputsz(1),inputsz(2),length(imds));
for j=1:length(imds)
    I = imread(string(imds.Files(j)));    
    gradcamMap(:,:,j) = gradCAM(net,I,YPred(j));
end




end
cd(Path_to_data)