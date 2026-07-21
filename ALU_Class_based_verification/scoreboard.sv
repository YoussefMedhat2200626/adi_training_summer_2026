class scoreboard;
  mailbox #(transaction) mbx;

  function new(mailbox #(transaction) mbx);
    this.mbx = mbx;
  endfunction

  task run();
  transaction tr;
  bit [3:0] exp_result;
  bit       exp_carry = 0;
  bit       exp_borrow = 0;
  bit       exp_overflow = 0;

  forever begin
    mbx.get(tr);

    if (!tr.rst) begin
      exp_result   = 0;
      exp_carry    = 0;
      exp_borrow   = 0;
      exp_overflow = 0;
    end else begin
      case (tr.Opcode)
        2'b00: begin
          {exp_carry, exp_result} = tr.A + tr.B + tr.Cin;
          exp_overflow = (tr.A[3] == tr.B[3]) && (exp_result[3] != tr.A[3]);
        end
        2'b01: begin
          exp_result   = tr.A - tr.B;
          exp_borrow   = (tr.A < tr.B);
          exp_overflow = (tr.A[3] != tr.B[3]) && (exp_result[3] != tr.A[3]);
        end
        2'b10: begin
          exp_result = tr.A & tr.B;
        end
        2'b11: begin
          exp_result = tr.A | tr.B;
        end
      endcase
    end
  end
  endtask
endclass
