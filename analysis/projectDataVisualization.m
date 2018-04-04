figure(1);
plot(GPS_data(:,1),GPS_data(:,2),'LineWidth',3);
hold on;
grid on;
text(GPS_data([1 end],1),GPS_data([1 end],2),{'Start','End'},'Color','r')
hold off;
plot_google_map('mapType','roadmap');
figure(2);
plot(scale_norm_x,scale_norm_y,'LineWidth',3);
hold on;
grid on;
text(scale_norm_x([1 end]),scale_norm_y([1 end]),{'Start','End'},'Color','r')
plot(norm_x,norm_y,'--','LineWidth',3);
text(norm_x([1 end]),norm_y([1 end]),{'Start','End'},'Color','r')
axis([- 0.4 0.4 -0.4 0.4]);
legend('scaled-UTM','orientation normalized');
hold off;
%% data visualization
%PCA
x = trainTestSet.input;
y = trainTestSet.target;
y1 = trainTestSet.y;

%x = (x'-mean(x'))./max(abs(x'));
covX = cov(x');
[U,V,lambda] = eig(covX);
visualV = max(V);
explained = visualV/sum(visualV)*100;
X= x'*(U(:,end-2:end));
%% data visualization
figure(1);
char_plot = 'xodvs';
for i = 1:length(unique(y1))
       %plot(X(y1==i,1),X(y1==i,2),char_plot(i));hold on;
       plot3(X(y1==i,1),X(y1==i,2),X(y1==i,3),char_plot(i));hold on;
end
legend({'left lane change','right lane change','left turn','right turn','goStraight'}, ...
    'Location','southeast');
grid on;
hold off;
%% plot explained variance

figure(1);
rangePlot = 70;
barh(1:rangePlot,explained(end-rangePlot+1:end),'r'); grid on;
axis([0 18 0 rangePlot])
h = gca;
set(h,'YMinorGrid','on');
colormap(cool)
xlabel('Variance explained percentage')
ylabel('PCA components')
%% 2 layers increasing 2nd layer hidden nodes
no_ = [0.6354 0.6069 0.6028 0.6435];
yes_ = [0.6606  0.6708 0.6647 0.6471];
figure(1);
plot(no_,'-x','LineWidth',2); hold on;
plot(yes_,'-o','LineWidth',2);hold off;
grid on;
axis([1 4 0.4 0.7]);
h = gca;
h.XTick = 1:4;
h.XTickLabel = {'5-5','10-5','15-5','20-5'};
xlabel('# of hidden-nodes in 2 hidden-layer');
ylabel('10-fold validation accuracy');
legend({'w/o feature extraction','with feature extraction'},'Location','southeast');

%% 2 layers increasing 1st layer hidden nodes
no_ = [0.6354 0.6354 0.5836 0.5822];
yes_ = [0.6606  0.6480 0.6382 0.6113];
figure(1);
plot(no_,'-x','LineWidth',2); hold on;
plot(yes_,'-o','LineWidth',2);hold off;
grid on;
axis([1 4 0.4 0.7]);
h = gca;
h.XTick = 1:4;
h.XTickLabel = {'5-5','5-10','5-15','5-20'};
xlabel('# of hidden-nodes in 2 hidden-layer');
ylabel('10-fold validation accuracy');
legend({'w/o feature extraction','with feature extraction'},'Location','southeast');
%% 1 layer increasing hidden nodes
no_ = [0.6269 0.6182 0.6367 0.6830 0.6714 0.6608 ];
yes_ = [0.6762 0.6762 0.7112 0.6920 0.6920 0.6562 ];
figure(1);
plot(no_,'-x','LineWidth',2); hold on;
plot(yes_,'-o','LineWidth',2);hold off;
grid on;
axis([1 6 0.4 0.72]);
h = gca;
h.XTick = 1:7;
h.XTickLabel = {'5','10','15','20','25','30'};
xlabel('# of hidden-nodes');
ylabel('10-fold validation accuracy');
legend({'w/o feature extraction','with feature extraction'},'Location','southeast');
%% 1 layer increasing hidden nodes w/ w/o orientation invariant (no feature extraction)
no_ = [0.5550 0.5887 0.6680 0.6706 0.6378 0.6330];
yes_ = [0.6384 0.6578 0.6752 0.6502 0.6971 0.6947];
figure(1);
plot(no_,'-x','LineWidth',2); hold on;
plot(yes_,'-o','LineWidth',2);hold off;
grid on;
axis([1 6 0.4 0.72]);
h = gca;
h.XTick = 1:6;
h.XTickLabel = {'5','10','15','20','25','30'};
xlabel('# of hidden-nodes');
ylabel('10-fold validation accuracy');
legend({'w/o orientation invariant','with orientation invariant'},'Location','southeast');

%% 1 layer increasing hidden nodes w/ w/o orientation invariant (with feature extraction)
no_ = [0.6343 0.6517 0.6432 0.6754 0.6554 0.6287];
yes_ = [0.6762 0.6762 0.7112 0.6920 0.6920 0.6562];
figure(1);
plot(no_,'-x','LineWidth',2); hold on;
plot(yes_,'-o','LineWidth',2);hold off;
grid on;
axis([1 6 0.4 0.72]);
h = gca;
h.XTick = 1:6;
h.XTickLabel = {'5','10','15','20','25','30'};
xlabel('# of hidden-nodes');
ylabel('10-fold validation accuracy');
legend({'w/o orientation invariant','with orientation invariant'},'Location','southeast');








