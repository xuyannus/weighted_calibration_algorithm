%This code will save a sparse matrix to a sparse format.
%By Ma Wei,15.08.2013

function save2SparseMatrix(A)
[p,m] = size(A);
buffer=[];

for i=1:p
  for j=1:m
    if A(i,j) > 0
      buffer=[buffer;i j A(i,j);];
    end
  end
end

save wh.dat buffer -ascii;
