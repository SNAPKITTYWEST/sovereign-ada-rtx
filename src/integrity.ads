with Core_Types; use Core_Types;
with Memory_Structures;
with Math_Utils;
with Errors;

package Integrity is

   function Compute_Item_Checksum (Item : Data_Item; Seed : Word16) return Word16;
   function Verify_Item (Item : Data_Item; Seed : Word16) return Status_Code;

   function Compute_Buffer_Checksum
     (Buf : Memory_Structures.Buffer;
      Seed : Word16) return Word16;

   function Verify_Buffer
     (Buf : Memory_Structures.Buffer;
      Expected : Word16;
      Seed : Word16) return Status_Code;

   function Compute_Header_Checksum (Hdr : Serial_Header) return Word16;
   function Verify_Header (Hdr : Serial_Header) return Status_Code;

   function Verify_Store_Integrity
     (Store : Memory_Structures.Data_Store;
      Seed : Word16;
      Log : in out Errors.Error_Log) return Status_Code;

end Integrity;
