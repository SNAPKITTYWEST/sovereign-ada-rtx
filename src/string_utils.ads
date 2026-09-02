with Core_Types; use Core_Types;
package String_Utils is
   function Length_Of (S : Bounded_String) return Natural;
   function Is_Empty (S : Bounded_String) return Boolean;
   procedure Clear (S : in out Bounded_String);
   procedure Copy_To (Src : String; Dst : in out Bounded_String);
   function Starts_With (S : Bounded_String; Prefix : String) return Boolean;
   function Equals (A, B : Bounded_String) return Boolean;
   function To_Upper_Bounded (S : Bounded_String) return Bounded_String;
   function Contains_Char (S : Bounded_String; C : Character) return Boolean;
   procedure Append_Char (S : in out Bounded_String; C : Character; Ok : out Boolean);
end String_Utils;
