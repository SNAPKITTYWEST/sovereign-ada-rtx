package body String_Utils is
   function Length_Of (S : Bounded_String) return Natural is
      Last : Natural := 0;
   begin
      for I in S'Range loop
         if S (I) /= ' ' then Last := I + 1; end if;
      end loop;
      return Last;
   end Length_Of;
   function Is_Empty (S : Bounded_String) return Boolean is
   begin
      for I in S'Range loop
         if S (I) /= ' ' then return False; end if;
      end loop;
      return True;
   end Is_Empty;
   procedure Clear (S : in out Bounded_String) is
   begin
      S := (others => ' ');
   end Clear;
   procedure Copy_To (Src : String; Dst : in out Bounded_String) is
      Len : Natural := Natural'Min (Src'Length, Dst'Length);
   begin
      Dst := (others => ' ');
      for I in 0 .. Len - 1 loop
         Dst (I) := Src (Src'First + I);
      end loop;
   end Copy_To;
   function Starts_With (S : Bounded_String; Prefix : String) return Boolean is
   begin
      if Prefix'Length > S'Length then return False; end if;
      for I in 0 .. Prefix'Length - 1 loop
         if S (I) /= Prefix (Prefix'First + I) then return False; end if;
      end loop;
      return True;
   end Starts_With;
   function Equals (A, B : Bounded_String) return Boolean is
   begin
      for I in A'Range loop
         if A (I) /= B (I) then return False; end if;
      end loop;
      return True;
   end Equals;
   function To_Upper_Bounded (S : Bounded_String) return Bounded_String is
      Result : Bounded_String := S;
   begin
      for I in Result'Range loop
         if Result (I) >= 'a' and Result (I) <= 'z' then
            Result (I) := Character'Val (Character'Pos (Result (I)) - 32);
         end if;
      end loop;
      return Result;
   end To_Upper_Bounded;
   function Contains_Char (S : Bounded_String; C : Character) return Boolean is
   begin
      for I in S'Range loop
         if S (I) = C then return True; end if;
      end loop;
      return False;
   end Contains_Char;
   procedure Append_Char (S : in out Bounded_String; C : Character; Ok : out Boolean) is
   begin
      for I in S'Range loop
         if S (I) = ' ' then
            S (I) := C; Ok := True; return;
         end if;
      end loop;
      Ok := False;
   end Append_Char;
end String_Utils;
