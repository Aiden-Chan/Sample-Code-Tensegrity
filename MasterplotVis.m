function MasterplotVis(elem,node,shownode,showlabel,struts)

% This function models the given symmetric structures
% element, node - details of elements and nodes
% showlabel and shownode, true/false - used to label on or off for element no and node no
% type - used to show actual or displaced shape of model

sf = max(max(node))-min(min(node)); % Scale factor

figure
    for i=1:size(elem,1)

    %     Display cables/struts
        FnCoordinate = node(elem(i,1),1:3)';
        SnCoordinate = node(elem(i,2),1:3)';

        vtr1 = (FnCoordinate-SnCoordinate);
       [Q,~] = qr(vtr1);
       vtr3 = Q(:,2);
       vtr4 = Q(:,3);

        theta =[0:2*(pi/40):2*pi];    
        switch0 = max(struts==i);
        switch switch0
            case 0
%                 Cable
                r=0.01*sf;
                circle = r*[vtr3*cos(theta)+vtr4*sin(theta)];
                circle1 = circle+repmat(FnCoordinate,[size(theta)]);
                circle2 = circle+repmat(SnCoordinate,[size(theta)]);

                Surface = [permute(circle1,[3 2 1]); permute(circle2,[3 2 1])];    
                hh = surf(Surface(:,:,1), Surface(:,:,2), Surface(:,:,3), 'EdgeColor','none','FaceColor',[0.5 0.5 0.9]); %[0.1 0.1 0.1]
                material shiny;            
            case 1       
%                 Strut
                r=0.015*sf;
                circle = r*[vtr3*cos(theta)+vtr4*sin(theta)];
                circle1 = circle+repmat(FnCoordinate,[size(theta)]);
                circle2 = circle+repmat(SnCoordinate,[size(theta)]);

                Surface = [permute(circle1,[3 2 1]); permute(circle2,[3 2 1])];
                hh = surf(Surface(:,:,1), Surface(:,:,2), Surface(:,:,3), 'EdgeColor','none','FaceColor',[1 0.62 0.4]); %copper strut
                material dull;
        end      
        hold on
        
        if showlabel
            m = (FnCoordinate+SnCoordinate)./2 + sf*[0.03 0.03 0.03];
            f = text(m(1),m(2),m(3),sprintf('%g',i));
            f.FontSize = 14;
            set(f,'Color','black')
        end
        
    end

    % For displaying nodes
    radius = 0.04*sf; resolution = 40;
    if shownode
        for j=1:size(node,1)
            xcenter = node(j,1);
            ycenter = node(j,2);
            zcenter = node(j,3);

            [Xsphere,Ysphere,Zsphere] = sphere(resolution);

            xsphere = Xsphere*radius + xcenter;
            ysphere = Ysphere*radius + ycenter;
            zsphere = Zsphere*radius + zcenter;

            solidsphere = surf(xsphere,ysphere,zsphere);
            set(solidsphere,'FaceColor',[0.3 0.3 0.3],'EdgeColor','none');
            material shiny;           
            hold on
        end 
    end

    axis equal
    xlabel('x-axis')
    ylabel('y-axis')
    zlabel('z-axis')
    view(57,28);
    grid off
    axis off
    axis vis3d
    camlight;

    hold on


