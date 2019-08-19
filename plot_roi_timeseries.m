%
% Purpose:
%
% Input     
%           
% Effects:
%
% Usage examples
%
%
% (c) 2018 Paul Moore - moorep@maths.ox.ac.uk 
%
% This software is provided 'as is' with no warranty or other guarantee of
% fitness for the user's purpose.  Please let the author know of any bugs
% or potential improvements.

function plot_roi_timeseries()

    addpath('../../shared/code/common');
    addpath('../../shared/code/util');

    tic;
    
    close all;        
           
     % choose data tag 
    datatag = 'brain702xt';                  
    load(['./data/tpdata_' datatag],'tpdata');   
    
    % time matched sets for paper
    load('./data/training_set','sadrids','snlrids','smcirids');           
 
    fnstem =  '../docs/time_series_plots/figures/healthy';
    plot_features(snlrids,tpdata,fnstem,true,22); 

    fnstem =  '../docs/time_series_plots/figures/unhealthy';
    plot_features(sadrids,tpdata,fnstem,true,22); 

    fnstem =  '../docs/time_series_plots/figures/mci';
    plot_features(smcirids,tpdata,fnstem,true,22); 
        
    toc;
    
end


% function
function plot_features(rids,tpd,fnstem,fsel,sample_size)    
    
    c1 = [0 0.6 1]; % blue - whole brain
    c2 = [0.8 0.2 0 ]; % red - hippo
    c3 = [1 0.8 0.2 ]; % yellow - vents
    c4 = [0.2 0.8 0.2 ]; % green - ento
    c5 = [0.8 0.2 0.8 ]; % purple - fusi
    c6 = [0.2 0.2 0.2 ]; % grey - midtemp
    
    
    rng(38)
    ridsample = randsample(rids,length(rids));
%    ridsample = rids;

    
    i = 1;
    k = 1;
    while i<=length(ridsample) && k<=sample_size
        
        rid = ridsample(i);
        ridsat = tpd(tpd(:,1)==rid,:);
        ridsat = sortrows(ridsat,4);
        
        % check number of useful points
        ts_dx = ridsat(:,5);        
        npoints = length(find(~isnan(ts_dx) & ts_dx~=0));
      
        if npoints > 4 || fsel
            
            ts_wholebrain = ridsat(:,23);
            ts_hippo = ridsat(:,22);
            ts_vents = ridsat(:,34);
            ts_ento = ridsat(:,24);
            ts_fusi = ridsat(:,25);
            ts_midtemp = ridsat(:,58);
            ts_var = ridsat(:,26);            

            vcs = ridsat(:,4);
            x_wholebrain = vcs(~isnan(ts_wholebrain));
            y_wholebrain = ts_wholebrain(~isnan(ts_wholebrain))/12500;

            x_hippo = vcs(~isnan(ts_hippo));
            y_hippo = ts_hippo(~isnan(ts_hippo))/100;               

            x_vents = vcs(~isnan(ts_vents));  
            y_vents = ts_vents(~isnan(ts_vents))/1000;       

            x_ento = vcs(~isnan(ts_ento));  
            y_ento = ts_ento(~isnan(ts_ento))/100;       

            x_fusi = vcs(~isnan(ts_fusi));  
            y_fusi = ts_fusi(~isnan(ts_fusi))/1000;       

            x_midtemp = vcs(~isnan(ts_midtemp));  
            y_midtemp = ts_midtemp(~isnan(ts_midtemp))/1000;       

            x_var = vcs(~isnan(ts_var));  
            y_var = ts_var(~isnan(ts_var))/100;       
            
            dxes = ridsat(:,5);
            ts_dx = zeros(length(dxes),2);
            ts_dx(:,1) = (1:length(dxes))';
            ts_dx(:,2) = dxes';
            ts_dx(ts_dx(:,2)<1,:) = NaN;

            figure('visible','off');
            %figure('visible','on');

            hold on;

            scatter(x_wholebrain,y_wholebrain,100,c1,'s','filled','Linewidth',3);
            lsline;

            scatter(x_hippo,y_hippo,100,c2,'s','filled','Linewidth',3);
            lsline;

            scatter(x_vents,y_vents,100,c3,'s','filled','Linewidth',3);
            lsline;  

%             scatter(x_fusi,y_fusi,100,c5,'s','filled','Linewidth',3);
%             lsline; 

            %scatter(ts_dx(:,1),ts_dx(:,2),100,'d','MarkerEdgeColor','r','MarkerFaceColor','k','Linewidth',2);
            thecols = {'g','o','r'};
            coltab = [0 0 0; 0 255 0; 255 255 0; 255 0 0];
            RGB = coltab(1+dxes',:); % set colour of diamonds
            ydx = ts_dx(:,2);  
            ydx(ydx>=1) = 4;    % set height of diamonds
            ydx(ydx<1)= NaN;
            if length(find(~isnan(ydx))) == 1
                % scatter generates a warning and refuses to use the colour value if it has only one non-NaN value
                disp('Length 1');
                thecol = thecols{dxes(~isnan(ydx))};
                scatter(vcs,ydx,100,thecol,'d', 'filled','MarkerEdgeColor','k');
            else
                scatter(vcs,ydx,100,RGB,'d', 'filled','MarkerEdgeColor','k');
            end

            ylim([0 100]);
            xlim([0 120]);
            fn = [fnstem num2str(k) '.eps' ] ;
            saveas(gcf,fn,'epsc');
            close;
            k = k + 1;
            if k > sample_size
                break;
            end
        end
        i = i + 1;
    end        
end




