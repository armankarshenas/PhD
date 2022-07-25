%% Sequence-expression data processing 
% This script reads in CSV file from Rob Philips' group at Caltech and
% reshapes sequences to images and exports them into a new directory along
% with the corresponding expression level
 
%% Specifications 
Path_to_data = "~/Arman/BerkeleyPhD/Yr2/Reg-seq/RawData";
Path_to_save = "~/Arman/BerkeleyPhD/Yr2/Reg-seq/Data/LB_dataset";
% threshold of activity for labelling (default 20%)
act_thresh = 0.2;
% training and test fraction of the data 
train_f = 0.7;
test_f = 0.15;


%% Main code body
cd(Path_to_data);
seq_file = dir(fullfile(pwd,"*.csv"));
sequences = readtable(seq_file(3).name);
fprintf("Showing a preview of the data ...\n");
head(sequences)
sequences.Properties.VariableNames{5} = 'sequence';
sequences.Properties.VariableNames{4} = 'ct_DNA';
sequences.Properties.VariableNames{2} = 'ct_RNA';
header = string(sequences.gene(:)) + "_"+cell2mat(sequences.barcode(1:height(sequences)));
sequences{:,width(sequences)+1} = header;
sequences.Properties.VariableNames{'Var8'} = 'Header';
sequences(any(ismissing(sequences),2),:) = [];

% Label the dataset
sequences = RNASeqLabel(sequences,act_thresh);

% Partitioning the dataset
[tb_test,tb_val,tb_train] = PartitionDataSet(train_f,test_f,sequences);

cd(Path_to_save)
% Training data
fastawrite("Train_sequences.fa",string(sequences.Header(1:train_idx)),string(sequences.sequence(1:train_idx,:)));
writetable(tb_train,"Train_activity.txt");
Train_label = [table2array(tb_train.label_RNA) table2array(tb_train.label_DNA)];
save("Train_label.mat",'Train_label');
% Testing data 
fastawrite("Test_sequences.fa",string(sequences.Header(train_idx+1:train_idx+test_idx)),string(sequences.sequence(train_idx+1:train_idx+test_idx,:)));
writetable(tb_test,"Test_activity.txt");
Test_label = [table2array(tb_test.label_RNA) table2array(tb_test.label_DNA)];
save("Test_label.mat",'Test_label');
% Validation data
fastawrite("Valid_sequences.fa",string(sequences.Header(train_idx+test_idx+1:end)),string(sequences.sequence(train_idx+test_idx+1:end,:)));
writetable(tb_val,"Valid_activity.txt");
Valid_label = [table2array(tb_val.label_RNA) table2array(tb_val.label_DNA)];
save("Valid_label.mat",'Valid_label');

