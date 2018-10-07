function [collpoints,nodeshift] = collision2(node,elem,visOn)

collpoints = []; % Record which elements collide, and at which point
nodeshift = zeros(size(node,1),3); % Move nodes to remove collision
cshift = 0.02; % Factor by which to shift nodes. Default 0.03

for e1 = 1:size(elem,1)-1
    for e2 = e1+1:size(elem,1)
        
%         Ensure that elements being compared don't have a common node
        if length(unique([elem(e1,:) elem(e2,:)])) == 4

            n4 = [node(elem(e1,1),1:3); node(elem(e1,2),1:3); node(elem(e2,1),1:3); node(elem(e2,2),1:3)];

            % u1 = (n1b-n1a)';
            % u2 = (n2b-n2a)';
            % u0 = (n2a-n1a)';
            u0 = (n4(3,:)-n4(1,:))';
            u1 = (n4(2,:)-n4(1,:))';
            u2 = (n4(4,:)-n4(3,:))';
            

            f = [1 1];
            Aeq = [u1 -u2];
            beq = [u0];
            lb = [0; 0];
            ub = [1; 1];

            % options = optimoptions('linprog','Algorithm','dual-simplex');
            [t,fval,exitflag,output] = linprog(f,[],[],Aeq,beq,lb,ub);

            collpoint1 = n4(1,:) + t(1)*u1';
            collpoint2 = n4(3,:) + t(2)*u2';

            if max(abs(collpoint1 - collpoint2)) < 0.0001 %&& min(t) > 0.000001 && max(t) < 0.9999999
                collide = true;
                collpoints(size(collpoints,1)+1,:) = [e1 e2 collpoint1];
                
%                 Shift using vector normal to plane of crossing
                nodeshift(elem(e1,:),:) = nodeshift(elem(e1,:),:)+cshift*cross(u1,u2)';
                nodeshift(elem(e2,:),:) = nodeshift(elem(e2,:),:)-cshift*cross(u1,u2)';
            else
                collide = false;
            end

    %         collide = true;
            if collide
                if visOn
                    hold on
                    radius = 0.04;
                    resolution = 40;
                    xcenter = collpoint1(1);
                    ycenter = collpoint1(2);
                    zcenter = collpoint1(3);
                    [Xsphere,Ysphere,Zsphere] = sphere(resolution);

                    xsphere = Xsphere*radius + xcenter;
                    ysphere = Ysphere*radius + ycenter;
                    zsphere = Zsphere*radius + zcenter;

                    solidsphere = surf(xsphere,ysphere,zsphere);
                    set(solidsphere,'FaceColor',[1 0 0],'EdgeColor','none');
                    material shiny;    
                else
                    plot3(collpoint1(1),collpoint1(2),collpoint1(3),'ro')
                end
            end
        end
    end
end