%function 
close all;
clear;

%% cost funcs 
% klPenalty = 3;
opts.plot = 0;
opts.savegif = 0;
egName = 'ot';
opts.funcL = @(rho,m) sum(m.^2,3)./(rho);
opts.gradLrho = @(rho,m) -sum(m.^2,3)./(rho.^2);
opts.gradLm = @(rho,m) 2*m./rho; 
opts.funcF = @(rho) zeros(size(rho));
opts.gradF = @(rho) zeros(size(rho));

maxits = [497,949,1887,3755];
% opts.maxit = 5000;
opts.tol = 1e-5;
opts.stepsize0 = 1;
opts.stepmodif = 0.5;
opts.submaxit = 5;

%% refine both
for i = 1:4
    %% mesh
    % meshName = 'euc_equ_reg24';
    opts.nt = 4*2^i;
    dt = 1/opts.nt;
    meshsize = 8*2.^i;
    meshName = ['euc_equ_reg',num2str(meshsize)];
    load(['../Data/',meshName,'.mat'],'surf');

    nPt = size(surf.pt,1);
    nTrg = size(surf.trg,1);
    surf = surfOperators(surf);

    %% init and term densities
    aroundpt = getaroundpt(surf.pt,surf.trg);
    rho0 = surf.pt(:,1) + 0.5;
    rho1 = ones(nPt,1);

    %% FISTA
    opts.maxit = maxits(i);
    tic;
    [rho, flux, output] = mfpMfFista(surf,rho0,rho1,opts);
    % [rho, flux, output] = mfgMfFista(surf,rho0,opts);
    toc;
    save(['results/',meshName,'_nt',num2str(opts.nt),'_mfp']);        

    %% compare with truth
    W2sq_true = 1/120;
    W2sqerr = abs(output.objArray(end)-W2sq_true);
    
    t = linspace(0,1,opts.nt+1);    
    x = surf.pt(:,1);
    sqrtterm = sqrt(2.*x.*t + (0.5*t-1).^2);
    rho_true = (sqrtterm + t-1)./(t.*sqrtterm);
    rho_true(:,1) = rho0; 
    rho_true(:,end) = rho1;
    rhoerr = abs(rho-rho_true);
    rhoerr_l2 = sqrt(sum(rhoerr.^2.*surf.ptArea,'all')*dt);
    rhoerr_l1 = sum(rhoerr.*surf.ptArea,'all')*dt;
    
    t = linspace(dt,1-dt,opts.nt);
    x = surf.trgCenter(:,1);
    sqrtterm = sqrt(2.*x.*t + (0.5*t-1).^2);
    flux_true = zeros(nTrg,opts.nt,3);
    flux_true(:,:,1) = x./(t.^2) - (3-t)./(2*t.^3).*sqrtterm - (t-1).*(t.^2-4)./(8*t.^3)./sqrtterm - (3*t-4)./(2*t.^3);
    fluxerr = abs(flux-flux_true);
    fluxerr_l2 = sqrt(sum(fluxerr.^2.*surf.trgArea,'all')*dt);
    fluxerr_l1 = sum(fluxerr.*surf.trgArea,'all')*dt;
    
    save(['results/',meshName,'_nt',num2str(opts.nt),'_mfp']);
    
end

%%
clear
nt_list = zeros(4,1);
nx_list = zeros(4,1);
W2sqerr_list = zeros(4,1);
rhoerr_l1_list = zeros(4,1);
rhoerr_l2_list = zeros(4,1);
fluxerr_l1_list = zeros(4,1);
fluxerr_l2_list = zeros(4,1);

for i = 1:4
    %% mesh
    % meshName = 'euc_equ_reg24';
    nt = 4*2^i;
    meshsize = 8*2.^i;
    meshName = ['euc_equ_reg',num2str(meshsize)];
    
    load(['results/',meshName,'_nt',num2str(nt),'_mfp']);
    
    nt_list(i) = nt;
    nx_list(i) = meshsize;
    W2sqerr_list(i) = W2sqerr;
    rhoerr_l1_list(i) = rhoerr_l1;
    rhoerr_l2_list(i) = rhoerr_l2;
    fluxerr_l1_list(i) = fluxerr_l1;
    fluxerr_l2_list(i) = fluxerr_l2;
    
end
varerr_l2_list = sqrt(rhoerr_l2_list.^2+fluxerr_l2_list.^2);
varerr_l1_list = rhoerr_l1_list + fluxerr_l1_list;
disp('W2sqerr:'); disp(W2sqerr_list');disp('order:'); disp(log(W2sqerr_list(1:end-1)'./W2sqerr_list(2:end)')/log(2));
disp('varerr l2:'); disp(varerr_l2_list');disp('order:'); disp(log(varerr_l2_list(1:end-1)'./varerr_l2_list(2:end)')/log(2));
disp('varerr l1:'); disp(varerr_l1_list');disp('order:'); disp(log(varerr_l1_list(1:end-1)'./varerr_l1_list(2:end)')/log(2));

% disp('rhoerr l2:'); disp(rhoerr_l2_list');disp('order:'); disp(log(rhoerr_l2_list(1:end-1)'./rhoerr_l2_list(2:end)')/log(2));
% disp('rhoerr l1:'); disp(rhoerr_l1_list');disp('order:'); disp(log(rhoerr_l1_list(1:end-1)'./rhoerr_l1_list(2:end)')/log(2));
% disp('fluxerr l2:'); disp(fluxerr_l2_list');disp('order:'); disp(log(fluxerr_l2_list(1:end-1)'./fluxerr_l2_list(2:end)')/log(2));
% disp('fluxerr l1:'); disp(fluxerr_l1_list');disp('order:'); disp(log(fluxerr_l1_list(1:end-1)'./fluxerr_l1_list(2:end)')/log(2));

fig = figure;
set(gcf,'unit','centimeters','position',[10 5 15 6])

subplot(1,2,1);
set(gca,'Position',[0.1,0.2,0.35,0.7]);% left margin, lower margin, width, height
loglog(nt_list,W2sqerr_list,'ro-','linewidth',1.5,'markersize',7);
axis([6,100,0.45*10^-4,4*10^-4]);
xlabel('n','fontsize',10,'fontweight','bold');
ylabel('objective error','fontsize',10,'fontweight','bold');
% title('objective error');
% fig = gcf;
% exportgraphics(fig,'results/cvg_W2sq.eps');

subplot(1,2,2);
set(gca,'Position',[0.6,0.2,0.35,0.7]);% left margin, lower margin, width, height
loglog(nt_list,varerr_l2_list,'bs--','linewidth',1.5,'markersize',7);
axis([6,100,0.018,0.042]);
xlabel('n','fontsize',10,'fontweight','bold');
ylabel('l2 norm of variable error','fontsize',10,'fontweight','bold');
% title('variable l2 error');
exportgraphics(fig,'results/cvg.eps');


% figure;
% loglog(nt_list,rhoerr_l2_list,'b--',nt_list,rhoerr_l1_list,'b:',nt_list,fluxerr_l2_list,'r--',nt_list,fluxerr_l1_list,'r:');

save(['results/euc_cvg_',num2str(opts.maxit)],'W2sqerr_list','rhoerr_l2_list','rhoerr_l1_list','fluxerr_l2_list','fluxerr_l1_list');
