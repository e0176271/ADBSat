function [cp, ctau, cd, cl] = coeff_DRIA(param_eq, delta)
% Calculates aerodynamic coefficients for a flat plate using DRIA (Diffuse
% Reflection with Incomplete Accommodation)
% [Doornbos E (2012) Thermospheric Density and Wind Determination from Satellite Dynamics]
%
% Inputs:
%       param_eq.alpha  : Accomodation coefficient
%       param_eq.s      : Thermal speed ratio [-]
%       param_eq.Tw     : Wall temperature [K]
%       delta           : Angle between the flow and the surface normal(external) [rad]
%
% Outputs:
%       cp      : Pressure coefficient [-]
%       ctau    : Shear stress coefficient [-]
%       cd      : Drag coefficent [-]
%       cl      : Local Lift coefficient [-]
%
% Author: Nicholas H. Crisp
% The University of Manchester
% July 2021
%
%--- Copyright notice ---%
% Copyright (C) 2021 The University of Manchester
% Written by David Mostaza Prieto,  Nicholas H. Crisp, Luciana Sinpetru and Sabrina Livadiotti
%
% This file is part of the ADBSat toolkit.
%
% This program is free software: you can redistribute it and/or modify it
% under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or (at
% your option) any later version.
%
% This program is distributed in the hope that it will be useful, but
% WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General
% Public License for more details.
%
% You should have received a copy of the GNU General Public License along
% with this program. If not, see <http://www.gnu.org/licenses/>.
%------------- BEGIN CODE -------------

[data] = astrophysicalConstants;

Tinf = param_eq.Tinf;
Vinf = param_eq.vinf;
alpha = param_eq.alpha;
s = param_eq.s;
Tw = param_eq.Tw;
mmean = param_eq.mmean;
massConc = param_eq.massConc;

m = [data.constants.mH, data.constants.mHe, data.constants.mN,...
    data.constants.mO, data.constants.mAnO, data.constants.mN2,...
    data.constants.mO2, data.constants.mAr];

gam = cos(delta);
ell = sin(2*delta);

for j = 1:8 % Species specific (by mass concentration)
    s_j = Vinf./sqrt(2*data.constants.kb*Tinf/(m(j)/data.constants.NA/1000));
    P = exp(-gam.^2 * s_j.^2)./s_j;
    G = 1/(2*s_j.^2);
    Q = 1+G;
    Z = 1+erf(gam.*s_j);
    R = data.constants.R/m(j) * 1e3; % Specifc gas constant
    Vratio = sqrt((1/2)*(1+alpha.*((4*R*Tw)./Vinf.^2 - 1))); % [Doornbos 2012]
    cd_j(:,j) = P./sqrt(pi) + gam.*Q.*Z + 0.5*gam.*Vratio.*(gam.*sqrt(pi).*Z + P);
    cl_j(:,j) = ell.*G.*Z + 0.5*ell.*Vratio.*(gam.*sqrt(pi).*Z + P);
end
cd = sum(cd_j.*repmat(massConc,[size(cd_j,1),1]),2)';
cl = sum(cl_j.*repmat(massConc,[size(cd_j,1),1]),2)';

% gam = cos(delta);
% ell = sin(2*delta);
% P = exp(-gam.^2 * s.^2)./s;
% G = 1/(2*s.^2);
% Q = 1+G;
% Z = 1+erf(gam.*s);
% R = data.constants.R/mmean * 1e3; % Specifc gas constant
% Vratio = sqrt((1/2)*(1+alpha.*((4*R*Tw)./Vinf.^2 - 1))); % [Doornbos 2012]
% cd = P./sqrt(pi) + gam.*Q.*Z + 0.5*gam.*Vratio.*(gam.*sqrt(pi).*Z + P);
% cl = ell.*G.*Z + 0.5*ell.*Vratio.*(gam.*sqrt(pi).*Z + P);

cp   = cd.*cos(delta) + cl.*sin(delta);
ctau = cd.*sin(delta) - cl.*cos(delta);

%------------- END OF CODE --------------

% Mehta DRIA Flat Plate
% T_ki = ((mmean*1e-3/data.constants.NA) * Vinf^2)/(3*data.constants.kb); % Incoming kinetic temperature [K]
% T_kr  = T_ki*(1-alpha) + alpha*Tw; % Reflected kinetic temperature [K]
% V_r = Vinf * sqrt(2/3) * sqrt(1 + alpha*(Tw/T_ki - 1)); % Reflected particle velocity
% cd_m = (2 + 1/s.^2).*erf(s) + (2/(sqrt(pi)*s))*exp(-s.^2) + (sqrt(pi)/s)*sqrt(T_kr/Tinf);
% cl_m = 0;