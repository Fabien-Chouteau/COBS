private with Ada.Containers.Indefinite_Vectors;

package Test_Utils.Abstract_Encoder is

   subtype Parent is Test_Utils.Abstract_Data_Processing;
   type Instance is abstract limited new Parent with private;
   type Acc is access all Instance;
   type Any_Acc is access all Instance'Class;

   procedure Receive (This : in out Instance;
                      Data :        Storage_Element)
   is abstract;
   --  This procedure is called when there is new data to process

   procedure End_Of_Frame (This : in out Instance)
   is abstract;
   --  This procedure is called to signal the end of input frame

   procedure Update (This : in out Instance)
   is abstract;
   --  This procedure is called regularely during test to let processing
   --  abstraction handle pending data, if any.

   procedure End_Of_Test (This : in out Instance)
   is abstract;
   --  This procedure is called at the end of the test, before collecting the
   --  output data frames.

private

   package Data_Frame_Vectors
   is new Ada.Containers.Indefinite_Vectors (Storage_Count, Data_Frame);

   type Instance is abstract limited new Parent with null record;

end Test_Utils.Abstract_Encoder;
