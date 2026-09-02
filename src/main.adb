with Ada.Text_IO;
with Ada.Strings.Unbounded;
with Core_Types; use Core_Types;
with Errors;
with Parser;
with Dispatcher;
with Self_Test;
with Benchmark;
with RTX_Sovereign_Driver;

procedure Main is
   Log : Errors.Error_Log;
   Ctx : Dispatcher.Context;
   Cmd : Parser.Parsed_Command;
   St : Status_Code;
   Line : String (1 .. 256);
   Last : Natural;
   Test_Results : Self_Test.Test_Results;
   Test_Count : Natural;
   Test_Overall : Boolean;
   Bench_Results : Benchmark.Bench_Results;
   Bench_Count : Natural;
   Bench_Overall : Boolean;
   Weights : RTX_Sovereign_Driver.Tensor_State;
   Bias : Word32;
begin
   Ada.Text_IO.Put_Line ("========================================");
   Ada.Text_IO.Put_Line ("ADA DETERMINISTIC PROCESSOR v1.0");
   Ada.Text_IO.Put_Line ("Pure Ada, no external dependencies");
   Ada.Text_IO.Put_Line ("========================================");
   Ada.Text_IO.Put_Line ("Build: pure Ada standard library only");
   Ada.Text_IO.Put_Line ("Architecture: core types + config + parser + state machine + validation");
   Ada.Text_IO.Put_Line ("+ math utils + memory + serialization + integrity + dispatcher + self-test");
   Ada.Text_IO.Put_Line ("+ RTX sovereign driver + benchmark suite");
   Ada.Text_IO.New_Line;

   Ada.Text_IO.Put_Line ("Initializing subsystems...");
   Dispatcher.Init_Context (Ctx);

   Ada.Text_IO.Put_Line ("Running comprehensive self-tests...");
   Self_Test.Run_All_Tests (Test_Results, Test_Count, Test_Overall);
   Self_Test.Report_Results (Test_Results, Test_Count, Test_Overall);

   if not Test_Overall then
      Ada.Text_IO.Put_Line ("SELF-TEST FAILED. System halted.");
      return;
   end if;

   Ada.Text_IO.New_Line;
   Ada.Text_IO.Put_Line ("Running benchmark suite...");
   Benchmark.Run_Benchmarks (Bench_Results, Bench_Count, Bench_Overall);
   Benchmark.Report_Benchmarks (Bench_Results, Bench_Count, Bench_Overall);

   Ada.Text_IO.New_Line;
   Ada.Text_IO.Put_Line ("Initializing RTX Sovereign Engine...");
   RTX_Sovereign_Driver.Initialize_Engine (Weights, Bias);
   Ada.Text_IO.Put_Line ("RTX engine initialized (256-dim tensor, cold-boot state).");
   Ada.Text_IO.Put_Line ("Tensor weights: all 1, bias: 0");

   Ada.Text_IO.New_Line;
   Ada.Text_IO.Put_Line ("Self-tests passed. System ready.");
   Ada.Text_IO.Put_Line ("Type HELP for commands, EXIT to quit.");
   Ada.Text_IO.New_Line;

   loop
      Ada.Text_IO.Put ("> ");
      Ada.Text_IO.Get_Line (Line, Last);
      exit when Last = 0;

      St := Parser.Parse_Line (Line (1 .. Last), Cmd, Log);
      if St /= Success then
         Errors.Report_Error (Log);
         Errors.Clear_Error (Log);
      else
         St := Dispatcher.Dispatch (Ctx, Cmd, Log);
         if St /= Success then
            Errors.Report_Error (Log);
            Errors.Clear_Error (Log);
         end if;
         exit when Dispatcher.Get_Current_State (Ctx) = Shutdown;
      end if;
   end loop;

   Ada.Text_IO.Put_Line ("Processor shutdown.");
end Main;
