(* techmap_celltype = "$fa" *)
module _tech_fa (A, B, C, X, Y);
  parameter WIDTH = 1;

  (* force_downto *)
    input  [WIDTH-1 : 0] A, B, C;

  (* force_downto *)
    output [WIDTH-1 : 0] X, Y;

  // Yosys techmap constant-folding support (same pattern as sky130 file)
  parameter _TECHMAP_CONSTVAL_A_ = WIDTH'bx;
  parameter _TECHMAP_CONSTVAL_B_ = WIDTH'bx;
  parameter _TECHMAP_CONSTVAL_C_ = WIDTH'bx;

  genvar i;
  generate
    for (i = 0; i < WIDTH; i = i + 1) begin : gen_fa
      // SCL180: use ad01d1 full adder
      // Pin map from liberty:
      //   inputs:  A, B, CI
      //   outputs: CO (carry), S (sum)
      ad01d1 fulladder (
        .A (A[i]),
        .B (B[i]),
        .CI(C[i]),
        .CO(X[i]),
        .S (Y[i])
      );
    end
  endgenerate

endmodule

