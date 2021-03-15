function refls= RCWA_Silicon(height, gap, period, diameter, acc, stepcase, show1)
    wave = 380:5:780;
    trans=[];
    refls =[];
    radius=diameter/2;
    medium=0;
    shape=0;
    
    parfor i = 1:length(wave)
        wavelength=wave(i);
        addpath('./RCWA/RETICOLO V8/reticolo_allege')

        [prv,vmax]=retio([],inf*1i); % never write on the disc (nod to do retio)
        Si3N4_data = load('./RCWA/Si3N4_new.mat');
        Si_data = load('./RCWA/Si.mat');
        WL_SiN = Si3N4_data.WL_SiN;
        R_SiN = Si3N4_data.R_SiN;
        WL = Si_data.WL;
        R = Si_data.R;
        I = Si_data.I;
        
        n_Si = interp1(WL, R, wavelength)+1i*interp1(WL, I, wavelength);
        n_SiN =interp1(WL_SiN, R_SiN, wavelength)+1i*0;
        periods = [period,period];% same unit as wavelength
        n_air = 1;% refractive index of the top layer
        n_glass = 1.5;% refractive index of the bottom layer
        angle_theta = 0;
        k_parallel = n_air*sin(angle_theta*pi/180);
        angle_delta = 0;
        parm = res0; % default parameters for "parm"
        parm.sym.pol = 1; % TE
        parm.res1.champ = 1; % the eletromagnetic field is calculated accurately
        parm.sym.x=0;parm.sym.y=0;% use of symetry

        if i == 1
            parm.res1.trace=1; %show the refractive index distribution
        else
            parm.res1.trace=0; 
        end

        nn=[acc,acc];
        % textures for all layers including the top and bottom
        textures = cell(1,5);
        textures{1}= n_air; % uniform texture
        textures{2}= n_air; % uniform texture
        textures{3}={n_air,[gap/2,gap/2,diameter,diameter,n_Si,stepcase],[-gap/2,gap/2,diameter,diameter,n_Si,stepcase],[gap/2,-gap/2,diameter,diameter,n_Si,stepcase],[-gap/2,-gap/2,diameter,diameter,n_Si,stepcase]};
        % textures{3} = {n_air, [0, 0, diameter, 100, n_Si, stepcase]};
        textures{4}=n_SiN;
        textures{5}=n_Si;
        aa=res1(wavelength,periods,textures,nn,k_parallel,angle_delta,parm);

        profile={[200,height,70,90000,0],[1,3,4,5,2]}; % how many layers and its corresponding refractive index

        two_D=res2(aa,profile);
        n_order = size(two_D.TEinc_top_transmitted.efficiency_TE,1);
        trans(i) = sum(two_D.TEinc_top_transmitted.efficiency_TE); % sum over all orders 
        refls(i) = sum(two_D.TEinc_top_reflected.efficiency_TE);
        %two_D.TEinc_top_reflected.order  % gives the information of order
        %trans(i) =two_D.TEinc_top_transmitted.efficiency_TE((n_order+1)/2,1) % only contain the 0 order 
        %refls(i) = two_D.TEinc_top_reflected.efficiency_TE((n_order+1)/2,1);
        %refls(((9-n_order)/2+1):((9+n_order)/2),i)=two_D.TEinc_top_reflected.efficiency_TE;
    end
    if show1==1
        plot(wave, trans, wave, refls)
        xlabel('Wavelength/(nm)');
        ylabel('Efficiency');
        legend({'T','R'})
        saveas(gcf, 'res.png')
    end
    %save('refls.mat','refls');
end