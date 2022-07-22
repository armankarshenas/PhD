trainingSetup = load("/Users/karshenas/Arman/BerkeleyPhD/PhD/Reg-seq/trainingSetup_2022_07_22__10_45_14.mat");

Import Data
Import training and validation data.
imdsTrain = trainingSetup.imdsTrain;
[imdsTrain, imdsValidation] = splitEachLabel(imdsTrain,0.7);

% Resize the images to match the network input layer.
augimdsTrain = augmentedImageDatastore([4 160 1],imdsTrain);
augimdsValidation = augmentedImageDatastore([4 160 1],imdsValidation);

Set Training Options
Specify options to use when training.
opts = trainingOptions("sgdm",...
    "ExecutionEnvironment","auto",...
    "InitialLearnRate",0.01,...
    "Shuffle","every-epoch",...
    "Plots","training-progress",...
    "ValidationData",augimdsValidation);

Create Array of Layers
layers = [
    imageInputLayer([4 160 1],"Name","SequenceInput")
    convolution2dLayer([7 7],256,"Name","conv_1","Padding","same")
    convolution2dLayer([3 3],60,"Name","conv_2","Padding","same")
    batchNormalizationLayer("Name","batchnorm_1")
    reluLayer("Name","relu_1")
    maxPooling2dLayer([2 2],"Name","maxpool_1","Padding","same")
    convolution2dLayer([5 5],60,"Name","conv_4","Padding","same")
    batchNormalizationLayer("Name","batchnorm_3")
    reluLayer("Name","relu_3")
    maxPooling2dLayer([2 2],"Name","maxpool_3","Padding","same")
    convolution2dLayer([3 3],120,"Name","conv_3","Padding","same")
    batchNormalizationLayer("Name","batchnorm_2")
    reluLayer("Name","relu_2")
    maxPooling2dLayer([2 2],"Name","maxpool_2","Padding","same")
    fullyConnectedLayer(256,"Name","fc_1")
    batchNormalizationLayer("Name","batchnorm_4")
    reluLayer("Name","relu_4")
    dropoutLayer(0.4,"Name","dropout_1")
    fullyConnectedLayer(2,"Name","fc_2")
    batchNormalizationLayer("Name","batchnorm_5")
    reluLayer("Name","relu_5")
    dropoutLayer(0.4,"Name","dropout_2")
    softmaxLayer("Name","softmax")
    classificationLayer("Name","classoutput")];

Train Network
Train the network using the specified options and training data.
[net, traininfo] = trainNetwork(augimdsTrain,layers,opts);