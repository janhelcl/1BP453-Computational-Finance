function value = getOptionVal(S, K, r, T, sigma, w, N, modelName)
% w: w=1 -> call opce, w=-1 put opce
% K: realizacni cena opce

dt = T/N;
[p, u, d] = getParameters(modelName, r, sigma, dt);

stockTree = getStockTree(S, u, d, N);
optionTree = getOptionTree(stockTree, w, K, p, exp(-r*dt), N);
value = optionTree(end, 1);
end

function optionTree = getOptionTree(stockTree, w, K, p, disc, N)

optionTree = 0*stockTree;

optionTree(:, end) = getPayoff(stockTree(:,end) ,K, w);

for i = N-1:-1:0
    for j = 0:i
        optionTree(N+1- j,i +1) = disc*(p*optionTree(N+1- j-1,i +2) + (1-p)*optionTree(N+1- j,i +2));
    end
end

end

function payoff = getPayoff(ST, K, w)

payoff = max((ST-K)*w,0);

end

function stockTree = getStockTree(S, u, d, N)
% funkce vytvari strom (matici) hodnot podkladu Si,j

stockTree = zeros(N+1, N+1);

for i = 0:N % iterujeme pres vsechny casy
    for j = 0:i % iterujeme pres posuny nahoru
        stockTree(N+1- j,i +1) = S*u^j*d^(i-j); % Si,j
    end
end


end


function [p, u, d] = getParameters(modelName, r, sigma, dt)
% funkce vraci parametry:
% p: pravdepodobnost narustu (pst. poklesu je 1-p )
% u: koeficient narustu
% d: koeficient poklesu

if strcmpi(modelName, 'CRR') % jedna se o model Cox-Ross-Rubinstein 1979
    u = exp(sigma*sqrt(dt));
    d = 1/u; % d = exp(-sigma*sqrt(dt))
    p = (exp(r*dt)-d)/(u-d);
elseif strcmpi(modelName, 'JR') % jedna se o model Jarrow-Rudd
    u = exp((r-0.5*sigma^2)*dt + sigma*sqrt(dt));
    d = exp((r-0.5*sigma^2)*dt - sigma*sqrt(dt));
    p = 0.5;
else % model nebyl identifikovan
    warning('neznamy model, jedu CRR');
    [p, u, d] = getParameters('CRR', r, sigma, dt); % rekurzivni fce
end

end