function evidence = verify_course_toolbox(toolboxPath,root)
%VERIFY_COURSE_TOOLBOX Require exact bytes of the user-provided course files.
% No toolbox source is copied, edited or submitted. Verify MATLAB resolution
% as well as SHA-256 so another installed distribution cannot be used silently.
manifest=jsondecode(fileread(fullfile(root,'validation','course_toolbox_manifest.json')));
names={'ranking','sus','recint','mutbga','rep'}; resolved=struct();
for k=1:numel(names)
    name=names{k}; actual=which(name); expected=fullfile(toolboxPath,[name '.m']);
    assert(strcmpi(char(java.io.File(actual).getCanonicalPath()), ...
        char(java.io.File(expected).getCanonicalPath())), ...
        'Operator %s resolves outside the provided course directory.',name);
    fid=fopen(actual,'rb'); assert(fid>=0); bytes=fread(fid,Inf,'*uint8'); fclose(fid);
    md=java.security.MessageDigest.getInstance('SHA-256'); md.update(bytes);
    digest=typecast(md.digest(),'uint8'); sha=lower(reshape(dec2hex(digest,2).',1,[]));
    idx=find(strcmp({manifest.files.name},[name '.m']));
    assert(numel(idx)==1 && strcmp(sha,manifest.files(idx).sha256), ...
        'Course operator %s differs from the supplied download.',name);
    resolved.(name)=struct('path',actual,'sha256',sha,'bytes',numel(bytes));
end
% Course ranking requires [pressure, linear/nonlinear flag], not a scalar.
f=ranking((1:4)',[1.8 0]); assert(max(abs(f-[1.8;1.266666666666667;0.733333333333333;0.2]))<1e-12);
evidence=struct('passed',true,'source','User-supplied course GA Toolbox', ...
    'operators',resolved,'linearRankingArguments',[1.8 0],'matlabVersion',version);
fid=fopen(fullfile(root,'validation','course_toolbox_runtime.json'),'w');
fprintf(fid,'%s',jsonencode(evidence,PrettyPrint=true)); fclose(fid);
fprintf('Course toolbox exact-byte and MATLAB-resolution checks PASSED.\n');
end
