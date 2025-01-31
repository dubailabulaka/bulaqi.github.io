
class random_sequence extends uvm_sequence #(sequence_item);
   `uvm_object_utils(random_sequence)
   
   int item_num = 100;
   sequence_item command;

   function new(string name = "random_sequence");
      super.new(name);
   endfunction : new

   task body();
      repeat (item_num) begin : random_loop
         command = sequence_item::type_id::create("command");
         start_item(command);
         assert(command.randomize());
         finish_item(command);
         `uvm_info("RANDOM SEQ", $sformatf("random command: %s", command.convert2string), UVM_LOW)
      end : random_loop
   endtask : body
endclass : random_sequence











