with Core_Types; use Core_Types;
with Errors;
with Validation;

package State_Machine is

   type Machine is limited private;

   procedure Init_Machine (M : in out Machine);
   procedure Reset_Machine (M : in out Machine);

   function Get_State (M : Machine) return App_State;
   function Transition
     (M : in out Machine;
      To : App_State;
      Log : in out Errors.Error_Log) return Status_Code;

   function Force_Error (M : in out Machine) return Status_Code;
   function Is_Terminal (M : Machine) return Boolean;
   function Can_Accept_Input (M : Machine) return Boolean;

private

   type Machine is record
      Current : App_State := Idle;
      Previous : App_State := Idle;
      Transition_Count : Medium_Natural := 0;
   end record;

end State_Machine;
