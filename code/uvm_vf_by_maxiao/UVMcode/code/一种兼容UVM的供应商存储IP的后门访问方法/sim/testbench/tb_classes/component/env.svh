
class env extends uvm_env;
   `uvm_component_utils(env)

   agent         agent_h;
   coverage      coverage_h;
   scoreboard    scoreboard_h;
   bus_agent     bus_agent_h;

   reg_model reg_model_h;
   adapter adapter_h;
   adapter reg_adapter_h;
   predictor predictor_h;

   uvm_tlm_analysis_fifo #(sequence_item) command_mon_cov_fifo;
   uvm_tlm_analysis_fifo #(sequence_item) command_mon_scb_fifo;
   uvm_tlm_analysis_fifo #(result_transaction) result_mon_scb_fifo;

   function void build_phase(uvm_phase phase);
      agent_h   = agent::type_id::create ("agent_h",this);
      agent_h.is_active = UVM_ACTIVE;
      bus_agent_h   = bus_agent::type_id::create ("bus_agent_h",this);
      bus_agent_h.is_active = UVM_ACTIVE;

      reg_model_h   = reg_model::type_id::create ("reg_model_h");
      reg_model_h.configure();
      reg_model_h.build();
      reg_model_h.lock_model();
      reg_model_h.reset();
      adapter_h   = adapter::type_id::create ("adapter_h");
      reg_adapter_h   = adapter::type_id::create ("reg_adapter_h");
      reg_model_h.add_hdl_path("top.DUT");
      predictor_h   = predictor::type_id::create ("predictor_h",this);

   //analysis
      coverage_h   = coverage::type_id::create ("coverage_h",this);
      scoreboard_h = scoreboard::type_id::create("scoreboard_h",this);
   //fifos
      command_mon_cov_fifo = new("command_mon_cov_fifo",this);
      command_mon_scb_fifo = new("command_mon_scb_fifo",this);
      result_mon_scb_fifo = new("result_mon_scb_fifo",this);
   endfunction : build_phase

   function void connect_phase(uvm_phase phase);
        agent_h.cmd_ap.connect(command_mon_cov_fifo.analysis_export);
        coverage_h.cmd_port.connect(command_mon_cov_fifo.blocking_get_export);

        agent_h.cmd_ap.connect(command_mon_scb_fifo.analysis_export);
        scoreboard_h.cmd_port.connect(command_mon_scb_fifo.blocking_get_export);

        agent_h.result_ap.connect(result_mon_scb_fifo.analysis_export);
        scoreboard_h.result_port.connect(result_mon_scb_fifo.blocking_get_export);

        reg_model_h.default_map.set_sequencer(bus_agent_h.sequencer_h, adapter_h);
        //reg_model_h.default_map.set_auto_predict(1);
        predictor_h.map = reg_model_h.default_map;
        predictor_h.adapter = reg_adapter_h;
        bus_agent_h.bus_trans_ap.connect(predictor_h.bus_in);

   endfunction : connect_phase

   function void end_of_elaboration_phase(uvm_phase phase);
        scoreboard_h.set_report_verbosity_level_hier(UVM_HIGH);
        agent_h.set_report_verbosity_level_hier(UVM_MEDIUM);
   endfunction

   function new (string name, uvm_component parent);
      super.new(name,parent);
   endfunction : new

endclass
   
   
