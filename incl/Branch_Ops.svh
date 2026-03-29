localparam BRANCH_NO_OP=3'b00;

// if nonzero flag, branch
localparam BRANCH_NOTZERO_OP=3'b01;

// if sub flag (implies overflow of sub or something)
localparam BRANCH_SUBOVERFLOW_OP=3'b10;

// if zero flag, branch
localparam BRANCH_ZERO_OP=3'b11;

// unconditionally branch
localparam BRANCH_UNCONDITIONAL_OP=3'b100;
