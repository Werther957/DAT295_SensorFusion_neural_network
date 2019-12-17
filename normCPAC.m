function out = normCPAC(in)
out = zeros(1,1,'like', in);
for i = int32(1):length(in)
    out = out + in(i)^2;
end
out = sqrt(out);
end

