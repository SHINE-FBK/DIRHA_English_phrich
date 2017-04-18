# Introduction:

The phonetically-rich part of the DIRHA English Dataset [1,2] is a multi-microphone acoustic corpus being developed under the EC project Distant-speech Interaction for Robust Home Applications ([DIRHA](https://dirha.fbk.eu/)). The corpus is composed of real phonetically-rich sentences recorded  with 32 sample-synchronized microphones in a domestic environment. 

The database contains signals of different characteristics in terms of reverberation making it suitable for various multi-microphone signal processing and distant speech recognition tasks. The part of the dataset currently released is composed of  4 native US speakers (2 Males, 2 Females) uttering  192 sentences from the Harvard corpus simultaneously recorded with 32 microphones. All the sentences has been automatically annotated at phone-level and manually check by an expert and can be used for test purposes.
You can download the database here:

The current repository  provides the related Kaldi recipe and the tools that are necessary to run a kaldi-based distant phone recognizer.. A contaminated version of the original TIMIT corpus is used for training, while test is performed with the DIRHA English wsj dataset. More information can be found in the reference papers [1,2]

# How to run the recipe:

0) Download the dataset from here:

https://dirha.fbk.eu/dirha-english-phdev-agreement

1)  Make sure to have the standard TIMIT dataset available (for training purposes)

2) make sure that your KALDI installation is working. Try for instance to launch “egs/TIMIT/s5/run.sh” and check whether everything is properly working.

3) Generate Contaminated TIMIT dataset.
   
   - A. Open Matlab
   - B. Open “Tools/Data_Contamination.m” (or "Tools/for_Matlab_older_than_R2014a/OldMatlab_Data_Contamination.m if your Matlab version is older than R2014a)
   - C. Set in “timit_folder” the folder where you have stored the original (close-talking) TIMIT database
   - D. Set in “out_folder” the folder where the generated datasets will be created
   - F. Select in “mic_sel” the reference microphone for the generated databases (see Additional_info/Floorplan or Additional_info/microphone_info.txt for the complete list)

4) Run the KALDI recipe.
   
   - A. Go in the “Kaldi_recipe” folder
   - B. In you are using Kaldi-trunk version, go to "kaldi_trunk". If you have the current github kaldi version (tested on 28 March 2017) go to "kaldi_last"
   - C. Open the file path.sh and set the path of your kaldi installation in “export KALDI_ROOT=your_path”
   - D. Open the file “run.sh”
   - E. check parameters in run.sh and modify according to your machine:
        feats_nj=10 # number of jobs for feature extraction
        train_nj=30 # number of jobs for training
        decode_nj=6 # number of jobs for decoding (maximum 6)
   - F. Set directory of the contaminated timit dataset previously created by the MATLAB script in “timit”
   - G. Set directory of the DIRHA dataset in “dirha” (e.g., dirha=DIRHA_English_phrich/Data)
   - H. Set the desired test microphone in "test_mic" (e.g., test_mic="LA6", see Additional_info/Floorplan or Additional_info/Microphones for more information)
   - I. Run the script “./run.sh”
   - L. See the results by typing “./RESULTS”. Please note that the results may vary depending on: operating system, system architecture, version of kaldi


# Common issues:
- "awk:function gensub never defined”. The problem can be solved by typing the following command:  sudo apt-get install gawk
- make sure your ~/.bashrc contains the needed kaldi paths.
```
  PATH=$PATH:/home/kaldi-trunk/tools/openfst-1.3.4/bin
  PATH=$PATH:/home/kaldi-trunk/src/featbin
  PATH=$PATH:/home/kaldi-trunk/src/gmmbin
  PATH=$PATH:/home/kaldi-trunk/src/bin
  PATH=$PATH:/home/kaldi-trunk/src/nnetbin
  ```


# Cuda experiments
We recommend to use a CUDA-capable GPU for the DNN experiments. Before starting the experiments we suggest to do the following checks:

1. Make sure you have a cuda-capable GPU by typing “nvidia-smi”
2. Make sure you have installed the CUDA package (see nvidia website)
3. Make sure that in your .bashrc file you have the following lines :

       PATH=$PATH:$YOUR_CUDA_PATH/bin
       export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$YOUR_CUDA_PATH/lib64

4. Make sure you have installed kaldi with the cuda enabled (cd kaldi-trunk/src ; make clean; ./configure --cudatk-dir=$YOUR_CUDA_PATH; make depend ; make)
5. Test your GPU.  

    A. cd $YOUR_CUDA_PATH/samples/0_Simple/vectorAdd
    B. nvcc  vectorAdd.cu
    C. ./vectorAdd
    The result should be this: “Test PASSED”


# References:
If you use the DIRHA English wsj dataset or the related baselines and tools, please cite the following papers:

[1] M. Ravanelli, L. Cristoforetti, R. Gretter, M. Pellin, A. Sosi, M. Omologo, "The DIRHA-English corpus and related tasks for distant-speech recognition in domestic environments", in Proceedings of ASRU 2015.

[2] M. Ravanelli, P. Svaizer, M. Omologo, "Realistic Multi-Microphone Data Simulation for Distant Speech Recognition",in Proceedings of Interspeech 2016.

