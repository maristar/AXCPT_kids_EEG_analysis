function topoplots_maria2(name_component, timeinmsec, timeVec_msec, EEG, text_for_condition)
    %% Define time limits and ask for them FRN
    index=find_index_intime2(timeVec_msec, timeinmsec);
    fig1=figure; topoplot(EEG.data(:, index), EEG.chanlocs, 'maplimits', [-10 10]);
    % Remove the underscore characters 
    for jj=1:length(text_for_condition); 
        if ( text_for_condition(jj)=='_' || text_for_condition(jj)==' '); 
            text_for_condition(jj)='-';
        end; 
    end
    clear jj 
    
    title(['Grand-average ' name_component '-' text_for_condition]);
    xlabel('Time(ms)'); ylabel('Amplitude (uV)'); colorbar; 
    temp_save_name_fig=['GA_topoplot_' name_component '_' text_for_condition] ;
    saveas(fig1, temp_save_name_fig, 'tiff');
    saveas(fig1, temp_save_name_fig, 'fig');
    clear temp_save_name_fig
    %UNTITLED4 Summary of this function goes here
    %   Detailed explanation goes here


end

