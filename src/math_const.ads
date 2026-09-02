with Core_Types; use Core_Types;
package Math_Const is
   Pi_Approx : constant Word32 := 314;
   E_Approx : constant Word32 := 271;
   function Degrees_To_Radians_Approx (Deg : Word32) return Word32;
   function Radians_To_Degrees_Approx (Rad : Word32) return Word32;
   function Factorial_Bounded (N : Natural) return Word32;
   function Fibonacci (N : Natural) return Word32;
   function Binomial (N, K : Natural) return Word32;
end Math_Const;
