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
    fnstem =  '../docs/interaction_plots/figures/nl';
    plot_features(snlrids,tpdata,fnstem,21); 

    % AD set
    fnstem =  '../docs/interaction_plots/figures/ad';
    plot_features(sadrids,tpdata,fnstem,21); 

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

        hold on;

        % plot hippocampus vs wholebrain
        scatter(xval,yval,300,c1,'s','filled','Linewidth',3);
        set(gca,'XTickLabel',[]);
        set(gca,'YTickLabel',[]);        
        
%         for k=1:numel(xval)
%             text(xval(k),yval(k),num2str(k),'FontSize',18);
%         end
        
        % draw path
        for ip = 1:numel(xval)-1
            p1 = [xval(ip),yval(ip)];
            p2 = [xval(ip+1),yval(ip+1)];
            dp = p2-p1;
%             if ip == numel(xval)-1
%                 arrow_length=36;
%             else
%                 arrow_length=0;
%             end
%             arrow(p1,p2,20,'BaseAngle',90,'LineWidth',10,'Length',arrow_length);
            q=quiver(p1(1),p1(2),dp(1),dp(2),0);
            q.Color = 'k';
            q.LineWidth = 10;
            q.MaxHeadSize = 2;
            q.AutoScale = 'off';
            if ip == numel(xval)-1
                q.ShowArrowHead = 'on';
            else
                q.ShowArrowHead = 'off';
            end
        end

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




