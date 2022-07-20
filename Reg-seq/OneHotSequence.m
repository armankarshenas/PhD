%% This script generates matrices for each sequence as a one-hot encoder

%% Specifications 
addpath(genpath("/Users/karshenas/Arman/BerkeleyPhD/PhD/Reg-seq"))
Path_to_data = "/Users/karshenas/Arman/BerkeleyPhD/Yr2/Reg-seq/Data/LB_dataset";
Path_to_save = "/Users/karshenas/Arman/BerkeleyPhD/Yr2/Reg-seq/Data/LB_dataset/imgs";

%% Main code 
cd(Path_to_data)
FST_files = dir(fullfile(pwd,"*.fa"));
for i=1:length(FST_files)
    OneHot = struct();
    fst = fastaread(FST_files(i).folder + "/"+ FST_files(i).name);
    for j=1:length(fst)
        seq_read = OneHotEncoder(fst(j).Sequence);
        WriteImageToTIFF(seq_read,Path_to_save,FST_files(i).name,j);
        OneHot(j).data = seq_read;
        OneHot(j).index = fst(j).Header;
    end
    cd(Path_to_save)
    name = split(FST_files(i).name,".fa");
    name = name{1};
    name = name + ".mat";
    save(name,'OneHot');
end

