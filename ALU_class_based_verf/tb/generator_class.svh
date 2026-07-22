class generator_class;
    transaction_class tr;
    mailbox #(transaction_class) gen_mb = new(1);
    event send_tr;

    function new (mailbox #(transaction_class) ag_mb);
        gen_mb = ag_mb;
    endfunction

    task run_gen ();
        for (int i = 0; i < 30; i++) begin
            tr = new();
            assert(tr.randomize());
            tr.print_transction(i, "Generator");
            gen_mb.put(tr);
            ->send_tr;
        end
    endtask
endclass