%% To do the grandaverage of CHild experiment AXCPT
% 5 March 2016
% 12 April 2016 for real children
% 18.4.16 problem with legends and not working (v2) trying to solve in v3
% Ploting fixed 15.05.2017. Maria Stavrinou
clear all
close all

tic
%% Path information
Raw_Path='Y:\Prosjekt\Tune_Into_Kids_Session1\TIK\AXCPT_TIK\';
%'/Users/mstavrin/Documents/A_SettingEEG_lab/A_RECORDINGS/RAW_datasets/'; 
Analyzed_Path='Y:\Prosjekt\Tune_Into_Kids_Session1\TIK\Analyzed_datasets\';

cd(Analyzed_Path)
% Define list of Folders - Subjects  
Name_subject_folder='AXCPT*_TIK*';
listing_raw=dir(Name_subject_folder);
Num_folders=length(listing_raw);
for kk=1:Num_folders
    temp22{kk,:}=listing_raw(kk).name;
end
clear listing_raw

% Decide on which condition to work 
conditions_probe={'AX','AY','BX','BY'}; % CHANGE 03.05.2017
conditions_cue={'As', 'Bs'};

% SOS Define here for what condition you want.
% In the ploting function at the end of this program, one gives as input
% AXAYBXBY and the program gives out the As and Bs as well, so no need to
% select the condition_cue for the cue plotting. 

% Select ALWAYS probe
conditions=conditions_probe;
% change this to cue or probe as it goes to filenames and figures naming
text_condition='probe';

% load a dataset to get the dimensions - cue 
Analyzed_path_folder_1='Y:\Prosjekt\Tune_Into_Kids_Session1\TIK\Analyzed_datasets\AXCPT1_TIK_2016001001\';
cd(Analyzed_path_folder_1);
Name_to_load=['AXCPT1_TIK_2016001001_S1_newf_256_ICA_' text_condition '.set'];
EEG = pop_loadset('filename',Name_to_load,'filepath',Analyzed_path_folder_1);
EEG = eeg_checkset( EEG );
eeglab redraw

data=EEG.data;
[nchan ntimeGA ntrigs]=size(data); % probe 66 x 461 x 120 
clear data

% Initialize empty matrices to store the results. 
% For probe analysis
dataGA_AX=zeros(nchan, ntimeGA, ntrigs);
dataGA_AY=zeros(nchan, ntimeGA, ntrigs);
dataGA_BX=zeros(nchan, ntimeGA, ntrigs);
dataGA_BY=zeros(nchan, ntimeGA, ntrigs);

% For cue analysis 
dataGA_As=zeros(nchan, ntimeGA, ntrigs);
dataGA_Bs=zeros(nchan, ntimeGA, ntrigs);



bad_subject_list=[5, 8, 14, 15, 16, 17, 22, 24, 36, 37]; 

good_subj_list=[]; 

for kk=1:Num_folders, 
    if ~ismember(kk, bad_subject_list), 
        good_subj_list=[good_subj_list kk]; 
    end; 
end
clear kk 
%% Start load



startfolder=1;
for mkk=startfolder:length(good_subj_list) % For every subject - folder
     jjk=good_subj_list(mkk);
     Folder_name=temp22{jjk,:};

    Analyzed_path_folder=[Analyzed_Path temp22{jjk,:} '\'];
    Raw_path_folder=[Raw_Path temp22{jjk,:} '\'];

    for kk=1:length(conditions) % For every subject - condition 
        temp_condition=conditions(kk);
        temp_condition_char=char(temp_condition);

        % Go the Analyzed_path_folder for each subject
        % and search for the set files for each AX, AY condition
        cd(Analyzed_path_folder)
        Search_for_folder=[Name_subject_folder 'ICA_' text_condition 'triggers' temp_condition_char '.txt.set'];
        listing_sets=dir(Search_for_folder);
        Num_setfiles=length(listing_sets);
        temp_set=listing_sets.name;
        clear listing_sets

        % Find where the condition starts in the filename, and take the
        % first temp_set to look for it.
        B=strfind(temp_set, temp_condition_char); 

        if kk==1
            indexB=B(2);
        elseif kk>1
            indexB=B;
        end
        
        name1=temp_set(1:(indexB-1));%'Subject_103_25_512_ch_DC_epochs_tr2_autotriggers'; %AX.txt;
        name2=temp_condition_char;
        name3='.txt.set';
        name_file=[name1 name2 name3];
        name_data=[name1 name2];

        AreWeRight=strcmp(name_file, temp_set);
        if AreWeRight==1, 
            disp(['Working on file ' temp_set ' for condition ' temp_condition_char]);
            EEG = pop_loadset('filename',name_file,'filepath',Analyzed_path_folder);
            EEG = eeg_checkset( EEG );
            eeglab redraw
            data=EEG.data;
            nchan=size(data,1);
            if nchan>66
                data=data(1:66,:,:);
            end
            
                
%            TODOHERE  cat(1, arrayy1, array2)
            if strcmp(temp_condition, 'AX')==1 
                dataAX=data;
                data_temp=dataAX;
                dataGA_AX=cat(3, data_temp, dataGA_AX);
                clear data_temp dataAX
            elseif strcmp(temp_condition, 'AY')==1 
                  dataAY=data;
                  data_temp=dataAY;
                dataGA_AY=cat(3, data_temp, dataGA_AY);
                clear data_temp dataAY
            elseif strcmp(temp_condition, 'BX')==1
                  dataBX=data;
                  data_temp=dataBX;
                dataGA_BX=cat(3, data_temp, dataGA_BX);
                clear data_temp dataBX
            elseif strcmp(temp_condition, 'BY')==1 
                dataBY=data;
                data_temp=dataBY;
                dataGA_BY=cat(3, data_temp, dataGA_BY);
                clear data_temp dataBY
            end % condition
        end % if we are right
    end % condition
% Make timevector for plotting 
Fs=EEG.srate;
pre_trigger = EEG.xmin*1000; %msec  200 700
post_trigger = EEG.xmax*1000; %msec 1100 1600
data_pre_trigger = floor(pre_trigger*Fs/1000);
data_post_trigger = floor(post_trigger*Fs/1000);
timeVec = ((data_pre_trigger):(data_post_trigger));
timeVec = timeVec';
timeVec_msec = timeVec.*(1000/Fs);
end % every subject
clear mkk jjk
            
%For the GA
GA_EEGdata_AX=mean(dataGA_AX,3);
GA_EEGdata_AY=mean(dataGA_AY,3);
GA_EEGdata_BX=mean(dataGA_BX,3);
GA_EEGdata_BY=mean(dataGA_BY,3);

disp('Size of GA_EEGdata_AX')
disp(num2str(size(GA_EEGdata_AX)))

for jjj=1:length(conditions),
      temp_condition=conditions(jjj);
      temp_condition_char=char(temp_condition);
       switch temp_condition_char
           case 'AX'
               meanEEGdataAX=GA_EEGdata_AX;
               disp('AX here')
           case 'AY'
               meanEEGdataAY=GA_EEGdata_AY;
               disp('AY here')
           case 'BX'
           meanEEGdataBX=GA_EEGdata_BX;
           disp('BX here')
           case 'BY'
               meanEEGdataBY=GA_EEGdata_BY;
               disp('BY here')
       end
end

% Change the timeVector for the probe as it starts from 1500 ms.
if strcmp(text_condition,'probe')==1
    new_timeVec_msec=timeVec_msec-2000;
    timeVec_msec=new_timeVec_msec;
end

results.AX=meanEEGdataAX;
results.AY=meanEEGdataAY;
results.BX=meanEEGdataBX;
results.BY=meanEEGdataBY;
results.As=meanEEGdataAX+meanEEGdataAY;
results.Bs=meanEEGdataBX+meanEEGdataBY;
results.timeVec_msec=timeVec_msec;
results.Fs=Fs;

results.timeVec_msec=timeVec_msec;
results.Fs=Fs;

% Make a directory to save the results. 
cd(Analyzed_Path)
folder_results=(['Figures_results_' text_condition '_' date ])
mkdir(folder_results)
cd(folder_results)

chanlocs=EEG.chanlocs; 
results.chanlocs=chanlocs;

% New 19.05.2017
save results results 
% Decide on a channel number and plot
for jj=1:nchan
chan_number=jj;
    [ hb,hb2 ] = AXCPT_CHILD_make_plot(chan_number, text_condition, timeVec_msec, meanEEGdataAX, meanEEGdataAY, meanEEGdataBX, meanEEGdataBY, ALLEEG);
    
end

toc
%% SAVE the figures
% cd '/Users/mstavrin/Documents/A_SettingEEG_lab/A_RECORDINGS/Analyzed_datasets/AXCPT/'
% cd FiguresGA_TIK
% 
% for mm=2:8,
%     temp_save_name_fig=[names_chan{mm-1} '_TIK_GA'];
% saveas(mm, temp_save_name_fig, 'png')
% saveas(mm, temp_save_name_fig, 'fig')
% end 
% %             
% 



