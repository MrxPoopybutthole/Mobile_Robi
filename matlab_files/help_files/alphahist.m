function [alpha] = alphahist(xy, old_alpha, k)
    
   alphas = atan2d((xy(1+k:end, 2) - xy(1:end-k, 2)), ...
       (xy(1+k:end, 1) - xy(1:end-k, 1)));
    alphas = -alphas;
   %alphas = mod(alphas + 360, 360);
%    tolerance = 2;
%    alphas(abs(alphas - 180) < tolerance) = 0;
   [N, edges] = histcounts(alphas, -180:5:180);
   old_alpha_index = round((old_alpha+180)/5);
   shift_index = 36-old_alpha_index;
   N = circshift(N, shift_index);
    
   indis = 36-4:36+4;

   sum_N_used = sum(N(indis));
   %disp(sum_N_used);
   if sum_N_used < 10
       N = circshift(N, 36);
   end
   N_used = N(indis);
   sum_N_used = sum(N_used);
   %disp(sum_N_used);
   edges_used = edges(indis) + 2.5;
   if sum_N_used < 10
       alpha = old_alpha;
   else
       alpha = sum(N_used.*edges_used)/sum_N_used - (shift_index*5);
       if(alpha > 180) 
           alpha = -180 + mod(alpha, 180);
       elseif (alpha < -180)
           alpha = 180 + mod(alpha, -180);
       end
   end
   figure(2);
   %Histogramm plotten
   histogram(alphas, -180:5:180);
   title("Histogramm der Alphas")
   xlabel("Alpha")
   ylabel("Häufigkeit")
end