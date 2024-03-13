function [soundSpeed] = getAirSpeed(P,modelFlag)
%GETAIRSPEED Estimates sound speed in air
%   P = structure with per-ping temperature and humidity measurements
%   modelFlag = flag for choice of sound speed model
%               0 = simple first order approximation, temperature dependence only
%               1 = higher order polynomial equation with temperature and humidity
%   soundSpeed = sound speed estimates, m/s

temp=mean(P.temp,2); %mean air temperature from two sensors
humidity=P.humidity*.01; %relative humidity, as a fraction

if exist('modelFlag','var')~=1 || isempty(modelFlag)
    modelFlag = 0;
end

switch modelFlag
    case 0
        soundSpeed=331.6+0.61*temp;
    case 1
        %from Owen Cramer, "The variation of the specific heat ratio and 
        %the speed of soundin air with temperature, pressure, humidity, 
        %and CO2 concentration" JASA 1992
        tempK=temp+273.15; %thermodynamic temperature, K
        p = 101.325e3; %atmpospheric pressure, Pa
        f = 1.00062+3.14e-8*p +5.6e-7*temp.^2;
        psv=exp(1.2811805e-5*tempK.^2-1.9509874e-2*tempK + 34.04926034 - 6.3536311e3./tempK); %saturation vapor pressure of water vapor in air, Pa
        xw=humidity.*f.*psv./p; %mol fraction of water vapor
        xc=0.0004; %mol fraction of carbon dioxide
        a0=331.5024;
        a1=0.603055;
        a2=-.000528;
        a3=51.471935;
        a4=0.1495874;
        a5=-0.000782;
        a6=-1.82e-7;
        a7=3.73e-8;
        a8=-2.93e-10;
        a9=-85.20931;
        a10=-0.228525;
        a11=5.91e-5;
        a12=-2.835149;
        a13=-2.15e-13;
        a14=29.179762;
        a15=0.000486;
        soundSpeed=a0+a1*temp+a2*temp.^2+(a3+a4*temp+a5*temp.^2).*xw+...
            (a6+a7*temp+a8*temp.^2)*p+(a9+a10+a11*temp.^2)*xc+...
            a12*xw.^2+a13*p^2+a14*xc^2+a15*xw*p*xc;

end

end

