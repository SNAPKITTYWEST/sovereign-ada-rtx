with Core_Types; use Core_Types;

package Math_Utils is

   function Safe_Add (A, B : Word32; Overflow : out Boolean) return Word32;
   function Safe_Sub (A, B : Word32; Underflow : out Boolean) return Word32;
   function Safe_Mul (A, B : Word32; Overflow : out Boolean) return Word32;

   function Modulo (A : Word32; M : Word32) return Word32
     with Pre => M > 0;

   function Rotate_Left (Value : Word16; Amount : Natural) return Word16;
   function Rotate_Right (Value : Word16; Amount : Natural) return Word16;
   function Bit_Count (Value : Word32) return Natural;

   function Simple_Checksum (Data : Byte_Array; Seed : Word16) return Word16;
   function Fletcher16 (Data : Byte_Array) return Word16;

   function Clamp (Value : Word32; Lo, Hi : Word32) return Word32
     with Pre => Lo <= Hi;

   function ISqrt (N : Word32) return Word32;

   function Is_Power_Of_Two (N : Word32) return Boolean;

   function Min_W32 (A, B : Word32) return Word32;
   function Max_W32 (A, B : Word32) return Word32;

end Math_Utils;
