function [r_out_cont,r_out, h_cell,bias_cell]=Real_EBP_minibatch( x_in,d_in,enable,K,h0_cell,bias0_cell,eta,sigma_w,dropout,batch_size)
% EBP algorithm for multilayer neural network with continuous (real) weights with minibatch and dropout options
% x_in - TxM input, where T- time length (number of patterns to generate)
% d- TxN label
% enable -  Tx1 "enable training" flag, 
% K - an L+1 - long vector, with the l-th component being the width of the l-th layer, and L - the number of layers
% h0_cell - initial hidden weights of network
% bias0_cell - initial biases of network
% eta - "bogus" learning rate for testing purposes. should be 1
% sigma_w - proportional to variance of initial weights
% dropout - use dropout on input? (0 or 1 flag)
% batch_size - mini-batch size

% outputs:
% r_out - TxN output of network EBP-D
% r_out_cont - TxN output of network with EBP-P
% h_cell - final hidden weights of network
% biases_cell - final biases of network
%% Array Sizes

T=size(x_in,1); 
if size(d_in,1)~=T
    error(' The length of "x"  and "d" should be equal!!! ' )
end

L=length(K)-1;

%% flip x,d - from row vectors to column vectors
x=x_in';
y=d_in'; 
r_out=0*d_in;
r_out_cont=0*d_in;

 %% Initialize
mean_v_prev_cell=cell(L+1,1); %myu
mean_u_cell=cell(L,1); %myu
var_u_cell=cell(L,1); % sigma^2

if isempty(h0_cell)    
    h_cell=cell(L,1); % synaptic weights for all layers
    for ll=1:L           
        h_cell(ll)={(rand(K(ll+1),K(ll))-0.5)*sqrt(sigma_w*12/K(ll))};  
    end 
else
    h_cell=h0_cell;
end

if isempty(bias0_cell)    
    bias_cell=cell(L,1); % biases for all layers
for ll=1:L           
    bias_cell(ll)={zeros(K(ll+1),1)};  %{randn(K(ll+1),1)*sqrt(1/K(ll))};  
end 
else
    bias_cell=bias0_cell;
end

%% Train
batch_size_fixed=batch_size;
time=0;

for tt=1:batch_size_fixed:T
    batch_size=min(batch_size,T-tt+1); %reduce batch size if not enough example remain
    batch_ind=tt:(tt+batch_size-1); %batch indices
    %% Forward pass
    %first layer    
    mean_v=x(:,batch_ind);
    
    h=cell2mat(h_cell(1));
    bias=cell2mat(bias_cell(1));

    mean_u= bsxfun(@plus,h*mean_v,bias)/sqrt(K(1)+1);

   if dropout   
        p_in=0.8; %dropout probability - use the 80% value from hinton
        var_input=4*p_in*(1-p_in); % variance binary +-1 bernoulli noise
        var_u = ((h*0+1)*(mean_v.^2)+h.^2*(mean_v.^2)*var_input+1)/(K(1)+1);
    else
        var_u = ((h*0+1)*(mean_v.^2)+1)/(K(1)+1);
   end      

    p_v=normcdf(mean_u./sqrt(var_u),0,1);
    mean_u_cell(1)={mean_u};
    var_u_cell(1)={var_u};
    mean_v_prev_cell(1)={mean_v};

    mean_v=2*p_v-1;
    mean_v_prev_cell(2)={mean_v};
    
    %other layers
    for ll=2:L   
            h=cell2mat(h_cell(ll));
            bias=cell2mat(bias_cell(ll));
            
            mean_u= bsxfun(@plus,h*mean_v,bias)/sqrt(K(ll)+1);
            var_u = 1+ ( (h.^2)*(1-mean_v.^2)+1)/(K(ll)+1);

            p_v=normcdf(mean_u./sqrt(var_u),0,1);
            mean_u_cell(ll)={mean_u};
            var_u_cell(ll)={var_u};
            
            mean_v=2*p_v-1;
            mean_v_prev_cell(ll+1)={mean_v};
    end    
    
    %output
    
    % probabilistic output
    r_out_cont(batch_ind,:)=mean_v';
    
    %determinstic output
    v=x(:,batch_ind);
    for ll=1:L-1
        h=cell2mat(h_cell(ll));
        bias=cell2mat(bias_cell(ll));
        v=sign(bsxfun(@plus,h*v,bias));
    end
    
    h=cell2mat(h_cell(L));
    bias=cell2mat(bias_cell(L));
    v=bsxfun(@plus,h*v,bias);
    
    r_out(batch_ind,:)=v';
    %% Backward pass

    if  enable==1
     for ll=L:-1:1
        mean_v_prev=cell2mat(mean_v_prev_cell(ll));
        mean_u=cell2mat(mean_u_cell(ll));
        var_u=cell2mat(var_u_cell(ll));
        
        if ll==L
            Y=y(:,batch_ind);
            
            delta=2*Y.*(normpdf(0,mean_u,sqrt(var_u))./normcdf(0,-Y.*mean_u,sqrt(var_u)))/sqrt(K(ll)+1);
            
%        ind=isnan(delta);
           ind=~isfinite(delta); % break: sum(sum(ind))>0
           delta(ind)=-2*((Y(ind).*mean_u(ind))<0).*(mean_u(ind)./var_u(ind))/sqrt(K(ll)+1); 
        else            
            delta_next=delta; 
            h_next=cell2mat(h_cell(ll+1));  
            G= 2*normpdf(0,mean_u,sqrt(var_u))/sqrt(K(ll)+1);
            delta=((h_next.')*delta_next).*G;            
        end  
        
            h=cell2mat(h_cell(ll));
            bias=cell2mat(bias_cell(ll));
            h=h+0.5*eta*delta*mean_v_prev.'; 
            h_cell(ll,1)={h};  %break: sum(isnan(r_out(tt,:)))>0
            bias=bias+0.5*eta*sum(delta,2);
            bias_cell(ll,1)={bias};
     end 
     
    elseif  enable==0
    else 
        error(' enable input must be 0 or 1')
    end
    
    ratio=0.01; %show every 1% complete
    temp=ratio*floor(tt/T/ratio);
    if  temp>time
        time=temp;
        disp([num2str(100*temp) '% complete'])        
    end
    
    
end


  %output
end