function [norm_x,norm_y]=rotate2Ori(scale_norm_x,scale_norm_y,segAngle)
% perform rotation on the event segment

% rotation matrix
% rotation_matrix =     [cos(theta) sin(theta);
%                        -sin(theta) cos(theta)]
if segAngle>=0 && segAngle<pi/2
    rot_Angle = pi/2-segAngle;
elseif segAngle>pi/2 && segAngle<=pi
    rot_Angle = -segAngle+pi/2;
elseif segAngle<0 && segAngle>=-pi
    rot_Angle = pi/2-segAngle;
end

rotation_matrix = [cos(rot_Angle) sin(rot_Angle);
                    -sin(rot_Angle) cos(rot_Angle)];
                
norm_xy = [scale_norm_x scale_norm_y]*rotation_matrix;
norm_x = norm_xy(:,1);
norm_y = norm_xy(:,2);

end