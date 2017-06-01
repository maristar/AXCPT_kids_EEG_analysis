clear all
close all 

% Olga do change this letter below to Z: % Me I have it as Y:
Raw_Path='Y:\Prosjekt\Tune_Into_Kids_Session1\TIK\AXCPT_TIK\';
Analyzed_path='Y:\Prosjekt\Tune_Into_Kids_Session1\TIK\Analyzed_datasets\';

%% Define list of folders 
cd(Raw_Path)
listing_raw=dir('AXCPT*_TIK*');
Num_folders=length(listing_raw);
for kk=1:Num_folders
    temp22{kk,:}=listing_raw(kk).name;
end
clear kk listing_raw

bad_subject_list=[5, 8, 14, 15, 16, 17, 22, 24, 36, 37]; % Session 1

good_subj_list=[]; 

for kk=1:Num_folders, 
    if ~ismember(kk, bad_subject_list), 
        good_subj_list=[good_subj_list kk]; 
    end; 
end
clear kk 

% Conditions

% conditions={'AX','AY','BX','BY'};

type={'cue', 'probe'};

%% Instruction: The folder name should be the same and as defined above
 % Lets start the mega loop
for mkk=1:length(good_subj_list)
    kk=good_subj_list(mkk);
    Folder_name=temp22{kk,:};
    cd(Analyzed_path)
    mkdir(temp22{kk,:})
    
    Analyzed_path_folder=[Analyzed_path temp22{kk,:}];
    %Raw_path_folder=[Raw_Path temp22{kk,:} '/'];
    cd(Analyzed_path_folder);
   
%     for jj=1:length(conditions) % AX AY etc
%         condition_temp=conditions{jj};
%         condition_temp_char=char(condition_temp);
        % What the filename should be then
%         cd(Analyzed_path_folder)
        Name_Subject_session=[Folder_name '_S1_newf_256_ICA.set'];
        
        eeglab;
        EEG = pop_loadset('filename',Name_Subject_session,'filepath',Analyzed_path_folder);
        EEG = eeg_checkset( EEG );
        eeglab redraw
        
        data=EEG.data;
        Fs=EEG.srate;
        timeVec=(-1:(1/Fs):(5-1/Fs));
        timeVec_msec=1000*timeVec;
        
        baseline_start=-500;
        baseline_start_indexes=find(timeVec_msec>baseline_start);
        baseline_start_index=min(baseline_start_indexes);
        
        baseline_end=0;
        baseline_end_indexes=find(timeVec_msec>0);
        baseline_end_index=min(baseline_end_indexes);
        
        cue_end=1950;
        cue_end_indexes=find(timeVec_msec>cue_end);
        cue_end_index=min(cue_end_indexes);
        
        
        [chan timeepoch numepochs]=size(data);
        
        % Remove baseline -500 to 0 from the big single trial -1 to 5 sec
        for ichan=1:chan
            for ie=1:numepochs
                single_trial=data(ichan, :, ie);
                new=single_trial-mean(single_trial(baseline_start_index:baseline_end_index));           
                data_new(ichan, :, ie)=new;
            end % for every single trial
            
        end % for every channel
        

        
        %eeglab redraw;
        %% Work for the probe:define limits and cut the single trials 
            probe_start=1500;
            probe_start_indexes=find(timeVec_msec>probe_start);
            probe_start_index=min(probe_start_indexes);
            
            probe_baseline_end=2000;
            probe_baseline_end_indexes=find(timeVec_msec>2000);
            probe_baseline_end_index=min(probe_baseline_end_indexes);
            
            probe_end=3300;
            probe_end_indexes=find(timeVec_msec>probe_end);
            probe_end_index=min(probe_end_indexes);
            
                    
        for ichan=1:chan
            for ie=1:numepochs
                single_trial=data(ichan, :, ie);
                new=single_trial-mean(single_trial(probe_start_index:probe_baseline_end_index));
                
                data_new_probe(ichan, :, ie)=new;
            end % for every single trial
            
        end % for every channel
            
  %% Cut and save for the cue:   from -500 to 1500 msec for the cue % Here 19.05.2017
            % HERE
        for bb=1%:length(type)
            type_temp=type{bb};
            type_temp_char=char(type_temp);
            datacue=data_new(:, baseline_start_index:cue_end_index, :);
            EEG.data=datacue;
            EEG.xmin=baseline_start/1000;
            EEG.xmax=cue_end/1000;
           EEG.trials=length(EEG.epoch);
           temp_setname= [Name_Subject_session(1:end-4) '_' type_temp_char];
           [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, CURRENTSET, 'setname', temp_setname, 'overwrite', 'off');
           EEG.trials=length(EEG.epoch);
           EEG = eeg_checkset( EEG );
           eeglab redraw
            
           Name_to_save = [Name_Subject_session(1:end-4) '_' type_temp_char]

           EEG = pop_saveset( EEG, 'filename',Name_to_save,'filepath',Analyzed_path_folder);
           EEG = eeg_checkset( EEG );
             % EEG = pop_rmbase( EEG, [-1000 0]); % Remove baseline
            % Add a description of the epoch extraction to EEG.comments.
            
            % see 
            
%             part_name_to_save=part_names{tt};
% 
%                     temp_setname=[EEG.filename(1:end-4) '_' temp23{kkj}(1:end-4) '_' part_name_to_save];
% 
%                     EEG.setname=temp_setname; %'RVS_Subject105_Base_512_ch_DC_epochs_tr2_auto_double_tr_2_corr';
% 
%                     EEG = eeg_checkset( EEG );
% 
%                     eeglab redraw
% 
% 
% 
% 
%                     % Saving the dataset
% 
%                     Name_to_save=[temp_setname '.set'];
% 
%                     EEG = pop_saveset( EEG, 'filename',Name_to_save,'filepath',Analyzed_path_folder);
% 
%                     EEG = eeg_checkset( EEG );
% 
%                     eeglab redraw
%             % end see
%             
            
            
%             [ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);  %Modify the dataset in the EEGLAB main window
            eeglab redraw % Update the EEGLAB window to view changes  
        end % for bb
 
        %% Cut and save for the probe
         for bb=2%:length(type)% probe
            type_temp=type{bb};
            type_temp_char=char(type_temp);
            dataprobe=data_new_probe(:, probe_start_index:probe_end_index, :);
            EEG.data=dataprobe;
            EEG.xmin=probe_start/1000;
            EEG.xmax=probe_end/1000;
            EEG.trials=length(EEG.epoch);
            temp_setname= [Name_Subject_session(1:end-4) '_' type_temp_char];
            [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, CURRENTSET, 'setname', temp_setname, 'overwrite', 'off');
            EEG.trials=length(EEG.epoch);
            EEG = eeg_checkset( EEG );
            eeglab redraw
            % EEG = pop_rmbase( EEG, [-1000 0]); % Remove baseline
            % Add a description of the epoch extraction to EEG.comments.
            Name_to_save = [Name_Subject_session(1:end-4) '_' type_temp_char]

           EEG = pop_saveset( EEG, 'filename',Name_to_save,'filepath',Analyzed_path_folder);
           EEG = eeg_checkset( EEG );
             
        end % for bb
        
    end % conditions
 % for every subject
        
         
        
                
                
            