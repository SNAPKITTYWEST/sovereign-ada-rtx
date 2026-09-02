with Core_Types; use Core_Types;
package Memory_Structures is
   type Buffer is limited private;
   type Data_Store is limited private;
   procedure Init_Buffer (Buf : in out Buffer);
   procedure Clear_Buffer (Buf : in out Buffer);
   function Buffer_Length (Buf : Buffer) return Length_Type;
   function Buffer_Capacity (Buf : Buffer) return Length_Type;
   function Is_Buffer_Full (Buf : Buffer) return Boolean;
   function Is_Buffer_Empty (Buf : Buffer) return Boolean;
   function Append_Byte (Buf : in out Buffer; Value : Byte) return Status_Code;
   function Append_Bytes (Buf : in out Buffer; Data : Byte_Array) return Status_Code;
   function Get_Byte (Buf : Buffer; Index : Index_Type; Value : out Byte) return Status_Code;
   function Get_Slice (Buf : Buffer; Start : Index_Type; Count : Length_Type; Result : out Byte_Array) return Status_Code;
   procedure Copy_Buffer (Src : Buffer; Dst : in out Buffer);
   procedure Fill_Buffer (Buf : in out Buffer; Value : Byte; Count : Length_Type);
   procedure Zero_Buffer (Buf : in out Buffer);
   function Buffer_Equals (A, B : Buffer) return Boolean;
   procedure Init_Store (Store : in out Data_Store);
   procedure Clear_Store (Store : in out Data_Store);
   function Store_Count (Store : Data_Store) return Natural;
   function Store_Capacity (Store : Data_Store) return Natural;
   function Insert_Item (Store : in out Data_Store; Item : Data_Item) return Status_Code;
   function Get_Item (Store : Data_Store; Index : Index_Type; Item : out Data_Item) return Status_Code;
   function Find_Item_By_Id (Store : Data_Store; Id : Word16; Item : out Data_Item; Found : out Boolean) return Status_Code;
   function Update_Item (Store : in out Data_Store; Index : Index_Type; Item : Data_Item) return Status_Code;
   function Remove_Item_By_Id (Store : in out Data_Store; Id : Word16) return Status_Code;
   function Store_Contains_Id (Store : Data_Store; Id : Word16) return Boolean;
private
   type Buffer is record
      Data : Fixed_Buffer := (others => 0);
      Length : Length_Type := 0;
   end record;
   type Data_Store is record
      Items : Fixed_Data_Store := (others => (Id => 0, Value => 0, Flags => 0, Checksum => 0, Valid => False));
      Count : Natural := 0;
   end record;
end Memory_Structures;
