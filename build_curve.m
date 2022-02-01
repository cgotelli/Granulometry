function [D50, Volumes, ecdf, sortMinor] = build_curve(minor, major, binsize)

%Granulometric curve plot from minor axis length array (here identified as minor). We use minor diameter since
%it is that size which will determine if a particle passes through a sieve or not.

%Volumes calculation
%Note: this is an approximation based on the assumption of the similarity
% with the sphere volume (with minor_axi ~= b axis ~= diameter)

    Volumes         =   4/3*pi*(minor/2).^(3);                      % Computes the volume for each particle
    minScaleMin     =   max(round(min(minor),1) - 10*binsize,0);    % Lower boundary for diameters' size class 
    maxScaleMin     =   round(max(minor),1) + 10*binsize;           % Top boundary
    vecEchelleMin   =   minScaleMin:binsize:maxScaleMin;            % Subdivision in equal size bins
    minScaleMax     =   min(round(min(major),1) - 10*binsize,0);    % Lower boundary for diameters' size class 
    maxScaleMax     =   round(max(major),1) + 10*binsize;           % Top boundary
    vecEchelleMax   =   minScaleMax:binsize:maxScaleMax;            % Subdivision in equal size bins
    
    CumVolMin = zeros(length(vecEchelleMin)-1,1);
    CumVolMaj = zeros(length(vecEchelleMax)-1,1);

    for l = 1:length(vecEchelleMin)-1
        CumVolMin(l,1) = sum(Volumes(minor>vecEchelleMin(l) & minor<vecEchelleMin(l+1)));
    end
    
    for l = 1:length(vecEchelleMax)-1
        CumVolMaj(l,1) = sum(Volumes(major>vecEchelleMax(l) & major<vecEchelleMax(l+1)));
    end

    fracMin   = CumVolMin/sum(Volumes);
    fracMaj   = CumVolMaj/sum(Volumes);
    
    % frequency histogram
    lmMin =   vecEchelleMin(1:end-1)+binsize/2;
    lmMaj =   vecEchelleMax(1:end-1)+binsize/2;
    
    bar(lmMin,fracMin*100,1,'y');
    hold on
    
    % ECDF computation and plot
    VolCum(1)   = 0;
    sortVolumes = sort(Volumes);
    sortMinor   = sort(minor);
    
    for k = 2:length(sortVolumes)
        VolCum(k) = sortVolumes(k)+VolCum(k-1);
    end
    
    ecdf = VolCum/sum(Volumes)*100;
    
    hold on
    plot(sortMinor,ecdf,'r')
    
% D16, D50 and D84 based on volume distribution

[mini16, ind16]  =   min(abs(ecdf-16));
[mini50, ind50]  =   min(abs(ecdf-50));
[mini84, ind84]  =   min(abs(ecdf-84));

% Values for each important diameter
D16 =   sortMinor(ind16);
D50 =   sortMinor(ind50);
D84 =   sortMinor(ind84);

% Print those values in command window
disp(strcat(['d16 = ',num2str(D16,'%.3g'), ' mm']))
disp(strcat(['d50 = ',num2str(D50,'%.3g'), ' mm']))
disp(strcat(['d84 = ',num2str(D84,'%.3g'), ' mm']))

% Add straight lines showing the values of each important diameter.
plot([D50 D50],[0 100],'--k')
hold on
plot([D16 D16],[0 100],'-k')
hold on
plot([D84 D84],[0 100],'-k')

lgnd = legend(['{N. particles = ' num2str(length(minor)) '}'],'cdf', ... 
    ['{$D_{50} =\,$' num2str(round(D50,2,'significant')) ' mm}'], ... 
    ['{$D_{16} =\,$' num2str(round(D16,2,'significant')) ' mm}'], ... 
    ['{$D_{84} =\,$' num2str(round(D84,2,'significant')) ' mm}'], ... 
    'Location','East','interpreter','latex');
set(lgnd,'Box','off');
set(lgnd,'color','none');
set(gca,'TickLabelInterpreter','latex')
xlabel('\textbf{$d_i$ [mm]}','interpreter','latex')
ylabel('$\%$ \textbf{Passing V}','interpreter','latex')  

x0=800;
y0=300;
width=700;
height=400;
set(gcf,'position',[x0,y0,width,height])

end
