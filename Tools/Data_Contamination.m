%%%%%%%%%%%%%%%%%%%%%%
% Author: Mirco Ravanelli (mravanelli@fbk.eu)
%
% NOV 2015
%
% Description:
% The script "Data_Contamination" starts from the standard close-talk version of timit and contaminates it with noise and reverberation.
% It normalizes the amplitude of each signal and performs a conversion of the xml label into a phn label. 
% After runnung the script, the training and test databases (to be used in the kaldi recipe) are available in the specified output folder.
%
%%%%%%%%%%%%%%%%%%%%%%


clear
clc
close all

warning off


% Parameters to set
%-----------------------------------------------------------------------

% Paths of the original datasets
timit_folder='/path/to/TIMIT'; % Path of the original close-talk TIMIT dataset

% output paths/names
out_folder='../Data'; % Path where both the contaminated traning dataset

timit_name='TIMIT_revnoise_mic';  %name of the output contaminated TIMIT folder


% Selected microphone
mic_sel='LA6'; % Select here one of the available microphone (e.g., LA6, L1R, LD07, Beam_Circular_Array,Beam_Linear_Array, etc. => Please, see Floorplan)

% Noise folder for TIMIT contamination (Default is: ../TIMIT_noise_sequences)
noise_folder='../Data/TIMIT_noise_sequences';

% Impulse responses for TIMIT contamination (Default is ../Training_IRs/*)
IR_folder{1}='../Data/Training_IRs/T1_O6';
IR_folder{2}='../Data/Training_IRs/T2_O5';
IR_folder{3}='../Data/Training_IRs/T3_O3';

%-----------------------------------------------------------------------


% Creation of the output folder
mkdir(out_folder); 
mkdir(strcat(out_folder,'/',timit_name,'_',mic_sel));




%%%%  TRAINING DATA %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fprintf('-----------------------------\n');
fprintf('Contamination of the TIMIT database using mic %s:\n',mic_sel);

add_samples=2500; % samples to append at the end to accout for the reverberation tail
Norm_factor=80000; % normalization factor

% Generation of a TIMIT folder with the same structure of the original TIMIT folder
fprintf('Folders creation...\n');
create_folder_str(timit_folder,strcat(out_folder,'/',timit_name,'_',mic_sel));

% list of all the original TIMIT files
list=find_files(timit_folder,'.wav');

count=0;

for i=1:length(list)
    
 count=count+1;
 
 % loading the training impulse responses
 IR_file=strcat(IR_folder{count},'/',mic_sel);
 load(IR_file);

 % Reading the original TIMIT signal
 signal=audioread(list{i});
 
 % Add samples to account for the reverberation tail
 signal=[signal; zeros(1,add_samples)'];
 
 % 16-48 kHz conversion (IRs were measured at 48 kHz)
 signal=resample(signal,3,1);
 signal=signal./max(abs(signal));


 % Convolution
 signal_rev=fftfilt(risp_imp,signal);
 signal_rev=signal_rev/Norm_factor;
 
 % Compensation for the delay due to time of Flight (ToF)
 [v, p]=max(risp_imp);
 signal_rev=linear_shift(signal_rev',-p);

 % Reading noise file
 noise_file=strrep(list{i},timit_folder,noise_folder);
 sig_noise=audioread(noise_file);

 % Adding the noise
 signal_rev_noise=signal_rev+sig_noise';

 % 48-16 kHz conversion
 signal_rev_noise=resample(signal_rev_noise,1,3);
 signal_rev_noise=signal_rev_noise./max(abs(signal_rev_noise));

 % saving the output wavfile
 name_wav=strrep(list{i},timit_folder,strcat(out_folder,'/',timit_name,'_',mic_sel));
 
 audiowrite(name_wav,0.95.*signal_rev_noise,16000)

 % Processing the .phn labels
 phn_or=strrep(list{i},'.wav','.phn');
 fid = fopen(phn_or);
 
 % saving the .phn labels
 clear beg_sample_s
 clear end_sample_s
 clear snt
 
 count_s=0;
 
 tline = fgetl(fid);
  while ischar(tline)
    count_s=count_s+1;
    trova=strfind(tline,' ');
    beg_sample_s(count_s)=str2double(tline(1:trova(1)-1));
    end_sample_s(count_s)=str2double(tline(trova(1)+1:trova(2)-1));
    snt{count_s}=tline(trova(2)+1:end);

    tline = fgetl(fid);
  end
  
  fclose(fid);
  
  % processing of the phn label: updating label according to
  % the samples added at the end of the signal for accouting of the reverberation tail.
  end_sample_s(end)=length(signal_rev);
  
  
  % saving the processed phn label
  name_phn=strrep(name_wav,'.wav','.phn');
  fid_w=fopen(name_phn,'w');
  
  for k=1:length(snt)
  fprintf(fid_w,'%i %i %s\n',beg_sample_s(k),end_sample_s(k),snt{k});
  end
  
  fclose(fid_w);
  fprintf('done %i/%i %s\n',i,length(list),name_wav);
  
  % change impulse response
  if count==length(IR_folder)
  count=0;
  end
  
  
 
end




