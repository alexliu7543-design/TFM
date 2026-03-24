function [vertex,faces,normal] = read_obj(filename)

fid = fopen(filename);
if fid<0
    error(['Cannot open ' filename '.']);
end

frewind(fid);
a = fscanf(fid,'%c',1);
if strcmp(a, 'P')
    fscanf(fid,'%f',5);
    n_points=fscanf(fid,'%i',1);
    vertex=fscanf(fid,'%f',[3,n_points]);
    normal=fscanf(fid,'%f',[3,n_points]);
    n_faces=fscanf(fid,'%i',1);
    fscanf(fid,'%i',5+n_faces);
    faces=fscanf(fid,'%i',[3,n_faces])'+1;
    fclose(fid);
    return;
end

frewind(fid);
vertex = [];
faces = [];
while 1
    s = fgetl(fid);
    if ~ischar(s), 
        break;
    end
    if ~isempty(s) && strcmp(s(1), 'f')
        % face
        faces(:,end+1) = sscanf(s(3:end), '%d %d %d');
    end
    if ~isempty(s) && strcmp(s(1), 'v')
        % vertex
        vertex(:,end+1) = sscanf(s(3:end), '%f %f %f');
    end
end
fclose(fid);
