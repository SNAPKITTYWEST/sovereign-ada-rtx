with Ada.Text_IO;
with Core_Types; use Core_Types;
with Math_Utils;

package body Benchmark is

   procedure Set_Name (R : in out Bench_Result; S : String) is
      Len : Natural := Natural'Min (S'Length, R.Name'Length);
   begin
      R.Name := (others => ' ');
      for I in 0 .. Len - 1 loop
         R.Name (I) := S (S'First + I);
      end loop;
   end Set_Name;

   function Recursive_GCD (A, B : Word32) return Word32 is
   begin
      if B = 0 then return A; end if;
      return Recursive_GCD (B, A mod B);
   end Recursive_GCD;

   function Recursive_Fibonacci (N : Natural) return Word32 is
   begin
      if N <= 1 then return Word32 (N); end if;
      return Recursive_Fibonacci (N - 1) + Recursive_Fibonacci (N - 2);
   end Recursive_Fibonacci;

   function Recursive_Factorial (N : Natural) return Word32 is
   begin
      if N <= 1 then return 1; end if;
      return Word32 (N) * Recursive_Factorial (N - 1);
   end Recursive_Factorial;

   function Recursive_Power (Base : Word32; Exp : Natural) return Word32 is
   begin
      if Exp = 0 then return 1; end if;
      return Base * Recursive_Power (Base, Exp - 1);
   end Recursive_Power;

   function Recursive_Sum (N : Natural) return Word32 is
   begin
      if N = 0 then return 0; end if;
      return Word32 (N) + Recursive_Sum (N - 1);
   end Recursive_Sum;

   procedure Run_Benchmarks (Results : out Bench_Results; Count : out Natural; Overall : out Boolean) is
      Idx : Natural := 0;
      W : Word32;
   begin
      Results := (others => (Name => (others => ' '), Iterations => 0, Cycles => 0, Passed => False));
      Overall := True;

      Set_Name (Results (Idx), "GCD_48_18");
      W := Recursive_GCD (48, 18);
      Results (Idx).Passed := W = 6;
      Results (Idx).Iterations := 1;
      Results (Idx).Cycles := 4;
      if not Results (Idx).Passed then Overall := False; end if;
      Idx := Idx + 1;

      Set_Name (Results (Idx), "Fib_10");
      W := Recursive_Fibonacci (10);
      Results (Idx).Passed := W = 55;
      Results (Idx).Iterations := 1;
      Results (Idx).Cycles := 177;
      if not Results (Idx).Passed then Overall := False; end if;
      Idx := Idx + 1;

      Set_Name (Results (Idx), "Fact_10");
      W := Recursive_Factorial (10);
      Results (Idx).Passed := W = 3628800;
      Results (Idx).Iterations := 1;
      Results (Idx).Cycles := 10;
      if not Results (Idx).Passed then Overall := False; end if;
      Idx := Idx + 1;

      Set_Name (Results (Idx), "Pow_2_10");
      W := Recursive_Power (2, 10);
      Results (Idx).Passed := W = 1024;
      Results (Idx).Iterations := 1;
      Results (Idx).Cycles := 10;
      if not Results (Idx).Passed then Overall := False; end if;
      Idx := Idx + 1;

      Set_Name (Results (Idx), "Sum_100");
      W := Recursive_Sum (100);
      Results (Idx).Passed := W = 5050;
      Results (Idx).Iterations := 1;
      Results (Idx).Cycles := 100;
      if not Results (Idx).Passed then Overall := False; end if;
      Idx := Idx + 1;

      Set_Name (Results (Idx), "GCD_Large");
      W := Recursive_GCD (1071, 462);
      Results (Idx).Passed := W = 21;
      Results (Idx).Iterations := 1;
      Results (Idx).Cycles := 6;
      if not Results (Idx).Passed then Overall := False; end if;
      Idx := Idx + 1;

      Set_Name (Results (Idx), "Fib_20");
      W := Recursive_Fibonacci (20);
      Results (Idx).Passed := W = 6765;
      Results (Idx).Iterations := 1;
      Results (Idx).Cycles := 21891;
      if not Results (Idx).Passed then Overall := False; end if;
      Idx := Idx + 1;

      Set_Name (Results (Idx), "Safe_Add_Bench");
      declare
         Ov : Boolean; R : Word32;
      begin
         for I in 1 .. 1000 loop
            R := Math_Utils.Safe_Add (Word32 (I), Word32 (I), Ov);
         end loop;
         Results (Idx).Passed := not Ov;
         Results (Idx).Iterations := 1000;
         Results (Idx).Cycles := 1000;
      end;
      if not Results (Idx).Passed then Overall := False; end if;
      Idx := Idx + 1;

      Set_Name (Results (Idx), "ISqrt_Bench");
      for I in 1 .. 100 loop
         W := Math_Utils.ISqrt (Word32 (I) * 100);
      end loop;
      Results (Idx).Passed := W = 100;
      Results (Idx).Iterations := 100;
      Results (Idx).Cycles := 100;
      if not Results (Idx).Passed then Overall := False; end if;
      Idx := Idx + 1;

      Count := Idx;
   end Run_Benchmarks;

   procedure Report_Benchmarks (Results : Bench_Results; Count : Natural; Overall : Boolean) is
      Name_Str : String (1 .. 64); Name_Len : Natural;
   begin
      Ada.Text_IO.New_Line;
      Ada.Text_IO.Put_Line ("=== SOVEREIGN RTX BENCHMARK SUITE ===");
      Ada.Text_IO.Put_Line ("Benchmarks: " & Natural'Image (Count));
      Ada.Text_IO.Put_Line ("------------------------------------");
      for I in 0 .. Count - 1 loop
         Name_Len := 0;
         for J in Results (I).Name'Range loop
            if Results (I).Name (J) /= ' ' then Name_Len := J + 1; end if;
         end loop;
         if Name_Len > 0 then
            Name_Str := (others => ' ');
            for J in 0 .. Name_Len - 1 loop
               Name_Str (J + 1) := Results (I).Name (J);
            end loop;
            if Results (I).Passed then
               Ada.Text_IO.Put_Line ("  [PASS] " & Name_Str (1 .. Name_Len) &
                  "  iters=" & Word32'Image (Results (I).Iterations) &
                  "  cycles=" & Word32'Image (Results (I).Cycles));
            else
               Ada.Text_IO.Put_Line ("  [FAIL] " & Name_Str (1 .. Name_Len));
            end if;
         end if;
      end loop;
      Ada.Text_IO.New_Line;
      if Overall then
         Ada.Text_IO.Put_Line ("RESULT: ALL BENCHMARKS PASSED");
      else
         Ada.Text_IO.Put_Line ("RESULT: SOME BENCHMARKS FAILED");
      end if;
   end Report_Benchmarks;

end Benchmark;
