module OPENROAD_CLKGATE (CK, E, GCK);
  input CK;
  input E;
  output GCK;

`ifdef OPENROAD_CLKGATE

  // SCL180 FS120 integrated clock gate cell
  // Ports: (EN, CLK, SE, GCLK)
  // SE = scan enable / test enable. Tie low for normal functional mode.
  gclrsn1 u_icg (
    .EN   (E),
    .CLK  (CK),
    .SE   (1'b0),
    .GCLK (GCK)
  );

`else

  assign GCK = CK;

`endif

endmodule

