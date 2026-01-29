function Process_EMG(EMG_data,framerate,path,name)

    order = 4; % 2nd order for each pass so 4th order
    cutoff_band = [20 400];
    cutoff_low = 10;

    
 
    % Express in mV (*1000)
        EMG_raw = zeros(size(EMG_data));        
        for n = 1:size(EMG_data,1)
            EMG_raw(n,:) = table2array(EMG_data(n,:)).*1000;
        end        

        % Apply filtering
        % Band pass filter
        [a,b] = ...
            butter(order/2,cutoff_band./(0.5*framerate),'bandpass');
        EMG_band = filtfilt(a,b,EMG_raw);
        clear a b

        % Rectification
        EMG_rect = abs(EMG_band);

        % Low pass filter
        [a,b] = butter(order/2,cutoff_low./(0.5*framerate),'low');
        EMG_low = filtfilt(a,b,EMG_rect);
        
        % Create time interval
        time = (0:1:size(EMG_low,1)-1)./framerate;
        
        % EMG to write
        output_raw = [time', EMG_raw]; 
        output_filtered = [time', EMG_low];
         
        % Define output path and name        
        path_out_raw = fullfile(path, 'EMG',[name,'_EMG_raw.mot']);
        path_out_filt = fullfile(path,'EMG',[name,'_EMG_filt.mot']);

        % Write to mot-file
        colheaders = [{'Time'} ,EMG_data.Properties.VariableNames];
        generateMotFile(output_raw,colheaders,path_out_raw);
        generateMotFile(output_filtered,colheaders, path_out_filt);


        % figure filtered
        figure
        tiledlayout(4,4)
        for n = 2:size(output_filtered,2)
            nexttile
            plot(output_filtered(:,n))
            title(colheaders{n})
        end 
        set(gcf,'Position',[100 100 800 800])
        fig_path_out_filt = fullfile(path, 'EMG',[name,'_EMG_filt.jpg']);
        exportgraphics(gcf,fig_path_out_filt)
        movegui(gcf,'center')

        % figure raw
        figure
        tiledlayout(4,4)
        for n = 2:size(output_raw,2)
            nexttile
            plot(output_raw(:,n))
            title(colheaders{n})
        end 
        set(gcf,'Position',[100 100 800 800])
        fig_path_out_raw = fullfile(path, 'EMG',[name,'_EMG_raw.jpg']);
        exportgraphics(gcf,fig_path_out_raw)
        movegui(gcf,'center')

        % figure frequency spectrum
        figure
        tiledlayout(4,4)
        for n = 2:size(output_raw,2)
            nexttile
            data_ft=fft(output_raw(:,n));
            sze = length(output_raw(:,n));
            ff= fix(sze/2) + 1;
            f = [0:ff-1]*framerate/sze;
            plot(f(2:ff), abs(data_ft(2:ff)/sze*2),'b'); 
            axis tight;
            title(colheaders{n})
        end
        set(gcf,'Position',[100 100 800 800]);
        han = axes(gcf,'visible','off'); 
        han.XLabel.Visible='on';
        han.YLabel.Visible='on';
        ylabel(han,'Magnitude',FontSize=14,FontWeight='bold');
        xlabel(han,'Frequency (Hz)',FontSize=14,FontWeight='bold');
        sgtitle('Frequency spectrum (raw)');
        fig_path_out_raw = fullfile(path, 'EMG',[name,'_EMG_raw_freq.jpg']);
        exportgraphics(gcf,fig_path_out_raw)
        movegui(gcf,'center')

        % figure frequency spectrum bandpass
        figure
        tiledlayout(4,4)
        for n = 2:size(EMG_band,2)
            nexttile
            data_ft=fft(EMG_band(:,n));
            sze = length(EMG_band(:,n));
            ff= fix(sze/2) + 1;
            f = [0:ff-1]*framerate/sze;
            plot(f(2:ff), abs(data_ft(2:ff)/sze*2),'b'); 
            axis tight;
            title(colheaders{n})
        end
        set(gcf,'Position',[100 100 800 800]);
        han = axes(gcf,'visible','off'); 
        han.XLabel.Visible='on';
        han.YLabel.Visible='on';
        ylabel(han,'Magnitude',FontSize=14,FontWeight='bold');
        xlabel(han,'Frequency (Hz)',FontSize=14,FontWeight='bold');
        sgtitle('Frequency spectrum (bandpassed)');
        fig_path_out_raw = fullfile(path, 'EMG',[name,'_EMG_band_freq.jpg']);
        exportgraphics(gcf,fig_path_out_raw)
        movegui(gcf,'center')

        % figure frequency spectrum filtered
        figure
        tiledlayout(4,4)
        for n = 2:size(output_filtered,2)
            nexttile
            data_ft=fft(output_filtered(:,n));
            sze = length(output_filtered(:,n));
            ff= fix(sze/2) + 1;
            f = [0:ff-1]*framerate/sze;
            plot(f(2:ff), abs(data_ft(2:ff)/sze*2),'b'); 
            axis tight;
            title(colheaders{n})
        end
        set(gcf,'Position',[100 100 800 800]);
        han = axes(gcf,'visible','off'); 
        han.XLabel.Visible='on';
        han.YLabel.Visible='on';
        ylabel(han,'Magnitude',FontSize=14,FontWeight='bold');
        xlabel(han,'Frequency (Hz)',FontSize=14,FontWeight='bold');
        sgtitle('Frequency spectrum (filtered)');
        fig_path_out_raw = fullfile(path, 'EMG',[name,'_EMG_filt_freq.jpg']);
        exportgraphics(gcf,fig_path_out_raw)
        movegui(gcf,'center')

end