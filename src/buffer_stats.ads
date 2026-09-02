with Core_Types; use Core_Types;
with Memory_Structures;
package Buffer_Stats is
   function Occupancy_Percent (Buf : Memory_Structures.Buffer) return Natural;
   function Remaining_Capacity (Buf : Memory_Structures.Buffer) return Length_Type;
   function Is_Nearly_Full (Buf : Memory_Structures.Buffer; Threshold : Natural) return Boolean;
   function Average_Byte (Buf : Memory_Structures.Buffer) return Byte;
   function Max_Byte (Buf : Memory_Structures.Buffer) return Byte;
   function Min_Byte (Buf : Memory_Structures.Buffer) return Byte;
   function Sum_Bytes (Buf : Memory_Structures.Buffer) return Word32;
end Buffer_Stats;
