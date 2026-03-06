module testbench;
  // individual component testing
  alu_tb alu_test ();
  branch_unit_tb branch_unit_test ();
  instruction_decode_tb instruction_decode_test ();
  slice_tb slice_test ();
  // system testing

   initial
    begin
       #0 begin end;
       #100000 $finish;
    end
endmodule // testbench
