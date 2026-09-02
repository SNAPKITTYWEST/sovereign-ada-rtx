with Math_Utils;
package body Buffer_Stats is
   function Occupancy_Percent (Buf : Memory_Structures.Buffer) return Natural is
      Len : constant Natural := Natural (Memory_Structures.Buffer_Length (Buf));
      Cap : constant Natural := Natural (Memory_Structures.Buffer_Capacity (Buf));
   begin
      if Cap = 0 then return 0; end if;
      return (Len * 100) / Cap;
   end Occupancy_Percent;
   function Remaining_Capacity (Buf : Memory_Structures.Buffer) return Length_Type is
   begin
      return Memory_Structures.Buffer_Capacity (Buf) - Memory_Structures.Buffer_Length (Buf);
   end Remaining_Capacity;
   function Is_Nearly_Full (Buf : Memory_Structures.Buffer; Threshold : Natural) return Boolean is
   begin
      return Occupancy_Percent (Buf) >= Threshold;
   end Is_Nearly_Full;
   function Average_Byte (Buf : Memory_Structures.Buffer) return Byte is
      Len : constant Length_Type := Memory_Structures.Buffer_Length (Buf);
      Sum : Word32 := 0; Dummy : Byte; St : Status_Code;
   begin
      if Len = 0 then return 0; end if;
      for I in 0 .. Len - 1 loop
         St := Memory_Structures.Get_Byte (Buf, I, Dummy);
         if St = Success then Sum := Sum + Word32 (Dummy); end if;
      end loop;
      return Byte (Sum / Word32 (Len));
   end Average_Byte;
   function Max_Byte (Buf : Memory_Structures.Buffer) return Byte is
      Len : constant Length_Type := Memory_Structures.Buffer_Length (Buf);
      Max_V : Byte := 0; Dummy : Byte; St : Status_Code;
   begin
      for I in 0 .. Len - 1 loop
         St := Memory_Structures.Get_Byte (Buf, I, Dummy);
         if St = Success and then Dummy > Max_V then Max_V := Dummy; end if;
      end loop;
      return Max_V;
   end Max_Byte;
   function Min_Byte (Buf : Memory_Structures.Buffer) return Byte is
      Len : constant Length_Type := Memory_Structures.Buffer_Length (Buf);
      Min_V : Byte := 255; Dummy : Byte; St : Status_Code;
   begin
      if Len = 0 then return 0; end if;
      for I in 0 .. Len - 1 loop
         St := Memory_Structures.Get_Byte (Buf, I, Dummy);
         if St = Success and then Dummy < Min_V then Min_V := Dummy; end if;
      end loop;
      return Min_V;
   end Min_Byte;
   function Sum_Bytes (Buf : Memory_Structures.Buffer) return Word32 is
      Len : constant Length_Type := Memory_Structures.Buffer_Length (Buf);
      Sum : Word32 := 0; Dummy : Byte; St : Status_Code;
   begin
      for I in 0 .. Len - 1 loop
         St := Memory_Structures.Get_Byte (Buf, I, Dummy);
         if St = Success then Sum := Sum + Word32 (Dummy); end if;
      end loop;
      return Sum;
   end Sum_Bytes;
end Buffer_Stats;
