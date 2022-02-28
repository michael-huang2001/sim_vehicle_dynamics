%% plot movement of vehicle

close all;
clearvars -except SimRealState input debug logsout

%% User Input
rr = [5000 2400]; % roll rate fr re (Nm/rad)
fc = 0.5; % distance from front axle to COG (m)
rc = 0.5; % distance from rear axle to COG (m)
l = 1; % wheelbase (m)
g=9.81; % accel due to gravity (m/s^2)
W=300*g; % mass of vehicle (N)
t=1.4; % track width (m)
hz=0.5; % COG z height (m)


%% data source

   % 1: from simulation
   % 2: from script which loads data for simulink replay
   % 3: from debug file logged on vehicle; raw import with mat load 

    i_datasource = 1;

% visualization settings
    
    % timestep of simulation in seconds
    sim_timestep = 0.004;       % in s
    
    % use every i-ith data point to reduce computational load
    i = 50;
    
    % timestep where to start visualization in seconds
    t_start = 0;

    % set replay speed: if > 1, replay is faster than reality and vice versa
    replay_speed_factor = 2;


% vehicle parameters
    length_front_m = 2;
    length_total_m = 4.5;
    
    width_m = 2;
    
%% convert data from different sources 

if i_datasource == 1
    % from simulation
    dummy = logsout{1}.Values;
    VehicleData.x_m = dummy.x_m;
    VehicleData.y_m = dummy.y_m;
    VehicleData.psi_rad = dummy.psi_rad;

    VehicleData.vx_mps = dummy.vx_mps;
    VehicleData.vy_mps = dummy.vy_mps;

    VehicleData.ax_mps2 = dummy.ax_mps2;
    VehicleData.ay_mps2 = dummy.ay_mps2;

    VehicleData.phi_rad = dummy.phi_rad;
    
elseif i_datasource == 2
        
    % from script which loads data for simulink replay
    VehicleData = input{2};
    VehicleData.x_m = SimRealState.Pos.x_m;
    VehicleData.y_m = SimRealState.Pos.y_m;
    VehicleData.psi_rad = SimRealState.Pos.psi_rad;

elseif i_datasource == 2

    % from debug file logged on vehicle; raw import with mat load 
    VehicleData.x_m = debug.debug_mvdc_state_estimation_debug_StateEstimate_Pos_x_m;
    VehicleData.y_m = debug.debug_mvdc_state_estimation_debug_StateEstimate_Pos_y_m;
    VehicleData.psi_rad = debug.debug_mvdc_state_estimation_debug_StateEstimate_Pos_psi_rad;

    VehicleData.vx_mps = debug.debug_mvdc_state_estimation_debug_StateEstimate_vx_mps;
    VehicleData.vy_mps = debug.debug_mvdc_state_estimation_debug_StateEstimate_vy_mps;

    VehicleData.ax_mps2 = debug.debug_mvdc_state_estimation_debug_StateEstimate_ax_mps2;
    VehicleData.ay_mps2 = debug.debug_mvdc_state_estimation_debug_StateEstimate_ay_mps2;

end


%% get recorded data and transform for use in visualization

    time = VehicleData.x_m.Time((t_start/sim_timestep)+1:i:end);

    x_m = VehicleData.x_m.Data((t_start/sim_timestep)+1:i:end);
    y_m = VehicleData.y_m.Data((t_start/sim_timestep)+1:i:end);

    psi_rad = VehicleData.psi_rad.Data((t_start/sim_timestep)+1:i:end);

    psi_rad = normalizeAngle(psi_rad) ;

    vx_mps = VehicleData.vx_mps.Data((t_start/sim_timestep)+1:i:end);
    vy_mps = VehicleData.vy_mps.Data((t_start/sim_timestep)+1:i:end);

    ax_mps2 = VehicleData.ax_mps2.Data((t_start/sim_timestep)+1:i:end);
    ay_mps2 = VehicleData.ay_mps2.Data((t_start/sim_timestep)+1:i:end);
    
    phi_rad = VehicleData.phi_rad.Data((t_start/sim_timestep)+1:i:end);
    

    % calculate tangent to vehicle's CoG path
    diff_x_m = diff(x_m);
    diff_y_m = diff(y_m);

    heading_traj_rad = normalizeAngle(atan2(diff_y_m,diff_x_m)-pi/2);
    
    
    
%% main plotting 

fig1 = figure;

% subplot 1 (top left)
    sp1 = subplot(3,2,1);
    title('vehicle velocity')
    grid on
    
  	xlabel('time in s')
    
    % set color of both y-axes to specific values matching the plot color
    ax_sp1 = gca;
  	yyaxis left
 	ax_sp1.YColor = [0, 0.4470, 0.7410];

    h1 = animatedline('Color',	[0, 0.4470, 0.7410]);
    ylabel('x-velocity in m/s')

    yyaxis right
    ax_sp1.YColor = [0.8500, 0.3250, 0.0980];

    h11 = animatedline('Color',	[0.8500, 0.3250, 0.0980]);
    ylabel('y-velocity in m/s')

    
% subplot 3 (middle left)
    sp3 = subplot(3,2,3);
    title('vehicle acceleration')
  	grid on

    h31 = animatedline('Color',	[0, 0.4470, 0.7410]);
    h32 = animatedline('Color',	[0.8500, 0.3250, 0.0980]);
    
    xlabel('time in s')
    ylabel('acceleration in m/s^2')
    
    legend('ax','ay')
    
% subplot 6 (bottom right)
    sp6 = subplot(3,2,6);
    title('Normal Force on each wheel')
  	grid on
    
    h61 = animatedline('Color',	[0, 0.4470, 0.7410]); %fr
    h62 = animatedline('Color',	[0.8500, 0.3250, 0.0980]); %fl
    h63 = animatedline('Color',	[1, 0, 1]); %rr
    h64 = animatedline('Color', [0, 0, 1]); %rl
    h65 = animatedline('Color', [0, 1, 1]); %sum
    
    xlabel('time in s')
    ylabel('normal force in N')
    
    legend('Front Right', 'Front Left', 'Rear Right', 'Rear Left', 'sanity check')
    
    
% subplot 5 (bottom left)
    sp5 = subplot(3,2,5);
    title('vehicle location - global')

    xlabel('x-coordinate in m')
    ylabel('y-coordinate in m')

    xlim([min(x_m)-10,max(x_m)+10])
    ylim([min(y_m)-10,max(y_m)+10])

    hold on 
    axis equal

    h5 = animatedline;

    plot(x_m(1),y_m(1),'+')
    
    
% subplot right side (subplot no. 2,4,6)
    sp24 = subplot(3,2,[2 4]);
    title('vehicle location - local')

    xlabel('x-coordinate in m')
    ylabel('y-coordinate in m')

    xlim([x_m(1)-50,x_m(1)+50])
    ylim([y_m(1)-50,y_m(1)+50])
    hold on 
    axis equal

    h24 = animatedline;

    plot(x_m(1),y_m(1),'+')

    R = [cos(psi_rad) -sin(psi_rad) ;sin(psi_rad) cos(psi_rad)] ;

    g_veh = hgtransform;
    x = [-width_m/2 0 width_m/2 ];
    y = [length_front_m-length_total_m length_front_m length_front_m-length_total_m];
    vehicle_arrow = patch(x,y,'red');
    set(vehicle_arrow,'Parent',g_veh)

    g_head = hgtransform;
    heading_line = patch([0 0 0],[0 20 NaN],[0 0 0],'EdgeColor','red');
    set(heading_line,'Parent',g_head)

    g_traj_tangent = hgtransform;
    tangent_traj = patch([0 0 0],[0 20 NaN],[0 0 0],'EdgeColor','black');
    set(tangent_traj,'Parent',g_traj_tangent)
    
    
    h = zeros(2, 1);
    h(1) = plot(0,0,'r');
    h(2) = plot(0,0,'k');
    legend([h(1) h(2)], {'vehicle heading',"tangent to vehicle's CoG path"});

    
% for loop which updates every subplot
for timestep=1:size(time,1)-1

   	trans = makehgtform('translate',[x_m(timestep),y_m(timestep),0]);
    rotz = makehgtform('zrotate',psi_rad(timestep));
    
  	rotz_tangent = makehgtform('zrotate',heading_traj_rad(timestep));
    
    % update subplot 1
    sp1;
    
  	addpoints(h1,time(timestep), vx_mps(timestep));
  	addpoints(h11,time(timestep), vy_mps(timestep));

    % update subplot 3
    sp3;
    
  	addpoints(h31,time(timestep), ax_mps2(timestep));
  	addpoints(h32,time(timestep), ay_mps2(timestep));

    % update subplot 6
    sp6;
    
    % front right
    addpoints(h61,time(timestep), W/4+(ay_mps2(timestep)*W/(g*2*t))*hz*((rr(1)+W*hz*(fc)/l)/(rr(1)+rr(2)-W*hz))-ax_mps2(timestep)*W/(2*l*g));
    % front left
    addpoints(h62,time(timestep), W/4-(ay_mps2(timestep)*W/(g*2*t))*hz*((rr(1)+W*hz*(fc)/l)/(rr(1)+rr(2)-W*hz))-ax_mps2(timestep)*W/(2*l*g));
    % rear right
    addpoints(h63,time(timestep), W/4+(ay_mps2(timestep)*W/(g*2*t))*hz*((rr(2)+W*hz*(rc)/l)/(rr(1)+rr(2)-W*hz))+ax_mps2(timestep)*W/(2*l*g));
    % rear left
    addpoints(h64,time(timestep), W/4-(ay_mps2(timestep)*W/(g*2*t))*hz*((rr(2)+W*hz*(rc)/l)/(rr(1)+rr(2)-W*hz))+ax_mps2(timestep)*W/(2*l*g));
    % sum
    addpoints(h65, time(timestep), W-(ay_mps2(timestep)*W/(g*2*t))*hz*((rr(1)+W*hz*(fc)/l)/(rr(1)+rr(2)-W*hz))-ax_mps2(timestep)*W/(2*l*g) ...
        +(ay_mps2(timestep)*W/(g*2*t))*hz*((rr(1)+W*hz*(fc)/l)/(rr(1)+rr(2)-W*hz))-ax_mps2(timestep)*W/(2*l*g)...
        -(ay_mps2(timestep)*W/(g*2*t))*hz*((rr(2)+W*hz*(rc)/l)/(rr(1)+rr(2)-W*hz))+ax_mps2(timestep)*W/(2*l*g)...
        +(ay_mps2(timestep)*W/(g*2*t))*hz*((rr(2)+W*hz*(rc)/l)/(rr(1)+rr(2)-W*hz))+ax_mps2(timestep)*W/(2*l*g))
    
    % update subplot 5
    sp5;
    
    addpoints(h5,x_m(timestep), y_m(timestep));
    
    % update subplot 24
  	sp24;
    
    xlim([x_m(timestep)-50,x_m(timestep)+50])
    ylim([y_m(timestep)-50,y_m(timestep)+50])
   
    set(g_veh,'Matrix',trans*rotz)
    set(g_head,'Matrix',trans*rotz)

    set(g_traj_tangent,'Matrix',trans*rotz_tangent)

    addpoints(h24,x_m(timestep), y_m(timestep));
    
    
    
    % update plot
    drawnow
    % pause to match specified visualization speed
    pause((sim_timestep*i)/replay_speed_factor)
    
end
