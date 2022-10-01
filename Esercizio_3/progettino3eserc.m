% Inizializziamo il nuovo script pulendo le eventuali variabili gia
% caricate su matlab e chiudendo le eventuali finestre aperte da un altro
% script

clear; close all;

% Usiamo il comando zpk('s') per far si che la lettera 's' diventi una
% variabile speciale in modo da poter esprimere il nostro sitema T-C in
% modo semplice e piu intuitivo rispetto a quello di specificare i
% coefficienti polinomiali
% 
s=zpk('s');

G=(s+1)/(s*(s+1/3)^2);

% Scriviamo il controllore appena calcolato

C_s=0.5;  % come detto ho gia un polo nell'origine nella FDT e 
               % non devo aggiungere un integratore

% Vediamo innanzitutto con solo l’aggiunta del controllore quanto vale
% il margine di fase e la pulsazione di attraversamento
               
L_old=series(C_s,G);

margin(L_old);

%attuo la strategia 

delta_cr=smorz_S(0.25);   % 0.4037 quindi phim deve essere >40.37° per S<0.25  
                                       % questo vale perche il margine di fase e lo 
                                       % smorzamento fino a circa 70 gradi sono approssimabili
                                       % dalla relazione phim = smorz*100  
                                       
                   

wn_cr=3/(70*delta_cr);              %0.1062

w_BW=wBwn(delta_cr)*wn_cr;    %0.1456

wc_new=1.5;        % scelgo una wc grande rispetto w_Bw (se ne scelgo una a ridosso 
                           % non va bene in quanto mi rimane il polo negativo con
                           % la prima rete anticipatrice)

[modulo,argomento]=bode(L_old,wc_new); %modulo 0.2545<1, argomento -188.63°

m=1/modulo; 

distanza=180-abs(argomento); % -8.62° < 50(phi_m);    devo amplificare e attenuare --> uso una rete anticipatrice

theta=50-(180-abs(argomento)); %ho fatto diverse approssimazioni e non bastano 
                                               %piu i gradi a ridosso dei 40.37 aumento 
                                               %fino a 50 per abbassare la massima sovraelongazione

[tauz,taup]=generica(wc_new,m,theta);

C_lead=(1+s*tauz)/(1+s*taup);

C=series(C_s,C_lead);

L=series(C,G);

margin(L);

[zero,polo,guadagno]=zpkdata(C_lead,'v');


