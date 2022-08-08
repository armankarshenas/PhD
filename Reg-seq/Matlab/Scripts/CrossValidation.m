%% Cross Validation
% This script optimises the threshold and kernel sizes for the deep
% learning model 

%% Specifications 
addpath(genpath(pwd));

Path_to_imgs = "/media/zebrafish/Data2/Arman/Data/LB_dataset/imgs";
Path_to_OneHots = "/media/zebrafish/Data2/Arman/Data/LB_dataset";

thresh = 0.05:0.05:0.25;


%% Main code 
cd(Path_to_OneHots)