% This code simulates the growth and drowning of coral reefs due to sea
% level change and subsidence
% written by agt 1/26/2016

clear all
figure(1)
clf
global Gm I0 Ik k 

%% initialize

% constants
sub = 0.002; %subsidence rate (m) 
Gm = 0.014; %max growth rate of coral (m)
I0 = 2000; %surface light intensity (uE m-2 s-1)
Ik = 100; %saturating light intensity (uE m-2 s-1)
k = 0.1; %extinction coefficient (m-1)

% set up time array
tmax = 100000; %number of years program will run for
dt = 100;
t = 0:dt:tmax;

%set up distance array
xmax = 20000; %m
dx = 5;
x = 0:dx:xmax;

% initial profile
S = 0.03; %slope of bedrock
bmax = 50+(sub*tmax); %finds depth bedrock subsides to so that it will stay in the frame of the model
b = bmax - S*x; %bedrock profile
b0=b; %saves initial bedrock profile
Tc = zeros(size(x)); %initial thickness of coral
h = b+Tc; %height of ground relative to msl (which is zero)
floor = ones(1,length(x)).*-800; %ocean floor

% sea level
msl = zeros(1,length(x)); %mean sea level, zero m
sl = zeros(1,length(x)); %initial current sea level 
a = 30; %amplitude of sea level change (m)
pyears = 10000; %years of period of sea level change
p = pyears; %period of sea level change

%% data 

%load data file
load pleist_del18O_copy.txt
age_data = pleist_del18O_copy(:,1); %age column
d18O_data = pleist_del18O_copy(:,2); %d18O column

%convert d18O to sea level
age0 = age_data*1000; %convert age column from kyears to years
age=flipud(age0); %flip ages so it goes from past to present
rangeO = range(d18O_data); %range of isotope data 
scaled = (d18O_data./rangeO) - min(d18O_data./rangeO); %scales d18O data from 0-1
sl0 = (scaled.*(-120)); %scales data to -120m, approx what it actually was

imax = length(t);
nplots = 100; %show 100 plots
tplot = tmax/nplots; %amount of time between plots

%% run

for i = 1:imax

    %iterate bedrock height
    b = b-(sub*dt); %decreasing bedrock height
   
    %iterate sea level
    sl = (interp1(age,sl0,t(i)))*ones(1,length(x)); %pulls interpolated sl from data, makes it an array
    s = sl - msl; %current sea level relative to msl
    h = b+Tc; %height of ground relative to msl
    d = s-h; %depth of coral relative to current sea level
    
    %iterate coral growth and height
    dTcdt = growth(d); %growth rate of coral
    dTcdt(d<=0)=0; %prevents coral from growing above water
    Tc = Tc + (dTcdt*dt); %height of coral   
        
    if(rem(t(i),tplot)==0)
        figure(1)       
        plot(x/1000,msl,'c','linewidth',2) %plot mean sea level
        hold on
        X=[x/1000,fliplr(x/1000)];
        SL=[sl,fliplr(h)];
        fill(X,SL,'b') %fills ocean
        H=[h,fliplr(b)];
        fill(X,H,'r') %fills coral
        B=[b,fliplr(floor)];
        fill(X,B,'k') %fills bedrock
        axis([0 xmax/1000 min(b0)-(sub*tmax) 150])
        xlabel('Distance (km)','fontname','arial','fontsize', 21)
        ylabel('Depth (m)', 'fontname', 'arial', 'fontsize', 21)
        set(gca, 'fontsize', 18, 'fontname', 'arial') 
        time=num2str(t(i)); %convert time of each plot to 'letters'
        timetext=strcat(time,' years'); %add years to the time
        text(15,80,timetext,'fontsize',14) %shows time on each plot
        pause(0.1)
        hold off
    end

end



