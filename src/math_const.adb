with Math_Utils;
package body Math_Const is
   function Degrees_To_Radians_Approx (Deg : Word32) return Word32 is
   begin
      return (Deg * Pi_Approx) / 180;
   end Degrees_To_Radians_Approx;
   function Radians_To_Degrees_Approx (Rad : Word32) return Word32 is
   begin
      return (Rad * 180) / Pi_Approx;
   end Radians_To_Degrees_Approx;
   function Factorial_Bounded (N : Natural) return Word32 is
      Result : Word32 := 1;
   begin
      if N = 0 then return 1; end if;
      for I in 1 .. Natural'Min (N, 12) loop
         Result := Result * Word32 (I);
      end loop;
      return Result;
   end Factorial_Bounded;
   function Fibonacci (N : Natural) return Word32 is
      A : Word32 := 0; B : Word32 := 1; T : Word32;
   begin
      if N = 0 then return 0; end if;
      for I in 2 .. N loop
         T := A + B;
         if T < A then return Word32'Last; end if;
         A := B; B := T;
      end loop;
      return B;
   end Fibonacci;
   function Binomial (N, K : Natural) return Word32 is
      Result : Word32 := 1;
   begin
      if K > N then return 0; end if;
      for I in 0 .. Natural'Min (K, N / 2) - 1 loop
         Result := Result * Word32 (N - I) / Word32 (I + 1);
      end loop;
      return Result;
   end Binomial;
end Math_Const;
