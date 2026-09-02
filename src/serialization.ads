with Core_Types; use Core_Types;
with Memory_Structures;
with Errors;
package Serialization is
   function Serialize_Header (Hdr : Serial_Header; Buf : in out Memory_Structures.Buffer) return Status_Code;
   function Deserialize_Header (Buf : Memory_Structures.Buffer; Hdr : out Serial_Header) return Status_Code;
   function Serialize_Item (Item : Data_Item; Buf : in out Memory_Structures.Buffer) return Status_Code;
   function Deserialize_Item (Buf : Memory_Structures.Buffer; Offset : Index_Type; Item : out Data_Item; Next : out Index_Type) return Status_Code;
   function Serialize_Store (Store : Memory_Structures.Data_Store; Buf : in out Memory_Structures.Buffer; Log : in out Errors.Error_Log) return Status_Code;
   function Deserialize_Store (Buf : Memory_Structures.Buffer; Store : in out Memory_Structures.Data_Store; Log : in out Errors.Error_Log) return Status_Code;
   function Header_Size return Length_Type;
end Serialization;
