with Core_Types; use Core_Types;
with Errors;
with Validation;

package body State_Machine is

   procedure Init_Machine (M : in out Machine) is
   begin
      M.Current := Idle;
      M.Previous := Idle;
      M.Transition_Count := 0;
   end Init_Machine;

   procedure Reset_Machine (M : in out Machine) is
   begin
      Init_Machine (M);
   end Reset_Machine;

   function Get_State (M : Machine) return App_State is
   begin
      return M.Current;
   end Get_State;

   function Transition
     (M : in out Machine;
      To : App_State;
      Log : in out Errors.Error_Log) return Status_Code
   is
      St : Status_Code;
   begin
      St := Validation.Validate_State_Transition (M.Current, To);
      if St /= Success then
         Errors.Set_Error (Log, St, Medium_Natural (App_State'Pos (M.Current)), "invalid transition");
         return St;
      end if;
      M.Previous := M.Current;
      M.Current := To;
      if M.Transition_Count < Medium_Natural'Last then
         M.Transition_Count := M.Transition_Count + 1;
      end if;
      return Success;
   end Transition;

   function Force_Error (M : in out Machine) return Status_Code is
   begin
      M.Previous := M.Current;
      M.Current := Error_State;
      return Success;
   end Force_Error;

   function Is_Terminal (M : Machine) return Boolean is
   begin
      return M.Current = Shutdown;
   end Is_Terminal;

   function Can_Accept_Input (M : Machine) return Boolean is
   begin
      return M.Current = Awaiting_Input or else
             M.Current = Configured or else
             M.Current = Authorized or else
             M.Current = Idle;
   end Can_Accept_Input;

end State_Machine;
