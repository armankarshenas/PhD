
print("Importing packages ...")
import os
import tensorflow as tf
import keras
import keras.layers as kl
from keras.layers.convolutional import Conv1D, MaxPooling1D
from keras.layers.core import Dropout, Reshape, Dense, Activation, Flatten
from keras.layers import BatchNormalization, InputLayer, Input
from keras import models
from keras.models import Sequential, Model
from tensorflow.keras.optimizers import Adam
from keras.callbacks import EarlyStopping, History, ModelCheckpoint

import pandas as pd
import numpy as np

import sys
from Neural_Network_DNA_Demo.helper import IOHelper, SequenceHelper # from https://github.com/const-ae/Neural_Network_DNA_Demo

import random
random.seed(1234)

print("Defining functions ...")
# function to load sequences and enhancer activity

def prepare_input(set):
    # Convert sequences to one-hot encoding matrix
    file_seq = str("Data/"+set+"_sequences.fa")
    input_fasta_data_A = IOHelper.get_fastas_from_file(file_seq, uppercase=True)

    # get length of first sequence
    sequence_length = len(input_fasta_data_A.sequence.iloc[0])

    # Convert sequence to one hot encoding matrix
    seq_matrix_A = SequenceHelper.do_one_hot_encoding(input_fasta_data_A.sequence, sequence_length,SequenceHelper.parse_alpha_to_seq)
    print(seq_matrix_A.shape)

    X = np.nan_to_num(seq_matrix_A) # Replace NaN with zero and infinity with large finite numbers
    X_reshaped = X.reshape((X.shape[0], X.shape[1], X.shape[2]))

    Activity = pd.read_table("Data/"+set +"_activity.txt",sep=',')
    ct_RNA = Activity.ct_RNA
    ct_DNA = Activity.ct_DNA
    Y = [ct_RNA, ct_DNA]

    print(set)

    return input_fasta_data_A.sequence, seq_matrix_A, X_reshaped, Y

### Additional metrics
from scipy.stats import spearmanr
def Spearman(y_true, y_pred):
     return ( tf.py_function(spearmanr, [tf.cast(y_pred, tf.float32),
                       tf.cast(y_true, tf.float32)], Tout = tf.float32) )

print("Downloading fasta files ...")
# FASTA files with DNA sequences of genomic regions from train/val/test sets
#!wget 'https://data.starklab.org/almeida/DeepSTARR/Data/Sequences_activity_Train.fa'
#!wget 'https://data.starklab.org/almeida/DeepSTARR/Data/Sequences_activity_Val.fa'
#!wget 'https://data.starklab.org/almeida/DeepSTARR/Data/Sequences_activity_Test.fa'

# Files with developmental and housekeeping activity of genomic regions from train/val/test sets
#!wget 'https://data.starklab.org/almeida/DeepSTARR/Data/Sequences_activity_Train.txt'
#!wget 'https://data.starklab.org/almeida/DeepSTARR/Data/Sequences_activity_Val.txt'
#!wget 'https://data.starklab.org/almeida/DeepSTARR/Data/Sequences_activity_Test.txt'

print("Reading in the inputs ... ")
# Data for train/val/test sets
X_train_sequence, X_train_seq_matrix, X_train, Y_train = prepare_input("Train")
print("Training dataset")
X_valid_sequence, X_valid_seq_matrix, X_valid, Y_valid = prepare_input("Valid")
print("Validation dataset")
X_test_sequence, X_test_seq_matrix, X_test, Y_test = prepare_input("Test")
print("Testing dataset")
print("Setting training parameters ...")

params = {'batch_size': 128,
          'epochs': 100,
          'early_stop': 10,
          'kernel_size1': 7,
          'kernel_size2': 3,
          'kernel_size3': 5,
          'kernel_size4': 3,
          'lr': 0.002,
          'num_filters': 256,
          'num_filters2': 60,
          'num_filters3': 60,
          'num_filters4': 120,
          'n_conv_layer': 4,
          'n_add_layer': 2,
          'dropout_prob': 0.4,
          'dense_neurons1': 256,
          'dense_neurons2': 256,
          'pad':'same'}

def DeepSTARR(params=params):

    lr = params['lr']
    dropout_prob = params['dropout_prob']
    n_conv_layer = params['n_conv_layer']
    n_add_layer = params['n_add_layer']

    # body
    input = kl.Input(shape=(160, 4))
    x = kl.Conv1D(params['num_filters'], kernel_size=params['kernel_size1'],
                  padding=params['pad'],
                  name='Conv1D_1st')(input)
    x = BatchNormalization()(x)
    x = Activation('relu')(x)
    x = MaxPooling1D(2)(x)

    for i in range(1, n_conv_layer):
        x = kl.Conv1D(params['num_filters'+str(i+1)],
                      kernel_size=params['kernel_size'+str(i+1)],
                      padding=params['pad'],
                      name=str('Conv1D_'+str(i+1)))(x)
        x = BatchNormalization()(x)
        x = Activation('relu')(x)
        x = MaxPooling1D(2)(x)

    x = Flatten()(x)

    # dense layers
    for i in range(0, n_add_layer):
        x = kl.Dense(params['dense_neurons'+str(i+1)],
                     name=str('Dense_'+str(i+1)))(x)
        x = BatchNormalization()(x)
        x = Activation('relu')(x)
        x = Dropout(dropout_prob)(x)
    bottleneck = x

    # heads per task (developmental and housekeeping enhancer activities)
    tasks = ['ct_DNA', 'ct_RNA']
    outputs = []
    for task in tasks:
        outputs.append(kl.Dense(1, activation='linear', name=str('Dense_' + task))(bottleneck))

    model = keras.models.Model([input], outputs)
    model.compile(keras.optimizers.Adam(lr=lr),
                  loss=['mse', 'mse'], # loss
                  loss_weights=[1, 1], # loss weigths to balance
                  metrics=[Spearman]) # additional track metric

    return model, params


DeepSTARR()[0].summary()
DeepSTARR()[1] # dictionary


def train(selected_model, X_train, Y_train, X_valid, Y_valid, params):

    my_history=selected_model.fit(X_train, Y_train,
                                  validation_data=(X_valid, Y_valid),
                                  batch_size=params['batch_size'], epochs=params['epochs'],
                                  callbacks=[EarlyStopping(patience=params['early_stop'], monitor="val_loss", restore_best_weights=True),
                                             History()])

    return selected_model, my_history


print("Training the model ...")
main_model, main_params = DeepSTARR()
main_model, my_history = train(main_model, X_train, Y_train, X_valid, Y_valid, main_params)




from scipy import stats
from sklearn.metrics import mean_squared_error

# create functions
def summary_statistics(X, Y, set, task):
    pred = main_model.predict(X, batch_size=main_params['batch_size'])
    if task =="ct_DNA":
        i=0
    if task =="ct_RNA":
        i=1
    print(set + ' MSE ' + task + ' = ' + str("{0:0.2f}".format(mean_squared_error(Y, pred[i].squeeze()))))
    print(set + ' PCC ' + task + ' = ' + str("{0:0.2f}".format(stats.pearsonr(Y, pred[i].squeeze())[0])))
    print(set + ' SCC ' + task + ' = ' + str("{0:0.2f}".format(stats.spearmanr(Y, pred[i].squeeze())[0])))



print("Evaluating the model ...")
# run for each set and enhancer type
summary_statistics(X_train, Y_train[0], "train", "ct_DNA")
summary_statistics(X_train, Y_train[1], "train", "ct_RNA")
summary_statistics(X_valid, Y_valid[0], "validation", "ct_DNA")
summary_statistics(X_valid, Y_valid[1], "validation", "ct_RNA")
summary_statistics(X_test, Y_test[0], "test", "ct_DNA")
summary_statistics(X_test, Y_test[1], "test", "ct_RNA")

print("Saving the trained model ...")
model_name="Ecoli_regseq"

model_json = main_model.to_json()
with open('Model_' + model_name + '.json', "w") as json_file:
    json_file.write(model_json)
main_model.save_weights('Model_' + model_name + '.h5')
