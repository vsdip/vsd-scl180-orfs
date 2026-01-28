// SCL180 FS120 6M1L latch mapping
// Liberty shows: enable : "(!EN)" ; data_in : "D"
// => latch is transparent when EN=0 (active-low enable).

module $_DLATCH_N_(input E, input D, output Q);
    // E is treated as active-low enable
    lanlq1 _TECHMAP_REPLACE_ (
        .D(D),
        .EN(E),
        .Q(Q)
    );
endmodule

module $_DLATCH_P_(input E, input D, output Q);
    // Yosys expects active-high enable, but SCL provides active-low enable.
    // Implement by inverting E and reusing the same latch.
    wire ENB;
    assign ENB = ~E;

    lanlq1 _TECHMAP_REPLACE_ (
        .D(D),
        .EN(ENB),
        .Q(Q)
    );
endmodule

