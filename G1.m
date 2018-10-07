% Master tensegrity calculator

% ONLY USE WITH GRAPHGEOM

close all
clear all

iter = 15; % Number of iterations
projection = false; % Project onto modes?
collideOn = false; % Detect collisions?
fixOn = true; % Separate collisions?

contGraph = false; % Display every graph iteration
initGraph = false; % Display first graph
visOn = true; % Pretty visuals?
gifOn = false; % GIF on/off
graphOn = false; % Display eigenvalue graphs?
shownode = true; % Show nodes?
showlabel = false; % Show element labels?
showtitle = false; % Show title on model?

Cindex = 3;
n = 8;
d = 4;

% [node, elem, struts, cables, geomname, C] = graphGeom(6,5);
[node, elem, struts, cables, geomname, C] = graphGeom2(n,d,Cindex);

[nnode,~] = size(node);
[nelem,~] = size(elem);
length = zeros(nelem,1);
node0 = node; % Store for later

% set(0,'DefaultFigurePosition',[2 42 681 642])
% Masterplot(node,elem,struts,cables,geomname);
% title('Original configuration')
% ax = gca;
% ax.NextPlot = 'replaceChildren';
% 
% % Find the equilibrium matrix
% A = EqMat2(node,elem);
% [U,V,W] = svd(A);

found0 = true;
DQ = zeros(iter,1);
gamma = DQ;

if gifOn
    F(iter+1) = struct('cdata',[],'colormap',[]); % Frames for animation
    F(1) = getframe;
    im = frame2im(F(1));
    [imind,cm] = rgb2ind(im,256);
    imwrite(imind,cm,strcat(geomname,'.gif'),'Loopcount',inf);
end

% Record minimum eigenvalues, in order: smallest eig of A, eig(i)/eig(i-1)
% of A, fourth smallest eig of S, eig(i)/eig(i-1) of S, smallest eig of S
EigMin = zeros(iter+1,5);
EigMin(1,1) = 1;

A=[];U=[];V=[];W=[];

iterL = 0;
Lx = zeros(nnode,1);
Ly = zeros(nnode,1);
Lz = zeros(nnode,1);

if Cindex == 6
%     iterL = 1;
    Ly(4) = -1;
    Ly(8) = 1;
end

iconv = 0;

for i=1:iter
%     [node,selfstress,length,S,modes,A,EigMin,U,V,W] = ...
%         iterG2(i,node,elem,nnode,nelem,struts,cables,geomname,Cindex,...
%         A,EigMin,U,V,W,Lx,Ly,Lz,iterL,iter,projection,contGraph,initGraph,visOn,gifOn);
    if iconv == 0
        [node,selfstress,length,S,modes,A,EigMin,U,V,W,iconv] = ...
        iterG3(i,node,elem,nnode,nelem,struts,cables,geomname,Cindex,...
        A,EigMin,U,V,W,Lx,Ly,Lz,iterL,iter,projection,contGraph,initGraph,visOn,gifOn);
    else
        break
    end
end

% Sort elements by selfstress
s0 = [selfstress [1:nelem]' elem];
s0 = sortrows(s0);
selfstress = s0(:,1);
elem = s0(:,3:4);
struts = [1:size(struts)]';
nsymm = symm2(selfstress);
EigMin(iter,2);

if collideOn
    if visOn
        MasterplotVis(elem,node,shownode,showlabel,struts)
    else
        Masterplot(node,elem,struts,cables,geomname);
        title('Final configuration')
    end 
    [collpoints,nodeshift] = collision2(node,elem,visOn);
    if fixOn
        node = node+[nodeshift zeros(size(nodeshift))];
            [node,selfstress,length,S,modes,A,EigMin,U,V,W] = iterG(1,...
                node,elem,nnode,nelem,struts,cables,geomname,Cindex,A,...
                EigMin,U,V,W,iter,projection,contGraph,initGraph,visOn,gifOn);
        MasterplotVis(elem,node,shownode,showlabel,struts)
    end
end

EigMin(iter+1,2) = EigMin(iter,2); % Repeat final value (so it's non-zero)
EigMin(iter+1,4) = EigMin(iter,4);
EigMin(iter+1,5) = EigMin(iter,5);
  
% Plot nodal positions and elements
    
set(0,'DefaultFigurePosition',[685 42 681 642])
    
if graphOn
    if iter > 1
        figure
        plot(EigMin(:,1))
        xlabel('Iterations')
        %ylabel('Lowest singular values')
        %title('Lowest singular values')
        set(gca,'FontSize',20)
        hold on
        plot(EigMin(:,5))
        legend('A: lowest singular value','S: lowest eigenvalue')
        plot(zeros(iter,1),'--')

        figure
        plot(EigMin(:,2))
        xlabel('Iterations')
        %ylabel('Ratio of lowest singular values')
        title('Ratio of lowest singular values')
        set(gca,'FontSize',20)
    end
    
    figure
    plot(selfstress,'bo')
    hold on
    t = zeros(nelem,1);
    plot(t,'--')
    xlabel('Element number')
    ylabel('Tension')
    title('Self stress')
%     Should be continually negative (compression) then all positive
end

% if ~ contGraph
%     Masterplot(node,elem,struts,cables,geomname);
%     title('Final configuration')
% end

exampleC = false;
if exampleC
    node = [
            0.5 1 0
            1 0.5 0
            1 -0.5 0
            0.5 -1 0
            -0.5 -1 0
            -1 -0.5 0
            -1 0.5 0
            -0.5 1 0];
    node = [node zeros(size(node))];
    MasterplotVis(elem,node,true,false,struts)
    for i = 1:nnode
        m = node(i,1:3)*1.2;
            f = text(m(1),m(2),m(3),sprintf('%g',i));
            f.FontSize = 32;
            set(f,'Color','black')
    end
    view(2)
end

if ~ collideOn
    if visOn
        MasterplotVis(elem,node,shownode,showlabel,struts)
        if showtitle
            if nnode == 8 && d == 4
                h1 = title(strcat('G(',num2str(n),',',num2str(d),')_{',num2str(C2G(Cindex)),'}'));
                set([h1], 'interpreter', 'tex');
                set(gca,'FontSize',40)
            elseif nnode == 8 && d == 5
                h1 = title(strcat('G(',num2str(n),',',num2str(d),')_{',num2str(C2Q(Cindex)),'}'));
                set([h1], 'interpreter', 'tex');
                set(gca,'FontSize',40)
            end
        end
    else
        Masterplot(node,elem,struts,cables,geomname);
        title('Final configuration')
    end
end

if iterL == 0 && Cindex == 6
%     plotL(node,Lx,Ly,Lz)
end

if n == 8 && d == 5
    eig(abs(C))
end

% if collideOn
%     [collpoints,nodeshift] = collision2(node,elem,visOn);
%     if fixOn
%         node = node+[nodeshift zeros(size(nodeshift))];
%         
%         for i = 1:3
%         [node,selfstress,length,S,modes,A,EigMin,U,V,W] = iterG(i,node,elem,nnode,nelem,struts,cables,geomname,Cindex,A,EigMin,U,V,W,iter,projection,contGraph,initGraph,visOn,gifOn);
%         end
%         
%         if visOn
%             MasterplotVis(elem,node,true,true,struts)
%         else
%             Masterplot(node,elem,struts,cables,geomname);
%             title('Final configuration')
%         end
%     end
% end

% Display movie
% if gifOn
    % fig = figure;
    % movie(fig,F,1,3)
% end
   

