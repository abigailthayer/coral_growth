function  dTcdt = growth(d)

global Gm I0 Ik k 

dTcdt = Gm*tanh((I0*exp(-k*d))/(Ik)); %change in growth rate

end
