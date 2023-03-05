global F;
F=struct('cdata',zeros(343,434,3,'uint8'),'colormap',[]); %poèetna struktura za spremanje slika
set_param('sustav/Ulaz','After',num2str(1)); %postavljanje ulaza u simulaciji na 1


postavke = optimoptions ('ga',...
    "CreationFcn",'gacreationlinearfeasible',...
    "MutationFcn",'mutationadaptfeasible',...
    "MaxGenerations",60,...
    "MaxStallGenerations",10,...
    "FunctionTolerance",0.001,...
    "PopulationSize",40,...
    "EliteCount",3);

% rezulti su dobiveni sa opcijama:"CreationFcn",'gacreationuniform',... i %"MutationFcn",'mutationgaussian',...
% sa "InitialPopulationRange",[0;10],... ,a bez linearnih ogranièenja: -eye(3),zeros(3,1)
% koje se postave na [].

tic %mjerenje vremena
[x,fval] = ga(@(parametri)pid(parametri),3,-eye(3),zeros(3,1),[],[],0,30,[],postavke);
toc

%pravljenje videa iz slika odziva nakon svake iteracije
writerObj = VideoWriter('Iteracije.avi');
writerObj.FrameRate = 15;
open(writerObj);
for j=1:length(F)
    frame = F(j);    
    writeVideo(writerObj, frame);
end
close(writerObj);
%%
function Enorm = pid (parametri)

P=parametri(1);
I=parametri(2);
D=parametri(3);

%postavljanje novo dobivenih parametara u simulaciju
set_param('sustav/PID Controller','P',num2str(P));
set_param('sustav/PID Controller','I',num2str(I));
set_param('sustav/PID Controller','D',num2str(D));

%simulacija
sim('sustav')

%racunanje greške
E = abs(e.signals.values);
T=t.signals.values;

% dodavanje težine vremena
Et = T.*E;

%raèunanje integrala trapeznim pravilom
v = cumtrapz(t.signals.values, Et);
J1=v(end);

%izlaz iz funkcije
Enorm = J1;

% greška se može proraèunati formulom 'J' tj ,njenim integralom ,takoðer se
% mogu uvesti ogranièenja ,npr s.Overshoot <5.0 (%)
%s=stepinfo(y.signals.values,t.signals.values);
%alfa=0.6;
%beta=0.3;
%gama=0.1;
%Ed=gradient(E);
%J= alfa*E+beta*Ed+gama*gradient(Ed);


%crtanje odziva i spremanje u strukturu 'F' za video
plot(t.signals.values,y.signals.values,'b','Linewidth',2)
axis([0 10 0 1.3]);
grid on
title('Evolucija parametara PID regulatora iz genetièkog algoritma')
xlabel('Vrijeme[s]')
ylabel('Amplituda')
persistent i
if isempty(i)
  i = 1;
end
global F;
F(i)=getframe(gcf);
i=i+1;

end