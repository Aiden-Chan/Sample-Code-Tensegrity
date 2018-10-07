function [node,elem,struts,cables,geomname,C] = graphGeom2(v,d,Cindex)

geomname = 'graph';
node = rand(v,3);
node = [node zeros(size(node))];
store = true;

nelem = 0;
elem = [0 0];
cables = [];
struts = [];

if store && v==8 && d==4
    load CstoreV8D4
%     load CstoreV8D4_red2
    C = Cstore(:,:,Cindex);
    
elseif store && v==8 && d==5
    load CstoreV8D5
    C = Cstore(:,:,Cindex);
%     trial = true;
%     if trial
%         C = [
%     0 -1 1 1 1 1 0 0
%     -1 0 1 0 0 1 1 1
%     1 1 0 1 0 0 -1 1
%     1 0 1 0 -1 0 1 1
%     1 0 0 -1 0 1 1 1
%     1 1 0 0 1 0 1 -1
%     0 1 -1 1 1 1 0 0
%     0 1 1 1 1 -1 0 0];
%     end
    
elseif store && v==10 && d==4
    load CstoreV10D4
    C = Cstore(:,:,Cindex);
    
elseif store && v==6 && d==3
    load CstoreV6D3
    C = Cstore(:,:,Cindex);
    
else
    C = graphConnect(v,d);
end

for i = 1:v-1
    for j = i+1:v
        if C(i,j) == 1 || C(i,j) == -1
            nelem = nelem+1;
            elem(nelem,:) = [i j];
            if C(i,j) == 1
                cables(size(cables,2)+1) = nelem;
            else
                struts(size(struts,2)+1) = nelem;
            end
        end
    end
end

cables = cables';
struts = struts';

% C =
% 
%      0    -1     1     0     1     1     0     0
%     -1     0     1     0     0     1     0     1
%      1     1     0    -1     0     0     1     0
%      0     0    -1     0     0     1     1     1
%      1     0     0     0     0    -1     1     1
%      1     1     0     1    -1     0     0     0
%      0     0     1     1     1     0     0    -1
%      0     1     0     1     1     0    -1     0


