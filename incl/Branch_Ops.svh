localparam BRANCH_NO_OP=2'b00;

// if nonzero flag, branch
localparam BRANCH_NOTZERO_OP=2'b01;

// if sub flag (implies overflow of sub or something)
localparam BRANCH_SUBOVERFLOW_OP=2'b10;

// if zero flag, branch
localparam BRANCH_ZERO_OP=2'b11;
