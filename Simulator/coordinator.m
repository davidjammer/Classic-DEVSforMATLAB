classdef coordinator < handle
    properties
  	   parent  %parent coordinator
       name
       tl      %time of last event
       tn      %time of next event

       D       %children
       I       %couplings

       IC      %internal coupling
       EIC     %external to internal coupling
       IEC     %internal to external coupling

       Select

       eventlist
       receivers
       IMM     %imminent children
       mail    %output mail bag
       yparent %output message bag for parent
       dstar

       debug_level = get_debug_level();
       epsilon = get_epsilon;

    end

    methods
  	   %% constructor
       function obj = coordinator(name)
  		  obj.name = name;
          obj.D = {};
          obj.eventlist = [];
          obj.Select = [];
          obj.mail = [];
          obj.I = [];
          obj.IC = [];
          obj.EIC = [];
          obj.IEC = [];
          obj.receivers=[];
       end
       %% copy methods
       function mdl=copy(obj,name)
  		  mdl = coordinator(obj.get_name);

          prop = properties(obj);
          nprop = numel(prop);

          for k=1:nprop
  			 if strcmp(prop{k},"parent")

             elseif strcmp(prop{k},"D")
  				for kk=1:numel(obj.D)
                    mdl.add_model(obj.D{kk}.copy(obj.D{kk}.get_name()));
                end
             elseif strcmp(prop{k},"name")
  				mdl.name = name;
             else
  				mdl.(prop{k}) = obj.(prop{k});
             end
          end

          for k=1:numel(mdl.I)
  			 if strcmp(mdl.I(k).from_mdl,obj.name)
  				mdl.I(k).from_mdl = mdl.name;
             end
             if strcmp(mdl.I(k).to_mdl,obj.name)
  				mdl.I(k).to_mdl = mdl.name;
             end
          end
          for k=1:numel(mdl.EIC)
  			 if strcmp(mdl.EIC(k).from_mdl,obj.name)
  				mdl.EIC(k).from_mdl = mdl.name;
             end
          end
          for k=1:numel(mdl.IEC)
  			 if strcmp(mdl.IEC(k).to_mdl,obj.name)
  				mdl.IEC(k).to_mdl = mdl.name;
             end
          end
       end
       %% set methods
       function set_parent(obj,value)
  		  obj.parent = value;
       end
       %% add methods
       function add_Select(obj,fun)
  		  obj.Select = fun;
       end
       function add_model(obj,mdl)
  		  obj.D = {obj.D{:},mdl};
          mdl.set_parent(obj);
       end
       function add_coupling(obj,from_mdl,from_port,to_mdl,to_port)
  		  coupling.from_mdl = from_mdl;
          coupling.from_port = from_port;
          coupling.to_mdl = to_mdl;
          coupling.to_port = to_port;

          obj.I = [obj.I, coupling];

          if(strcmp(coupling.from_mdl,obj.name))
  			 %EIC
             obj.EIC = [obj.EIC,coupling];
          elseif(strcmp(coupling.to_mdl,obj.name))
  			 %IEC
             obj.IEC = [obj.IEC,coupling];
          else
  			 %IC
             obj.IC = [obj.IC,coupling];
          end

       end
       %% get methods
       function tn = get_tn(obj)
  		  tn = obj.tn;
       end

       function tl = get_tl(obj)
  		  tl = obj.tl;
       end

       function name = get_name(obj)
  		  name = obj.name;
       end
       %%
       function create_eventlist(obj)
  		  obj.eventlist=[];
          for d=1:length(obj.D)
  			 obj.eventlist = [obj.eventlist;d,obj.D{d}.get_tn,obj.D{d}.get_tl];
          end
          obj.eventlist = sortrows(obj.eventlist,2);
       end
       %% message functions
       function imessage(obj,t)
  		  if obj.debug_level == 1
  			 sequenceaddlink(sprintf('i-msg(t=%f)',t),obj.get_name);
          end
          for d=1:length(obj.D)
  			 obj.D{d}.imessage(t);
             if obj.debug_level == 1
  				sequenceaddlink(sprintf('done',t),obj.get_name);
             end
          end

          obj.create_eventlist();

          obj.tl = max(obj.eventlist(:,3));
          obj.tn = min(obj.eventlist(:,2));
       end

       

       function smessage(obj,t)
  		  if obj.debug_level == 1
  			 disp(['coordinator: ' obj.name ' s-message']);
             sequenceaddlink(sprintf('*-msg(t=%f)',t),obj.get_name);
          end
          if(t ~= obj.tn)
  			 disp(['error in ' obj.name ' :']);
             disp('in *-msg: simulation time (t) is not equal to time of next event (tn)');
             disp(['simulation time: ' num2str(t)]);
             disp(['time of next event: ' num2str(obj.tn)]);
             pause();
          end
          id = find(obj.eventlist(:,2) == obj.tn);
          obj.IMM = {};
          while ~isempty(id)
  			 obj.IMM = {obj.IMM{:},obj.D{ obj.eventlist(id(1),1) } };
             obj.eventlist(id(1),:) = [];
             id = find(obj.eventlist(:,2) == obj.tn);
          end

          if isempty(obj.Select)
              obj.dstar = def_select(obj.IMM);
          else
              obj.dstar = feval(@obj.Select,obj.IMM);
          end

          obj.dstar.smessage(t);
          obj.create_eventlist();

          obj.tl = t;
          obj.tn = min(obj.eventlist(:,2));

       end

       function check_mail(obj)
		  %delete empty y-messages from mail
		  j=1;
		  while (j <= length(obj.mail))
			 if(isempty(obj.mail(j).y))
				obj.mail(j) = [];
			 else
				j = j+1;
			 end
		  end
       end

       function check_external_couplings(obj)
  		  %external couplings
          obj.yparent = [];
          for j=1:length(obj.mail)
  			 name=obj.mail(j).name;
             ports=fieldnames(obj.mail(j).y);
             for l=1:length(ports)
  				for k=1:length(obj.IEC)
                    if(strcmp(name,obj.IEC(k).from_mdl) && strcmp(ports(l),obj.IEC(k).from_port) )
  					   obj.yparent.(obj.IEC(k).to_port) = obj.mail(j).y.(obj.IEC(k).from_port);
                    end
                end
             end
          end

          obj.receivers=[];
       end

       function check_internal_couplings(obj)
  		  %%internal couplings
          for j=1:length(obj.mail)
  			 name=obj.mail(j).name;
             ports=fieldnames(obj.mail(j).y);
             for l=1:length(ports)
  				for k=1:length(obj.IC)

                    if( strcmp(name,obj.IC(k).from_mdl) && strcmp(ports(l),obj.IC(k).from_port) )

  					   if(isempty(obj.receivers))
  						  idx=[];
                       else
  						  idx=find_mdl(obj.receivers,obj.IC(k).to_mdl);
                       end

                       if(isempty(idx))
  						  r=[];
                          r.name=obj.IC(k).to_mdl;
                          r.x.(obj.IC(k).to_port) = obj.mail(j).y.(obj.IC(k).from_port);
                          r.del = 0;
                          obj.receivers = [obj.receivers, r];
                       else
  						  obj.receivers(idx).x.(obj.IC(k).to_port) = obj.mail(j).y.(obj.IC(k).from_port);
                       end

                    end

                end
             end
          end
       end

       function ymessage(obj,y,name,t)
  		  if obj.debug_level == 1
  			 disp(['coordinator: ' obj.name ' y-message from: ' name ' value:']);
             disp(y);
             if isempty(y)
  				sequenceaddlink(sprintf('y-msg([],%s,%f)',name,t),obj.get_name);
             else
  				sequenceaddlink(sprintf('y-msg(y,%s,%f)',name,t),obj.get_name);
             end
          end

          mail_d =[];
          mail_d.name = name;
          mail_d.y = y;
          mail_d.t = t;

          obj.mail = mail_d;

  		 if obj.debug_level == 1
  			disp(['coordinator: ' obj.name ' receive y-messages from child d*']);
         end
         
         obj.check_mail();
         obj.check_external_couplings();
         obj.check_internal_couplings();

         if obj.debug_level == 1
             disp(['coordinator: ' obj.name ' send y-messages to parent; value: ']);
             disp(obj.yparent);
         end
         obj.parent.ymessage(obj.yparent,obj.name,t);
         if obj.debug_level == 1
             sequenceaddlink('done',obj.get_name);
         end

         for r=1:length(obj.receivers)
             idx = find_mdl_in_D(obj.D, obj.receivers(r).name);
             if(~isempty(idx))
                 if obj.debug_level == 1
                     disp(['coordinator: ' obj.name ' send x-messages to child: ' obj.D{idx}.get_name ' value: ']);
                     disp(obj.receivers(r).x);
                 end
                 obj.D{idx}.xmessage(obj.receivers(r).x,t);

                 if obj.debug_level == 1
                     sequenceaddlink('done',obj.get_name);
                 end
             else
                 %                       disp(['error in ' obj.name ' :']);
                 %                       disp(['in y-msg: can not find the model ' obj.receivers(r).name ' in R_IC']);
                 %                       pause();
             end
         end
       end

       function xmessage(obj,x,t)

           if obj.tl <= t && t <= obj.tn

               if obj.debug_level == 1
                   disp(['coordinator: ' obj.name ' x-message' ' value:']);
                   disp(x);
                   if isempty(x)
                       sequenceaddlink(sprintf('x-msg([],%f)',t),obj.get_name);
                   else
                       sequenceaddlink(sprintf('x-msg(x,%f)',t),obj.get_name);
                   end
               end

               %EIC
               ports = fieldnames(x);
               for k=1:length(ports)
                   for d=1:length(obj.EIC)
                       if(strcmp(ports(k),obj.EIC(d).from_port))
     				       if(isempty(obj.receivers))
      					      idx=[];
                           else
      					      idx=find_mdl(obj.receivers,obj.EIC(d).to_mdl);
                           end

                           if(isempty(idx))
      					      r=[];
                              r.name =  obj.EIC(d).to_mdl;
                              r.x.(obj.EIC(d).to_port) = x.(obj.EIC(d).from_port);
                              r.del = 0;
                              obj.receivers = [obj.receivers,r];
                           else
      					      %r(idx).name =  obj.EIC(d).to_mdl;
                              obj.receivers(idx).x.(obj.EIC(d).to_port) = x.(obj.EIC(d).from_port);
                           end

                       end
                   end
               end


               %send x-message for receivers
               for r=1:length(obj.receivers)
                   idx = find_mdl_in_D(obj.D, obj.receivers(r).name);
                   if(~isempty(idx))
                       if obj.debug_level == 1
                           disp(['coordinator: ' obj.name ' send x-messages to child: ' obj.D{idx}.get_name ' value: ']);
                           disp(obj.receivers(r).x);
                       end
                       obj.D{idx}.xmessage(obj.receivers(r).x,t);
                       if obj.debug_level == 1
                           sequenceaddlink('done',obj.get_name);
                       end
                   else

                       disp(['error in ' obj.name ' :']);
                       disp(['in x-msg: can not find the model ' obj.receivers(r).name ' in D']);

                       pause();
                   end
               end

               obj.create_eventlist();
               obj.tl = t;
               obj.tn = min(obj.eventlist(:,2));
           end
       end
    end

   

end






