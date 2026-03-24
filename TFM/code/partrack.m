function trks = partrack(parimg1,parimg2,position,lnoise,lobject,pksz,ctsz)
for k = 1:10
    th = th/k;
    pk = pkfnd(parimg1,th,pksz);
    cnt = cntrd(parimg1,pk,ctsz);
    cnt1 = zeros(length(cnt),3);
    for k = 1:length(cnt)
        cnt1(k,1) = cnt(k,1);
        cnt1(k,2) = cnt(k,2);
        cnt1(k,3) = time;
    end
    pk = pkfnd(parimg1,th,pksz);
    cnt = cntrd(parimg1,pk,ctsz);
    cnt2 = zeros(length(cnt),3);
    for k = 1:length(cnt)
        cnt2(k,1) = cnt(k,1);
        cnt2(k,2) = cnt(k,2);
        cnt2(k,3) = time;
    end
    Pos_list = [cnt1
        cnt2];

    %% Plot the two images to identify the rough displacement
    % figure,imagesc(im1-im2);
    % axis image;
    %colormap(jet);

    track_result = trackone(position,Pos_list,maxdisp); %why is it 10



    function idx = trackone(pt,pts1,pts2,maxdisp,n_consider,n_use,varargin)

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

        % For pt, find the nearest n_consider points in pts1

        near_neighb_inds_pt=zeros(length(pt),n_consider+1);
        near_neighb_inds_pts2=zeros(length(pts2),n_consider+1);

        % First get a list of indices of the nearest n_consider neighbours of each
        % point in pt

        [~,I]=mink(sum((pts1-pt(i,:)).^2,2),n_consider+1);
        near_neighb_inds_pt(i,:)=I';


        % Next get a list of indices of the nearest n_consider neighbours of each
        % point in pts2
        for i=1:size(pts2,1)
            [~,I]=mink(sum((pts2-pts2(i,:)).^2,2),n_consider+1);
            near_neighb_inds_pts2(i,:)=I';
        end

        % Remove the first column, because these are the points themselves - not
        % nearest neighbours
        near_neighb_inds_pt(:,1)=[];
        near_neighb_inds_pts2(:,1)=[];

        nn=zeros(length(pts1(:,1)),3);


        inds_near=sum((pts2-pt(i,:)).^2,2)<maxdisp^2 & (pts2(:,1)-pt(i,1)).^2<maxdisp_x^2 & (pts2(:,2)-pt(i,2)).^2<maxdisp_y^2;


        for j=1:length(inds_near)
            % Work out the relative positions of the nearest neighbours to
            % the point in pts1
            ri=pts1(near_neighb_inds_pt(i,:),:)-pts1(i,:);
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

    end


end