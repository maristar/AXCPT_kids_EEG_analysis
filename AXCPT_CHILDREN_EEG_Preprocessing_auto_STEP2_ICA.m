% STEP 1 
% Makes the 4-5 preprocesing steps automatically.
% 29_2_2016 For the Children Version
% working on 06.03.2017
% Maria Stavrinou for PSI-UiO
%% Path information
% Raw_Path='/Users/mstavrin/Documents/A_SettingEEG_lab/A_RECORDINGS/RAW_datasets/AXCPT/CHILDREN_TIK/';
%'/Users/mstavrin/Documents/A_SettingEEG_lab/A_RECORDINGS/RAW_datasets/'; 
% Analyzed_path='/Users/mstavrin/Documents/A_SettingEEG_lab/A_RECORDINGS/Analyzed_datasets/AXCPT/CHILDREN_TIK/';
% '/Volumes/MY PASSPORT/EEG/RVS/Analyzed_datasets/'
%'/Users/mstavrin/Documents/A_SettingEEG_lab/A_RECORDINGS/Analyzed_datasets/';
% 

clear all
close all 

Raw_Path='Z:\Prosjekt\Tune_Into_Kids_Session1\TIK\AXCPT_TIK\';
Analyzed_path='Z:\Prosjekt\Tune_Into_Kids_Session1\TIK\Analyzed_datasets\';

%% Define list of folders 
cd(Raw_Path)
listing_raw=dir('AXCPT*_TIK*');
Num_folders=length(listing_raw);
for kk=1:Num_folders
    temp22{kk,:}=listing_raw(kk).name;
end
clear kk listing_raw
%% Instruction: The folder name should be the same and as defined above
 % Lets start the mega loop
for kk=36
    Folder_name=temp22{kk,:};
    Folder_name_char=char(Folder_name);
    cd(Analyzed_path)
    % mkdir(temp22{kk,:})
    
    Analyzed_path_folder=[Analyzed_path temp22{kk,:}];
    Raw_path_folder=[Raw_Path temp22{kk,:} '\'];
    cd(Analyzed_path_folder);
   
        
    % What the filename should be then
    Name_Subject_session=[Folder_name '_S1_newf_256'];
    
    % Search with 'dir' function the EEG recordings (for example
    % AXCPT1_TIK_2016001001_S1_newf_256.set)
    listing_set=dir('AXCPT*_TIK_*newf_256.set');
   
    Num_filesbdf=length(listing_set);
    if Num_filesbdf>1
        display('Warning, more data sets *.set found')
    elseif Num_filesbdf==0
        display('No EEG *.set file found')
    end
    
    % The set found by dir has a filename: *.set
    Name_found=listing_set.name;

    % Make a check
    if strcmp(Name_found(1:end-4), Name_Subject_session)==1
        % continue then
        
        % Load the set dataset 
        cd(Analyzed_path_folder)
        Name_to_load=[Name_Subject_session '.set'];
        eeglab;
        EEG = pop_loadset('filename',Name_to_load,'filepath',Analyzed_path_folder);
        EEG = eeg_checkset( EEG );
        eeglab redraw

        %% Remove the EOG electrodes
        EEG = pop_select( EEG,'nochannel',{'EXG3' 'EXG4'});
        EEG = eeg_checkset( EEG );
        eeglab redraw
               
        %% Apply ICA here
        EEG = pop_runica(EEG, 'extended',1,'interupt','on');
        [ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
        
        %% Add channels locations 
%        EEG.chanlocs=pop_chanedit(EEG.chanlocs, 'load',{'M:\pc\Dokumenter\MATLAB\eeglab_sml_v3\eeglab_sml_v3\plugins\dipfit2.3\standard_BESA\standard-10-5-cap66biosemi.elp', 'filetype', 'autodetect'});
%           EEG.chanlocs=pop_chanedit(EEG.chanlocs, 'load',{ '/matlab/eeglab/sample_data/eeglab_chan32.locs', 'filetype',  'autodetect'});
%       
% % read the channel location file and edit the channel location information ''
%           EEG = pop_saveset( EEG, 'savemode','resave');
%         EEG = eeg_checkset( EEG );
%         eeglab redraw  
        
        
        %% Save here
        EEG = pop_saveset( EEG, 'savemode','resave');
        EEG = eeg_checkset( EEG );
        eeglab redraw
        
        EEG.chanlocs(65).label='A1';
        EEG.chanlocs(66).label='A2';

        [ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
        eeglab redraw
        
    end % if strcmp is correct
end % For number of folders

