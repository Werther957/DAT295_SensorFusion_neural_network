function R = infinitesimalRotation2rotationMatrix(theta)
R = [          1, -theta(3),  theta(2);
        theta(3),         1, -theta(1);
       -theta(2),  theta(1),        1];
end
