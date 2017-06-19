% Analyzing EEG dataset for RVS - Base - Test data. 
% 30 November 2015, Maria L. Stavrinou at PSI, UiO
% 14 January 2016, MLS
% 18 February 2016 for AXCPT, Maria L. Stavrinou
% 18.4. for child axcpt 
% 04.04.2017 for chold axcpt and olga working on it. 
clear all 
close all

Raw_path='Z:\Prosjekt\Tune_Into_Kids_Session2\TIK\AXCPT_TIK\';
Analyzed_path='Z:\Prosjekt\Tune_Into_Kids_Session2\TIK\Analyzed_datasets\';
%'/Users/mstavrin/Documents/A_SettingEEG_lab/A_RECORDINGS/RAW_datasets/'; 

cd(Raw_path)
% Define list of folders 
%listing_raw=dir('AXCPT*_TIK*'); % Session 1
% For session 2 we write
listing_raw=dir('Axcpt*_tik_s2_*'); % Session 2
Num_folders=length(listing_raw);
for kk=1:Num_folders
    temp22{kk,:}=listing_raw(kk).name;
 
end
% test22=temp22(1,1)
clear kk listing_raw
%% 
for kk=38:Num_folders
    % Define on which subject we are working
    Subject_filename=temp22{kk,:}; 
    
    %Analyzed_path='/Users/mstavrin/Documents/A_SettingEEG_lab/A_RECORDINGS/Analyzed_datasets/AXCPT/';
    Analyzed_path_folder=[Analyzed_path Subject_filename '\'];
    Raw_path_folder=[Raw_path Subject_filename '\'];
 
    
    % Load the exported edat2 file (later named Tfinal).
    cd(Raw_path_folder)
    listing_raw2=dir('*matlab.txt');
    Edat2file=listing_raw2(1).name;
    FileName=Edat2file;
    
%     [FileName, Raw_Path] = uigetfile('*.*','Select the MATLAB T table (Tfinal) file "txt", or "mat" ');
%     cd(Raw_Path)
    T = readtable((FileName),...
    'Delimiter','\t','ReadVariableNames',false);
    clear Filename
    % Or load the Tfinal (if you are working with RVS_Subject101 -103



    % Define if there are delays in Stim Presentation (check StimOnsetDelay
    
    StimOnsetDelay=T(2:end, 74); % 122 was % >StimOne.OnsetDelay 74
    counter=0;
    for kk=1:size(StimOnsetDelay,1),
        if strcmp(StimOnsetDelay{kk,1},'0')==1 || strcmp(StimOnsetDelay{kk,1},'1')==1
        else
            counter=counter+1;
            indexes_StimOnsetDelay_toobig(counter)=kk;
        end
    end
    disp(['StimOnsetDelay: Found ' num2str(counter) ' delays bigger than 1']);

    %% Get some values from the T table from E-prime and do the ACC
    conditions={'AX','AY','BX','BY'};
    %%  Load the Condition for every stimulus AX; AY; BX; BY
    a=T(2:end, 43); %was 48

    %% TODO read the correct conditions only-
    %  Get the number that sets the correct answers only

       
% Commented on 04.04.2017 MLS    
%  if kk==1 % for JacLoe only
%        StimTwo_CRESP_tablenum=78; % 134
%        StimTwo_RESP_tablenum=83; % 147
%    else 
%        StimTwo_CRESP_tablenum=124; % 124
%        StimTwo_RESP_tablenum=137; % 137
%    end
   
%    StimTwo_CRESP=T(2:end, StimTwo_CRESP_tablenum);
%     %StimTwo_RESP=T(2:end, 147); For Jacob
%    StimTwo_RESP=T(2:end, StimTwo_RESP_tablenum);
   
%     %StimTwo_CRESP=T(2:end, 134); For Jacob
%     StimTwo_CRESP=T(2:end, 124);% Session 1
    StimTwo_CRESP=T(2:end, 78); % Session 2

%     %StimTwo_RESP=T(2:end, 147); For Jacob
%     StimTwo_RESP=T(2:end, 137); % Session 1
    StimTwo_RESP=T(2:end, 83); % Session 2
    
    Num_triggers=size(StimTwo_CRESP); 
    Num_triggers=Num_triggers(1);
    correct_index=zeros(Num_triggers,1);
    for kk=1:Num_triggers
        isequalX=strcmp(StimTwo_RESP{kk,1},StimTwo_CRESP{kk,1});
        if isequalX==1; 
            correct_index(kk,1)=kk;
        else
            correct_index(kk,1)=0;
        end
    end
    % 
    indexes_error=find(correct_index==0);
    indexes_correct=find(correct_index>0);

    cd(Analyzed_path_folder)
    mkdir('Triggers')
    cd Triggers
    %Noisy = dlmread('Noisy.rtf',' ',6,2);
    Noisy=[]; %NEW april 2017
    try 
        Noisy=load('Noisy.txt')
    end
    %% 
    for jj=1:length(conditions)
        temp_condition=conditions(jj);
        %temp_condition=cellstr(temp_condition);
        temp_condition_char=char(temp_condition);

        index=zeros(1, Num_triggers); % Should be 120 or less in our case
        for kk=1:Num_triggers, 
            if strcmp(a.Var43(kk,1),temp_condition)==1, 
                index(kk)=1; 
            end;
        end

        % index is an array of 1s and 0s. 1 means that in that position (index)
        % there is an 'AX' (for example).
        % Isolate the indexes that have the condition (AX) we want
        indexAX=find(index>0);

        % Set to zero the indexes that belong to AX condition but also belong
        % to Noisy    
        % Combine error responses and noisy triggers
         Noisy_error=[Noisy, indexes_error'];
         Noisy_error2=unique(Noisy_error);
%     
        for mm=1:length(indexAX),
            if ismember(indexAX(mm), Noisy_error2)==1,
                indexAX(mm)=0;
            end
        end

        % Remove the zeros (which are noisy epochs)
        indexfinal=find(indexAX>0);
        indexAXfinal=indexAX(indexfinal);

        % Make a txt file that would open for EEGLAB epoch selection.
        temp_filename=['triggers' temp_condition_char];
        create_triggers_in_txt(temp_filename, indexAXfinal);
        clear temp_condition_char temp_new_setname temp_condition temp_filename
    end

   
end

% Run 
temp_filenameAs=['triggersAs'];
temp_filenameBs=['triggersBs'];
for kk=38:Num_folders
    % Define on which subject we are working
    Subject_filename=temp22{kk,:}; 
    Analyzed_path_folder=[Analyzed_path Subject_filename '\'];
    cd(Analyzed_path_folder)
    cd('Triggers')
            % load AX
    AX=load('triggersAX.txt');
    AY=load('triggersAY.txt');
    % Unite triggers for cue : As and Bs        
    As=[AX AY];
    As=sort(As);
    % Make a txt file that would open for EEGLAB epoch selection.
    
    create_triggers_in_txt(temp_filenameAs, As);

    BX=load('triggersBX.txt');
    BY=load('triggersBY.txt');
    % Unite triggers for cue : As and Bs        
    Bs=[BX BY];
    Bs=sort(Bs);
    % Make a txt file that would open for EEGLAB epoch selection.
    
    create_triggers_in_txt(temp_filenameBs, Bs);

    clear AX AY As BX BY Bs
end
