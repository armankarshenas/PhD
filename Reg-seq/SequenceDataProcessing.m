%% Sequence-expression data processing 
% This script reads in CSV file from Rob Philips' group at Caltech and
% reshapes sequences to images and exports them into a new directory along
% with the corresponding expression level
 
%% Specifications 
Path_to_data = "~/Arman/BerkeleyPhD/Yr2/Reg-seq/DawData";
Path_to_save = "~/Arman/BerkeleyPhD/Yr2/Reg-seq/Data";
% bit assignment will be done based on A:1, C:2, G:3, T:4
train_f = 0.7;
test_f = 0.15;
% training and test fraction of the data 


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
%% Write fasta files 
header = string(sequences.gene(:)) + "_"+cell2mat(sequences.barcode(1:height(sequences)));
sequences{:,width(sequences)+1} = header;
sequences.Properties.VariableNames{'Var7'} = 'Header';
index = randperm(size(sequences,1));
sequences = sequences(index,:);
train_idx = floor(size(sequences,1)*train_f);
test_idx = floor(size(sequences,1)*test_f);
val_idx = size(sequences,1) - train_idx-test_idx;
cd(Path_to_save)
% Training data
fastawrite("Train_sequences.fa",string(sequences.Header(1:train_idx)),string(sequences.sequence(1:train_idx)));
tb_train = table();
tb_train(:,1) = table(sequences.Header(1:train_idx));
tb_train(:,2) = table(sequences.ct_DNA(1:train_idx));
tb_train(:,3) = table(sequences.ct_RNA(1:train_idx));
tb_train.Properties.VariableNames{'Var1'} = 'Header';
tb_train.Properties.VariableNames{'Var2'} = 'ct_DNA';
tb_train.Properties.VariableNames{'Var3'} = 'ct_RNA';
writetable(tb_train,"Train_activity.txt");
% Testing data 
fastawrite("Test_sequences.fa",string(sequences.Header(train_idx+1:train_idx+test_idx)),string(sequences.sequence(train_idx+1:train_idx+test_idx)));
tb_test = table();
tb_test(:,1) = table(sequences.Header(train_idx+1:train_idx+test_idx));
tb_test(:,2) = table(sequences.ct_DNA(train_idx+1:train_idx+test_idx));
tb_test(:,3) = table(sequences.ct_RNA(train_idx+1:train_idx+test_idx));
tb_test.Properties.VariableNames{'Var1'} = 'Header';
tb_test.Properties.VariableNames{'Var2'} = 'ct_DNA';
tb_test.Properties.VariableNames{'Var3'} = 'ct_RNA';
writetable(tb_test,"Test_activity.txt");
% Validation data
fastawrite("Valid_sequences.fa",string(sequences.Header(train_idx+test_idx+1:end)),string(sequences.sequence(train_idx+test_idx+1:end)));
tb_val = table();
tb_val(:,1) = table(sequences.Header(train_idx+test_idx+1:end));
tb_val(:,2) = table(sequences.ct_DNA(train_idx+test_idx+1:end));
tb_val(:,3) = table(sequences.ct_RNA(train_idx+test_idx+1:end));
tb_val.Properties.VariableNames{'Var1'} = 'Header';
tb_val.Properties.VariableNames{'Var2'} = 'ct_DNA';
tb_val.Properties.VariableNames{'Var3'} = 'ct_RNA';
writetable(tb_test,"Valid_activity.txt");


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
 
