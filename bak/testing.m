figure(1);
% ab = [mean_x,mean_y]*rotation_matrix;
% rot_x = ab(:,1);
% rot_y = ab(:,2);

plot(scale_norm_x,scale_norm_y);
hold on;
%plot(mean_x,mean_y,'rx');
%plot(rot_x,rot_y,'gx');
plot(norm_x,norm_y);
axis([-.7 .7 -.7 .7]);
grid on;
