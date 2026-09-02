with Core_Types; use Core_Types;
package Benchmark is
   type Bench_Result is record
      Name : Bounded_String := (others => ' ');
      Iterations : Word32 := 0;
      Cycles : Word32 := 0;
      Passed : Boolean := False;
   end record;
   Max_Benches : constant := 16;
   type Bench_Results is array (0 .. Max_Benches - 1) of Bench_Result;
   procedure Run_Benchmarks (Results : out Bench_Results; Count : out Natural; Overall : out Boolean);
   procedure Report_Benchmarks (Results : Bench_Results; Count : Natural; Overall : Boolean);
   function Recursive_GCD (A, B : Word32) return Word32;
   function Recursive_Fibonacci (N : Natural) return Word32;
   function Recursive_Factorial (N : Natural) return Word32;
   function Recursive_Power (Base : Word32; Exp : Natural) return Word32;
   function Recursive_Sum (N : Natural) return Word32;
-- Recursive depth limited for safety on constrained stacks
-- Benchmarks report abstract work units (cycles) for portability
end Benchmark;
