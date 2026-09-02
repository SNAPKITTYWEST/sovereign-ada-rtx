with Ada.Text_IO;
with Ada.Numerics.Elementary_Functions;

package body CNN_Engine is

   -- Activation function: ReLU
   function ReLU (X : Float) return Float is
   begin
      if X > 0.0 then
         return X;
      else
         return 0.0;
      end if;
   end ReLU;

   -- 2D Convolution Forward Pass Kernel
   procedure Convolve2D (
      Input        : in Matrix_2D;
      Kernel       : in Kernel_2D;
      Bias         : in Float;
      Output       : out Matrix_2D
   ) is
      In_Rows    : constant Integer := Input'Length(1);
      In_Cols    : constant Integer := Input'Length(2);
      K_Size     : constant Integer := Kernel'Length(1);
      Out_Rows   : constant Integer := In_Rows - K_Size + 1;
      Out_Cols   : constant Integer := In_Cols - K_Size + 1;
      Sum        : Float;
   begin
      for R in 1 .. Out_Rows loop
         for C in 1 .. Out_Cols loop
            Sum := Bias;
            for KR in 1 .. K_Size loop
               for KC in 1 .. K_Size loop
                  Sum := Sum + Input(R + KR - 1, C + KC - 1) * Kernel(KR, KC);
               end loop;
            end loop;
            Output(R, C) := ReLU(Sum);
         end loop;
      end loop;
   end Convolve2D;

end CNN_Engine;
