%% This is the main function which is from Pranovich's paper.
function Fr = MAT12_gonio_brdf(angles, alpha, parameters)

    rho = parameters(1:31);
    c   = parameters(32:62);
    Fr = zeros(size(angles, 1), 31);

    for k = 1:size(angles, 1)
        theta_i = deg2rad(angles(k, 1));
        theta_o = deg2rad(angles(k, 2));
        theta_h = (theta_i - theta_o)/ 2;

        numerator = alpha^2 .* rho .* exp(c .* (1 - cos((theta_i + theta_o)/2))) ;
        denominator = 4 * pi .* (((alpha^2 - 1) * cos(theta_h).^2) + 1).^2;
        Fr(k,:) = numerator ./ denominator;
    end

end