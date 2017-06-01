% Program to detect the peak and their mean values for AXCPT kids,
% Maria Stavrinou,2017

clear all 
close all
tic

% Make a structure to save all info on dataset and analysis
data_Properties.scope='analysis of AXCPT kids cue'
data_Properties.date=date;

%% Define new directories to save data and figures
Raw_path='Y:\Prosjekt\Tune_Into_Kids_Session1\TIK\AXCPT_TIK\';
Analyzed_path='Y:\Prosjekt\Tune_Into_Kids_Session1\TIK\Analyzed_datasets\';

% Define the 4 conditions,in alphabetical order so that the listing is in 
% same order as when matlab uses 'dir' function. Define the names of the 4
% parts. 
% Decide on which condition to work 
conditions_probe={'AX','AY','BX','BY'}; % CHANGE 03.05.2017
conditions_cue={'As', 'Bs'};

% Define here for what condition you want
conditions=conditions_cue;
condition_type='cue';
% Conditions short exists in the previous version and it is used for the graphs. 
conditions_short=conditions; 

% Directory for data
folder_data_save=['Results_AXCPT_mean_detection_forCNV' condition_type date];
cd(Analyzed_path)
mkdir(folder_data_save)

% Directory for data
folder_figures_save=folder_data_save; % the same directory
cd(Analyzed_path)
mkdir(folder_figures_save)

% For analysis with one part only 
part_names_all={};

%% Define which subjects to keep in the analysis 
bad_subject_list=[5, 8, 14, 15, 16, 17, 22, 24, 36, 37]; 

%% Define channels of interest
numchans=1:64;

%% Define list of Folders - Subjects  
Name_subject_folder='AXCPT*_TIK*';
listing_raw=dir(Name_subject_folder);
Num_folders=length(listing_raw);
for kk=1:Num_folders
    temp22{kk,:}=listing_raw(kk).name;
end
clear listing_raw Name_subject_folder kk


%% Save in the structure
data_Properties.conditions=conditions;
data_Properties.condition_type=condition_type;
data_Properties.conditions_probe=conditions_probe;
data_Properties.conditions_cue=conditions_cue;
data_Properties.Raw_path=Raw_path;
data_Properties.Analyzed_path=Analyzed_path;

% Save in the structure
data_Properties.folder_data_save=folder_data_save;
data_Properties.folder_figures_save=folder_figures_save;
data_Properties.conditions_short=conditions_short;
data_Properties.part_names_all=part_names_all;
data_Properties.numchans=numchans;

%% Save in the structure
data_Properties.temp22=temp22;

%% Define the header for the excel file
% General header based on conditions - it works now! magic maria 
header_raw_exp=['Subject_Num_'];
for kk=1:length(conditions)
    temp_condition=conditions_short(kk);
    temp_condition_char=char(temp_condition);
    if length(part_names_all)==0
        header_raw_exp=[header_raw_exp  temp_condition ]
    elseif length(part_names_all)>0
        for jj=1:length(part_names_all)
            temp_parts=part_names_all(jj);
            temp_parts_char=char(temp_parts);
            middle_temp_name=cellstr([temp_condition_char '_' temp_parts_char]);
            header_raw_exp=[header_raw_exp middle_temp_name ]
        end
    end
end
clear kk jj

% Save in the structure
data_Properties.header_raw=header_raw_exp; 

%% Extract the good subject list then
good_subj_list=[]; 
for kk=1:Num_folders,
    if ~ismember(kk, bad_subject_list), 
        good_subj_list=[good_subj_list kk]; 
    end; 
end
clear kk

data_Properties.bad_subject_list=bad_subject_list;
data_Properties.good_subj_list=good_subj_list;


%% Start!
startfolder=1;
for mkk=startfolder:length(good_subj_list)
    jjk=good_subj_list(mkk);
    Folder_name=temp22{jjk,:};
    % Print a message on screen to show on which subject we are working
    fprintf(' ***  Working on subject %s: %s\n', num2str(mkk), Folder_name)
        Analyzed_path_folder=[Analyzed_path Folder_name '\' ];
        Raw_path_folder=[Raw_path Folder_name '\' ];
        % 
        for kk=1:length(conditions) % For every condition
            temp_condition=conditions(kk);
            temp_condition_char=char(temp_condition);
            Subject_filename_condition=[Folder_name '_' temp_condition_char]; % AXCPT1_TIK_2016001001_AX
            %% HERE 
            clear temp_sets
            % Go the Analyzed_path_folder for each subject
            % and search for the set files for each AX, AY condition
            cd(Analyzed_path_folder)
            type_files_identifier='AXCPT*_TIK_*_S1_newf_256_ICA_'; 
            
            % Type files identifier for
            % a) FRN '*_256__Luck_triggers_'
            % b) Stim '*_256__Luck_stim_'
            % c) Stim and ICA '*_256__Luck_stim_ICA_'
            % d) EOG -pupil analysis '*_256__Luck_stim_unfilt_EOG_triggers_*'
            Search_for_folder=[type_files_identifier condition_type 'triggers' temp_condition_char '.txt.set'];
            listing_sets=dir(Search_for_folder);
            Num_setfiles=length(listing_sets);
            temp_set=listing_sets.name;
            clear listing_sets


             if length(part_names_all)==0
                 part_name_temp_char=[];
             end
            
            % Find where the condition starts in the filename, and take the
            % first temp_set to look for it.
            B=strfind(temp_set, temp_condition_char); 

            if (kk==1 && strcmp(condition_type, 'probe')==1);
                indexB=B(2);
            else
                indexB=B;
            end
       
            name1=temp_set(1:(indexB-1));%'Subject_103_25_512_ch_DC_epochs_tr2_autotriggers'; %AX.txt;
            name2=temp_condition_char;
            name3='.txt.set';
            name_file=[name1 name2 name3];
            name_data=[name1 name2];

            AreWeRight=strcmp(name_file, temp_set);
            
            % Checking if we are working on the correct condition:
            if AreWeRight==1, 
                disp(['Working on file ' temp_set ' for condition ' temp_condition_char]);
                EEG = pop_loadset('filename',name_file,'filepath',Analyzed_path_folder);
                EEG = eeg_checkset( EEG );
                eeglab redraw
                
                % Extract data
                data=EEG.data;
                nchan=size(data,1);
                
                % Get rid of the extra channels if any
                if nchan>66
                    data=data(1:66,:,:);
                end
                
               % Average with the number of trials. 
                meandata=mean(data, 3);

                % Give a name to the part_name_temp_char
                if isempty(part_name_temp_char)
                    disp('Doing for non parts')
                    part_name_temp_char='allparts'
                end

                % Save the results
                Mean_Subjects.(Folder_name).(temp_condition_char).(part_name_temp_char)=meandata;
                clear data
            end % For "if we are right"
        end   % For conditions
    end % For Subjects 

% Save the channels names
chanlocs=EEG.chanlocs(numchans); 
data_Properties.chanlocs=chanlocs;

% Save the limits of the epochs
% Define the limits, because you could change them in older
% versions
new_pre_trigger=EEG.xmin*1000;%
new_post_trigger=EEG.xmax*1000;%

data_Properties.new_pre_trigger=new_pre_trigger;
data_Properties.new_post_trigger=new_post_trigger;

% Make and save the timeVector
Fs=EEG.srate;
pre_trigger = EEG.xmin*1000; %msec  EEGLAB has the minus infront, 12.09.2016
post_trigger = EEG.xmax*1000; %msec 
data_pre_trigger = floor(pre_trigger*Fs/1000);
data_post_trigger = floor(post_trigger*Fs/1000);
timeVec = ((data_pre_trigger):(data_post_trigger));
timeVec = timeVec';
timeVec_msec = timeVec.*(1000/Fs);  
% This timeVec_msec for the probe is from 1500 to 3.296e+03. To 
% make it from time zero, condition_type='probe';
if strcmp(condition_type,'probe')==1
    timeVec_msec2=timeVec_msec-2000;
    timeVec_msec=timeVec_msec2;
end
clear timeVec_msec2
%% Save the Mean_All_Subjects 
cd(Analyzed_path)
cd(folder_data_save)
save Mean_Subjects Mean_Subjects 
% What else I need 
data_Properties.Analyzed_path=Analyzed_path;
data_Properties.timeVec_msec=timeVec_msec;
data_Properties.Fs=Fs;
data_Properties.new_pre_trigger=new_pre_trigger;
data_Properties.new_post_trigger=new_post_trigger;
save data_Properties data_Properties

% %Check if we need any of this
% clear jjk mm kk gg B AreWeRight ...
%     data_post_trigger ...
%     data_pre_trigger ...
%     name1 name2 name3a name3b ...
%     name_data ...
%     name_file ...
%     Name_subject_folder ...
%     part_names ...
%     part_name_temp_char ...
%     part_name_temp ...
%     post_trigger ...
%     pre_trigger ...
%     temp_condition ...
%     temp_condition_char

% %% Define time limits for the peak detection 
% name_component='N1';
% type='mean';
% peak_start_time=80;
% peak_end_time=160;
% time_start=new_pre_trigger; %was -200 % MLS 08.09.2+16 changed % In msec -there is abs(time_start) in the function so the minus is disgarted
% time_end=new_post_trigger; %600; % TODO sth here why it is deleted 
% 
% % For general peak intervals
% [ Peak_results, Tnew] = peak_detection_all( name_component, type, peak_start_time, peak_end_time, time_start, time_end, Mean_Subjects, data_Properties )
% clear Peak_results Tnew
% 
% %% Define time limits for the peak detection 
% name_component='P2';
% type='mean';
% peak_start_time=150;
% peak_end_time=250;
% time_start=new_pre_trigger; %was -200 % MLS 08.09.2+16 changed % In msec -there is abs(time_start) in the function so the minus is disgarted
% time_end=new_post_trigger; %600; % TODO sth here why it is deleted 
% 
% %% For general peak intervals
% [ Peak_results, Tnew] = peak_detection_all( name_component, type, peak_start_time, peak_end_time, time_start, time_end, Mean_Subjects, data_Properties )
% 
% clear Peak_results Tnew
% 
% %% Define time limits for the peak detection 
% name_component='N2'; 
% type='mean';
% peak_start_time=250;
% peak_end_time=400;
% time_start=new_pre_trigger; %was -200 % MLS 08.09.2+16 changed % In msec -there is abs(time_start) in the function so the minus is disgarted
% time_end=new_post_trigger; %600; % TODO sth here why it is deleted 
% 
% %% For general peak intervals
% [ Peak_results, Tnew] = peak_detection_all( name_component, type, peak_start_time, peak_end_time, time_start, time_end, Mean_Subjects, data_Properties )
% 
% clear Peak_results Tnew
% 
% %% Late positivity 
% name_component='LatPos';
% type='mean';
% peak_start_time=500;
% peak_end_time=1300
% time_start=new_pre_trigger; %was -200 % MLS 08.09.2+16 changed % In msec -there is abs(time_start) in the function so the minus is disgarted
% time_end=new_post_trigger;
% % In msec 
% 
% [ Peak_results, Tnew] = peak_detection_all( name_component, type, peak_start_time, peak_end_time, time_start, time_end, Mean_Subjects, data_Properties )
% clear Peak_results Tnew
% 
% %% Late positivity every 100 msec
% name_component='LatPos1';
% type='mean';
% peak_start_time=500;
% peak_end_time=600
% time_start=new_pre_trigger; %was -200 % MLS 08.09.2+16 changed % In msec -there is abs(time_start) in the function so the minus is disgarted
% time_end=new_post_trigger;
% % In msec 
% 
% [ Peak_results, Tnew] = peak_detection_all( name_component, type, peak_start_time, peak_end_time, time_start, time_end, Mean_Subjects, data_Properties )
% clear Peak_results Tnew
% 
% %% Late positivity every 100 msec
% name_component='LatPos2';
% type='mean';
% peak_start_time=600;
% peak_end_time=700
% time_start=new_pre_trigger; %was -200 % MLS 08.09.2+16 changed % In msec -there is abs(time_start) in the function so the minus is disgarted
% time_end=new_post_trigger;
% % In msec 
% 
% [ Peak_results, Tnew] = peak_detection_all( name_component, type, peak_start_time, peak_end_time, time_start, time_end, Mean_Subjects, data_Properties )
% clear Peak_results Tnew
% 
% %% Late positivity every 100 msec
% name_component='LatPos3';
% type='mean';
% peak_start_time=700;
% peak_end_time=800
% time_start=new_pre_trigger; %was -200 % MLS 08.09.2+16 changed % In msec -there is abs(time_start) in the function so the minus is disgarted
% time_end=new_post_trigger;
% % In msec 
% 
% [ Peak_results, Tnew] = peak_detection_all( name_component, type, peak_start_time, peak_end_time, time_start, time_end, Mean_Subjects, data_Properties )
% clear Peak_results Tnew
% 
% %% Late positivity every 100 msec
% name_component='LatPos4';
% type='mean';
% peak_start_time=800;
% peak_end_time=900
% time_start=new_pre_trigger; %was -200 % MLS 08.09.2+16 changed % In msec -there is abs(time_start) in the function so the minus is disgarted
% time_end=new_post_trigger;
% % In msec 
% 
% [ Peak_results, Tnew] = peak_detection_all( name_component, type, peak_start_time, peak_end_time, time_start, time_end, Mean_Subjects, data_Properties )
% clear Peak_results Tnew
% 
% %% Late positivity every 100 msec
% name_component='LatPos5';
% type='mean';
% peak_start_time=900;
% peak_end_time=1000
% time_start=new_pre_trigger; %was -200 % MLS 08.09.2+16 changed % In msec -there is abs(time_start) in the function so the minus is disgarted
% time_end=new_post_trigger;
% % In msec 
% 
% [ Peak_results, Tnew] = peak_detection_all( name_component, type, peak_start_time, peak_end_time, time_start, time_end, Mean_Subjects, data_Properties )
% clear Peak_results Tnew
% 
% 
% %% Late positivity every 100 msec
% name_component='LatPos6';
% type='mean';
% peak_start_time=1000;
% peak_end_time=1100
% time_start=new_pre_trigger; %was -200 % MLS 08.09.2+16 changed % In msec -there is abs(time_start) in the function so the minus is disgarted
% time_end=new_post_trigger;
% % In msec 
% 
% [ Peak_results, Tnew] = peak_detection_all( name_component, type, peak_start_time, peak_end_time, time_start, time_end, Mean_Subjects, data_Properties )
% clear Peak_results Tnew
% 
% %%
% name_component='LatPos7';
% type='mean';
% peak_start_time=1100;
% peak_end_time=1200
% time_start=new_pre_trigger; %was -200 % MLS 08.09.2+16 changed % In msec -there is abs(time_start) in the function so the minus is disgarted
% time_end=new_post_trigger;
% % In msec 
% 
% [ Peak_results, Tnew] = peak_detection_all( name_component, type, peak_start_time, peak_end_time, time_start, time_end, Mean_Subjects, data_Properties )
% clear Peak_results Tnew

% %%
% name_component='LatPos8';% CNV
% type='mean';
% peak_start_time=1200;
% peak_end_time=1300
% time_start=new_pre_trigger; %was -200 % MLS 08.09.2+16 changed % In msec -there is abs(time_start) in the function so the minus is disgarted
% time_end=new_post_trigger;
% % In msec 
% 
% [ Peak_results, Tnew] = peak_detection_all( name_component, type, peak_start_time, peak_end_time, time_start, time_end, Mean_Subjects, data_Properties )
% clear Peak_results Tnew

%% 
%% If we run extra analyses we need to re-load the data_Properties, and Mean_Subjects from the folder
% Results_AXCPT_mean_detection_cue/probe_(date)
new_pre_trigger=data_Properties.new_pre_trigger;
new_post_trigger=data_Properties.new_post_trigger;

name_component='CNV';
type='mean';
peak_start_time=1800;
peak_end_time=1900;
time_start=new_pre_trigger; %was -200 % MLS 08.09.2+16 changed % In msec -there is abs(time_start) in the function so the minus is disgarted
time_end=new_post_trigger;
% In msec 

[ Peak_results, Tnew] = peak_detection_all( name_component, type, peak_start_time, peak_end_time, time_start, time_end, Mean_Subjects, data_Properties )
clear Peak_results Tnew


%% Save data properties
cd(Analyzed_path)
cd(folder_data_save)
save data_Properties data_Properties
save Mean_Subjects Mean_Subjects