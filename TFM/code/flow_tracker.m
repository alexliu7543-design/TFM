function idx=flow_tracker(pts1,pts2,maxdisp,n_consider,n_use,varargin)
% Rob's flow tracker.. idea is to track particles that move in clusters

% Inputs
% pts1 List of particles in first frame, [X,Y], N x column vector
% pts2 List of particles in second frame, [X,Y], N x column vector
% n_use Number of nearest neighbours to use
% n_consider Number of nearest neighbours to consider
% maxdisp Maximum distance particles can move
% varargin If you want to put limits on how far a particle can move in x,y
% or z, just add 'x',2 or 'y',10 etc

% Outputs
% idx is a two column vector, with the first column being the number of the
% particle in pts1, and the second being the number that it corresponds to
% in pts2


% First set up the bounds on the displacement. See varargin above
k=0;
maxdisp_x=maxdisp;
maxdisp_y=maxdisp;
maxdisp_z=maxdisp;
if ~isempty(find(strcmp(varargin,'x'), 1))
    ind=find(strcmp(varargin,'x'));
    maxdisp_x=min(varargin{ind(1)+1},maxdisp);
end
if ~isempty(find(strcmp(varargin,'y'), 1))
    ind=find(strcmp(varargin,'y'));
    maxdisp_y=min(varargin{ind(1)+1},maxdisp);
end
if ~isempty(find(strcmp(varargin,'z'), 1))
    ind=find(strcmp(varargin,'z'));
    maxdisp_z=min(varargin{ind(1)+1},maxdisp);
end

% For each point in pts1, find the nearest n_consider points in pts1, and do the same
% for each point in pts2.

near_neighb_inds_pts1=zeros(length(pts1),n_consider+1);
near_neighb_inds_pts2=zeros(length(pts2),n_consider+1);

% First get a list of indices of the nearest n_consider neighbours of each
% point in pts1
for i=1:size(pts1,1)
    [~,I]=mink(sum((pts1-pts1(i,:)).^2,2),n_consider+1);
    near_neighb_inds_pts1(i,:)=I';
end

% Next get a list of indices of the nearest n_consider neighbours of each
% point in pts2
for i=1:size(pts2,1)
    [~,I]=mink(sum((pts2-pts2(i,:)).^2,2),n_consider+1);
    near_neighb_inds_pts2(i,:)=I';
end

% Remove the first column, because these are the points themselves - not
% nearest neighbours
near_neighb_inds_pts1(:,1)=[];
near_neighb_inds_pts2(:,1)=[];

siz=size(pts1);
N=siz(2);

nn=zeros(length(pts1(:,1)),3);

for i=1:length(pts1(:,1))
    % Now for each point in pts1, find the nearest points in pts2 that
    % satisfy any constraints you put in on x, y and z displacements
    if N==1
        inds_near=sum((pts2-pts1(i,:)).^2,2)<maxdisp^2 & (pts2(:,1)-pts1(i,1)).^2<maxdisp_x^2;
    elseif N==2
        inds_near=sum((pts2-pts1(i,:)).^2,2)<maxdisp^2 & (pts2(:,1)-pts1(i,1)).^2<maxdisp_x^2 & (pts2(:,2)-pts1(i,2)).^2<maxdisp_y^2;
        % sum(...,2) means sum them up by row not coloum
        % inds_near is a coloum matrix which have the information fulfill
        % the constraint
    else
        inds_near=sum((pts2-pts1(i,:)).^2,2)<maxdisp^2 & (pts2(:,1)-pts1(i,1)).^2<maxdisp_x^2 & (pts2(:,2)-pts1(i,2)).^2<maxdisp_y^2 & (pts2(:,3)-pts1(i,3)).^2<maxdisp_z^2;
    end
    % for each particle in pts1, inds_near gives a list of the indices of
    % particles in pts2 that could be matches
    inds_near=find(inds_near); % 提取出来了所有的在pts2的indices，满足条件的

    if ~isempty(inds_near)
        for j=1:length(inds_near)
            % Work out the relative positions of the nearest neighbours to
            % the point in pts1
            ri=pts1(near_neighb_inds_pts1(i,:),:)-pts1(i,:);
            % ri 是所有consider的点对 ri 的相对矢量
            % do the same for pts2
            rj=pts2(near_neighb_inds_pts2(inds_near(j),:),:)-pts2(inds_near(j),:);
            % rj 是满足maxdisp条件的点的所有consider的点对rj的相对矢量
            % Calculate the squared distance matrix for each of the
            % relative particle points ri, rj
            dij = bsxfun(@plus,sum(ri.*ri,2),sum(rj.*rj,2)') - 2*ri*rj';
            % d^2 = (xi-xj)^2 + (yi-yj)^2
            % The cost in the cost matrix is the sum of the distances
            % between n_use points. Note this cheats slightly, as it
            % doesn't use the minimum in both column and row, but I've
            % found this works well in practice.
            pm(j)=sum(sqrt(mink(min(dij,[],2),n_use)));
            % min返回维度 dim 上的最小元素。例如，如8果 A 为矩阵，则 min(A,[],2) 返回包含每一行的最小值的列向量。
        end
        % Find the minimum value of the penalty function for all the
        % potential particle pairs, and the index in pts2 of the
        % corresponding particle
        [penalty,ind_nn2]=min(pm);
        % Update a matrix that collects the index of the pts1 particle, the
        % index of its best match particle in pts2 and the penalty
        nn(i,1:3)=[i,inds_near(ind_nn2),penalty];
        clear pm
    else
        nn(i,1:3)=[NaN NaN NaN];
    end
end
% remove the NaN rows from nn
nn(isnan(nn(:,1)),:)=[];
% sort the rows to collect all the rows with the same pts2 particle
% together, and order so the one with the lowest penalty comes first
nn=sortrows(nn,[2,3]);
% throw away the repeat points in column 2 where the penalty isn't the
% lowest value
[~,inds]=unique(nn(:,2));
nn=nn(inds,:);
% sort the rows so that the first column is in order. This step can
% probably be deleted
nn=sortrows(nn,1);

% Spit out the indices of particle pairs from pts1 and pts2
idx=nn(:,1:2);

end
