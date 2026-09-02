package CNN_Engine is

   type Matrix_2D is array (Integer range <>, Integer range <>) of Float;
   type Kernel_2D is array (Integer range <>, Integer range <>) of Float;

   function ReLU (X : Float) return Float;

   procedure Convolve2D (
      Input        : in Matrix_2D;
      Kernel       : in Kernel_2D;
      Bias         : in Float;
      Output       : out Matrix_2D
   );

end CNN_Engine;
