with System.Storage_Elements; use System.Storage_Elements;

with Ada.Containers.Vectors;
with Ada.Unchecked_Deallocation;

with AAA.Strings;

private with Ada.Containers.Indefinite_Vectors;

package Test_Utils is

   package Data_Frame_Package
   is new Ada.Containers.Vectors (Storage_Count, Storage_Element);

   type Data_Frame is new Data_Frame_Package.Vector with null record;

   type Storage_Array_Access is access all Storage_Array;
   procedure Free is new Ada.Unchecked_Deallocation (Storage_Array,
                                                     Storage_Array_Access);

   function From_Array (Data : Storage_Array) return Data_Frame;

   function To_Array_Access (Data : Data_Frame'Class)
                             return Storage_Array_Access;

   function Hex_Dump (Data : Data_Frame'Class) return AAA.Strings.Vector;

   function Diff (A, B        : Data_Frame'Class;
                  A_Name      : String := "Expected";
                  B_Name      : String := "Output";
                  Skip_Header : Boolean := False)
                  return AAA.Strings.Vector;

   function Image (D : Storage_Array) return String;
   function Image (D : Data_Frame) return String;

   type Abstract_Data_Processing is abstract tagged limited private;

   function Number_Of_Frames (This : Abstract_Data_Processing)
                              return Storage_Count;
   --  Return the number of output data frames available

   procedure Clear (This : in out Abstract_Data_Processing)
     with Post => This.Number_Of_Frames = 0;

   function Get_Frame (This  : Abstract_Data_Processing'Class;
                       Index : Storage_Count)
                       return Data_Frame
     with Pre => Index <= This.Number_Of_Frames - 1;
   --  Return an output data frames from it index

private

   package Data_Frame_Vectors
   is new Ada.Containers.Indefinite_Vectors (Storage_Count, Data_Frame);

   type Abstract_Data_Processing is abstract tagged limited record
      Frames : Data_Frame_Vectors.Vector;
      Current_Frame : Data_Frame;
   end record;

   procedure Start_New_Frame (This : in out Abstract_Data_Processing);
   procedure Push_To_Frame (This : in out Abstract_Data_Processing;
                            Data : Storage_Element);
   procedure Save_Frame (This : in out Abstract_Data_Processing);

end Test_Utils;
