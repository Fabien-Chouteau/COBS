with Ada.Strings.Unbounded;

package body Test_Utils is

   function Shift_Right
     (Value  : Storage_Element;
      Amount : Natural) return Storage_Element
     with Import, Convention => Intrinsic;

   type UInt4 is mod 2 ** 4
     with Size => 4;

   UInt4_To_Char : constant array (UInt4) of Character
     := (0 =>  '0',
         1 =>  '1',
         2 =>  '2',
         3 =>  '3',
         4 =>  '4',
         5 =>  '5',
         6 =>  '6',
         7 =>  '7',
         8 =>  '8',
         9 =>  '9',
         10 => 'A',
         11 => 'B',
         12 => 'C',
         13 => 'D',
         14 => 'E',
         15 => 'F');

   ----------------
   -- From_Array --
   ----------------

   function From_Array (Data : Storage_Array) return Data_Frame is
      Result : Data_Frame;
   begin
      for Elt of Data loop
         Result.Append (Elt);
      end loop;

      return Result;
   end From_Array;

   ---------------------
   -- To_Array_Access --
   ---------------------

   function To_Array_Access (Data : Data_Frame'Class)
                             return Storage_Array_Access
   is
      Result : constant Storage_Array_Access :=
        new Storage_Array (1 .. Storage_Count (Data.Length));

      Index : Storage_Offset := Result'First;
   begin
      for Elt of Data loop
         Result (Index) := Elt;
         Index := Index + 1;
      end loop;

      return Result;
   end To_Array_Access;

   --------------
   -- Hex_Dump --
   --------------

   function Hex_Dump (Data : Data_Frame'Class) return AAA.Strings.Vector is
      Result : AAA.Strings.Vector;
      Cnt : Natural := 0;
   begin

      for Elt of Data loop
         Result.Append_To_Last_Line
           (UInt4_To_Char (UInt4 (Shift_Right (Elt, 4))) &
              UInt4_To_Char (UInt4 (Elt and 16#0F#)));

         Cnt := Cnt + 1;
         if Cnt = 16 then
            Result.Append ("");
            Cnt := 0;
         else
            Result.Append_To_Last_Line (" ");
         end if;
      end loop;
      return Result;
   end Hex_Dump;

   ----------
   -- Diff --
   ----------

   function Diff (A, B        : Data_Frame'Class;
                  A_Name      : String := "Expected";
                  B_Name      : String := "Output";
                  Skip_Header : Boolean := False)
                  return AAA.Strings.Vector
   is
   begin
      return AAA.Strings.Diff (Hex_Dump (A), Hex_Dump (B),
                               A_Name, B_Name, Skip_Header);
   end Diff;

   -----------
   -- Image --
   -----------

   function Image (D : Storage_Array) return String is
      use Ada.Strings.Unbounded;
      Result : Unbounded_String;

      First : Boolean := True;
   begin
      Append (Result, "[");
      for Elt of D loop
         if First then
            First := False;
         else
            Append (Result, ", ");
         end if;

         Append (Result,
                 UInt4_To_Char (UInt4 (Shift_Right (Elt, 4))) &
                   UInt4_To_Char (UInt4 (Elt and 16#0F#)));
      end loop;

      Append (Result, "]");
      return To_String (Result);
   end Image;

   -----------
   -- Image --
   -----------

   function Image (D : Data_Frame) return String is
      use Ada.Strings.Unbounded;
      Result : Unbounded_String;

      First : Boolean := True;
   begin
      Append (Result, "[");
      for Elt of D loop
         if First then
            First := False;
         else
            Append (Result, ", ");
         end if;

         Append (Result,
                 UInt4_To_Char (UInt4 (Shift_Right (Elt, 4))) &
                   UInt4_To_Char (UInt4 (Elt and 16#0F#)));
      end loop;

      Append (Result, "]");
      return To_String (Result);
   end Image;

   ----------------------
   -- Number_Of_Frames --
   ----------------------

   function Number_Of_Frames
     (This : Abstract_Data_Processing) return Storage_Count
   is
   begin
      return Storage_Count (This.Frames.Length);
   end Number_Of_Frames;

   -----------
   -- Clear --
   -----------

   procedure Clear (This : in out Abstract_Data_Processing) is
   begin
      This.Frames.Clear;
      This.Current_Frame.Clear;
   end Clear;

   ---------------
   -- Get_Frame --
   ---------------

   function Get_Frame
     (This : Abstract_Data_Processing'Class;
      Index : Storage_Count)
      return Data_Frame
   is
   begin
      return This.Frames (Index);
   end Get_Frame;

   ---------------------
   -- Start_New_Frame --
   ---------------------

   procedure Start_New_Frame (This : in out Abstract_Data_Processing) is
   begin
      This.Current_Frame.Clear;
   end Start_New_Frame;

   -------------------
   -- Push_To_Frame --
   -------------------

   procedure Push_To_Frame
     (This : in out Abstract_Data_Processing; Data : Storage_Element)
   is
   begin
      This.Current_Frame.Append (Data);
   end Push_To_Frame;

   ----------------
   -- Save_Frame --
   ----------------

   procedure Save_Frame (This : in out Abstract_Data_Processing) is
   begin
      This.Frames.Append (This.Current_Frame);
   end Save_Frame;

end Test_Utils;
