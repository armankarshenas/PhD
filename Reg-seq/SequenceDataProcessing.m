%% Sequence-expression data processing 
% This script reads in CSV file from Rob Philips' group at Caltech and
% reshapes sequences to images and exports them into a new directory along
% with the corresponding expression level
 
%% Specifications 
Path_to_data = "~/Arman/BerkeleyPhD/Yr2/Reg-seq";
% bit assignment will be done based on A:1, C:2, G:3, T:4



%% Main code body
cd(Path_to_data);
seq_file = dir(fullfile(pwd,"*.csv"));
sequences = readtable(seq_file(1).name);
fprintf("Showing a preview of the data ...\n");
head(sequences)

binary_seq = table();
binary_seq(:,1:4) = sequences(:,1:4);
binary_seq.Properties.VariableNames{'Var1'} = 'ct_DNA';
binary_seq.Properties.VariableNames{'Var2'} = 'ct_RNA';
binary_seq.Properties.VariableNames{'Var3'} = 'gene';
binary_seq.Properties.VariableNames{'Var4'} = 'n_mut';
SeqMatrix = cell2mat(sequences{:,6});
SeqMatrixBinary = nt2int((SeqMatrix));
binary_seq(:,5) = table(SeqMatrixBinary);
binary_seq.Properties.VariableNames{'Var5'} = 'sequence';
fprintf("Showing a preview of the binary sequence ...\n");
head(binary_seq)
cd(Path_to_data)
writetable(binary_seq,"Binary_seq.csv");
%% Image generation 
fprintf("Writing images ... \n")
cd(Path_to_data)
mkdir("BinaryImages")
cd("BinaryImages")

tagstruct.ImageLength = 16;
tagstruct.ImageWidth = 10;
tagstruct.Compression = Tiff.Compression.None;
tagstruct.SampleFormat = Tiff.SampleFormat.IEEEFP;
tagstruct.Photometric = Tiff.Photometric.MinIsBlack;
tagstruct.BitsPerSample = 32;
tagstruct.PlanarConfiguration = Tiff.PlanarConfiguration.Chunky;

for i=1:size(SeqMatrixBinary,1)
    tic;
    temp = reshape(SeqMatrixBinary(i,:),10,16)';
    temp = single(temp);
    temp = histeq(temp);
    name = string(i) + ".tif";
    tiffObject = Tiff(name, 'w');
    tiffObject.setTag(tagstruct);
    tiffObject.write(temp);
    tiffObject.close;
    toc
end





%{ 
This takes 50 days to run! 
for i=1:height(sequences)
    tic;
    temp = sequences.sequence{i};
    temp_binary = zeros(1,length(temp));
    for j=1:length(temp)
        if temp(j) == "T"
            temp_binary(j) = 1;
        elseif temp(j) == "C" 
            temp_binary(j) = 2;
        elseif temp(j) == "G" 
            temp_binary(j) = 3;
        end
    end
    binary_seq(i,5) = table(temp_binary);
    toc
end
%}
 
