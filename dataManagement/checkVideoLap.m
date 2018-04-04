idx = 1200:3000;
stop = 2239;
lc = 2495;
figure(1)
plot(WLE{idx,3},WLE{idx,4},'bx');
text(WLE{stop,3},WLE{stop,4},num2str(WLE{stop,1}), ...
      'Color','r');
text(WLE{lc,3},WLE{lc,4},num2str(WLE{lc,1}), ...
      'Color','r');
plot_google_map('mapType','satellite')