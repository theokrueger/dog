module testbench;
  // individual component testing
  alu_tb alu_test ();
  branch_unit_tb branch_unit_test ();
  instruction_decode_tb inst_dc_test ();

  // system testing

   initial
    begin
       #0 begin end;
       #100000 $finish;
    end
endmodule // testbench
