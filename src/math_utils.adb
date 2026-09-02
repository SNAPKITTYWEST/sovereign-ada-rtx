package body Math_Utils is

   function Safe_Add (A, B : Word32; Overflow : out Boolean) return Word32 is
   begin
      if A > Word32'Last - B then Overflow := True; return Word32'Last;
      else Overflow := False; return A + B; end if;
   end Safe_Add;

   function Safe_Sub (A, B : Word32; Underflow : out Boolean) return Word32 is
   begin
      if A < B then Underflow := True; return 0;
      else Underflow := False; return A - B; end if;
   end Safe_Sub;

   function Safe_Mul (A, B : Word32; Overflow : out Boolean) return Word32 is
   begin
      if A = 0 or B = 0 then Overflow := False; return 0; end if;
      if A > Word32'Last / B then Overflow := True; return Word32'Last;
      else Overflow := False; return A * B; end if;
   end Safe_Mul;

   function Modulo (A : Word32; M : Word32) return Word32 is (A - (A / M) * M);

   function Rotate_Left (Value : Word16; Amount : Natural) return Word16 is
      Amt : Natural := Amount mod 16; High : Word16;
   begin
      if Amt = 0 then return Value; end if;
      High := Value / (2 ** (16 - Amt));
      return (Value * (2 ** Amt)) mod 65536 + High;
   end Rotate_Left;

   function Rotate_Right (Value : Word16; Amount : Natural) return Word16 is
      Amt : Natural := Amount mod 16; Low : Word16;
   begin
      if Amt = 0 then return Value; end if;
      Low := Value mod (2 ** Amt);
      return (Value / (2 ** Amt)) + Low * (2 ** (16 - Amt));
   end Rotate_Right;

   function Bit_Count (Value : Word32) return Natural is
      V : Word32 := Value; Count : Natural := 0;
   begin
      while V /= 0 loop
         if (V mod 2) = 1 then Count := Count + 1; end if;
         V := V / 2;
      end loop;
      return Count;
   end Bit_Count;

   function Simple_Checksum (Data : Byte_Array; Seed : Word16) return Word16 is
      Sum : Word32 := Word32 (Seed); Ov : Boolean;
   begin
      for I in Data'Range loop
         Sum := Safe_Add (Sum, Word32 (Data (I)), Ov);
         if Ov then Sum := Sum mod 65536; end if;
         Sum := (Sum + Sum * 31) mod 65536;
      end loop;
      return Word16 (Sum);
   end Simple_Checksum;

   function Fletcher16 (Data : Byte_Array) return Word16 is
      Sum1 : Word32 := 0; Sum2 : Word32 := 0;
   begin
      for I in Data'Range loop
         Sum1 := (Sum1 + Word32 (Data (I))) mod 255;
         Sum2 := (Sum2 + Sum1) mod 255;
      end loop;
      return Word16 (Sum2 * 256 + Sum1);
   end Fletcher16;

   function Clamp (Value : Word32; Lo, Hi : Word32) return Word32 is
   begin
      if Value < Lo then return Lo; elsif Value > Hi then return Hi; else return Value; end if;
   end Clamp;

   function ISqrt (N : Word32) return Word32 is
      X : Word32 := N; Y : Word32;
   begin
      if N = 0 then return 0; end if;
      Y := N / 2 + 1;
      while Y < X loop X := Y; Y := (X + N / X) / 2; end loop;
      return X;
   end ISqrt;

   function Is_Power_Of_Two (N : Word32) return Boolean is
   begin
      if N = 0 then return False; end if;
      return (N and (N - 1)) = 0;
   end Is_Power_Of_Two;

   function Min_W32 (A, B : Word32) return Word32 is (if A < B then A else B);
   function Max_W32 (A, B : Word32) return Word32 is (if A > B then A else B);

end Math_Utils;
