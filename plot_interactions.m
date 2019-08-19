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

function plot_interactions()

    addpath('../../shared/code/common');
    addpath('../../shared/code/util');

    tic;
    
    close all;        
           
     % choose data tag 
    datatag = 'brain702xt';                  
    load(['./data/tpdata_' datatag],'tpdata');   
    
    % time matched sets for paper
    load('./data/training_set','sadrids','snlrids','smcirids');           
 
    % healthy set
    if 1
        fnstem =  '../docs/interaction_plots/figures/nl';
        plot_features(snlrids,tpdata,fnstem,21);         
    end
    
    % AD set
    if 1
        fnstem =  '../docs/interaction_plots/figures/ad';
        plot_features(sadrids,tpdata,fnstem,21); 
    end 
    % MCI set
%    fnstem =  '../docs/interaction_plots/figures/mci';
%    plot_features(smcirids,tpdata,fnstem,true,21); 
%         
    toc;
    
end


% function
function plot_features(ridsample,tpd,fnstem,sample_size)    
    
    c1 = [0 0.6 1]; % blue 
    i = 1;
    while i<=sample_size
        
        disp(i);
        rid = ridsample(i);
        ridsat = tpd(tpd(:,1)==rid,:);
        ridsat = sortrows(ridsat,4);
                    
        idx = find(ridsat(:,4)==24);
        ts_wholebrain = ridsat(1:idx,23);        
        ts_hippo = ridsat(1:idx,22);
        ts_vents = ridsat(1:idx,34);

         % remove 3 month measurements which are exclusive to AD
        id3 = find(ridsat(:,4)==3);
        if id3
            ts_wholebrain(id3,:) = [];             
            ts_hippo(id3,:) = [];             
            ts_vents(id3,:) = [];             
        end              

        % scale wholebrain, hippocampus, ventricles  
        scale = [1000000 10000 100000];    
        idx = ~isnan(ts_hippo) & ~isnan(ts_wholebrain) & ~isnan(ts_vents);
        yval = ts_hippo(idx)/scale(2);               
        xval = ts_wholebrain(idx)/scale(1);        

        figure('visible','off');
%        figure('visible','on');
        daspect([0.55 1 1 ]);
        hold on;

        % plot hippocampus vs wholebrain
%        xsval = [xval(1) xval(end) ];
%        ysval = [yval(1) yval(end) ];
        xsval = [xval(1)];
        ysval = [yval(1)];
        
        scatter(xsval,ysval,500,c1,'s','filled','Linewidth',3);
        set(gca,'XTick',[]);
        set(gca,'YTick',[]);        
        set(gca,'XTickLabel',[]);
        set(gca,'YTickLabel',[]);        
        
%         for k=1:numel(xval)
%             text(xval(k),yval(k),num2str(k),'FontSize',18);
%         end
        
        % draw path       
        for ip = 1:numel(xval)-1
            x1 = [xval(ip),xval(ip+1)];
            y1 = [yval(ip),yval(ip+1)];
            plot(x1,y1,'k-','Linewidth',6);
        end
        arrow3([x1(1) y1(1)],[x1(2) y1(2)],'k-',0.65,0.65);
        
        % centre image
        ctx = min(xval) + 0.5*(max(xval) - min(xval));
        cty = min(yval) + 0.5*(max(yval) - min(yval));
                
        xlim([ctx-0.05,ctx+0.05]);
        ylim([cty-0.07, cty+0.07]);
        fn = [fnstem num2str(i) '.eps' ] ;
        saveas(gcf,fn,'epsc');
        %close;
        i = i + 1;
    end        
end




