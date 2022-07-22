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
    counter = 0;
    path_name = split(FST_files(i).name,"_");
    path_name = path_name{1};
    cd(Path_to_save);
    mkdir(path_name);
    path_name = Path_to_save + "/" + path_name;
    for j=1:length(fst)
        seq_read = OneHotEncoder(fst(j).Sequence);
        WriteImageToTIFF(seq_read,path_name,FST_files(i).name,j,counter);
        OneHot(j).data = seq_read;
        OneHot(j).index = fst(j).Header;
        counter = counter +1;
    end
    cd(Path_to_data)
    name = split(FST_files(i).name,".fa");
    name = name{1};
    name = name + ".mat";
    save(name,'OneHot');
end

