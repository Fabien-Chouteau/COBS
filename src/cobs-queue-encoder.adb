with BBqueue; use BBqueue;

package body COBS.Queue.Encoder is

   procedure Ensure_Buffer (This    : in out Instance;
                            Success :    out Boolean);

   procedure Set (This  : in out Instance;
                  Index : Storage_Offset;
                  Data  :        Storage_Element)
     with Pre => State (This.WG) = Valid,
     Inline;

   -------------------
   -- Ensure_Buffer --
   -------------------

   procedure Ensure_Buffer (This    : in out Instance;
                            Success :    out Boolean)
   is
   begin
      if State (This.WG) /= Valid then
         Grant (This.Queue, This.WG, Min_Buf_Size);

         if State (This.WG) /= Valid then
            Success := False;
            return;
         end if;

         This.Code_Pointer := This.Buffer'First + Slice (This.WG).From;
         This.Encode_Pointer := This.Code_Pointer + 1;
      end if;

      Success := True;
      return;
   end Ensure_Buffer;

   ---------
   -- Set --
   ---------

   procedure Set (This  : in out Instance;
                  Index :        Storage_Offset;
                  Data  :        Storage_Element)
   is
   begin
      if Index not in This.Buffer'First + Slice (This.WG).From ..
        This.Buffer'First + Slice (This.WG).To
      then
         raise Program_Error;
      end if;

      This.Buffer (Index) := Data;
   end Set;

   ----------
   -- Push --
   ----------

   procedure Push (This    : in out Instance;
                   Data    :        Storage_Element;
                   Success :    out Boolean)
   is
   begin
      Ensure_Buffer (This, Success);
      if not Success then
         return;
      end if;

      if Data /= 0 then
         Set (This, This.Encode_Pointer, Data);
         This.Encode_Pointer := This.Encode_Pointer + 1;
         This.Code := This.Code + 1;
      end if;

      if Data = 0 or else This.Code = 16#FF# then
         Set (This, This.Code_Pointer, This.Code);
         This.Prev_Code := This.Code;

         Commit (This.Queue, This.WG, Count (This.Code));

         This.Code := 1;
      end if;

   end Push;

   ---------------
   -- End_Frame --
   ---------------

   procedure End_Frame (This    : in out Instance;
                        Success :    out Boolean)
   is
   begin
      Ensure_Buffer (This, Success);
      if not Success then
         return;
      end if;

      if This.Code /= 1 or else This.Prev_Code /= 16#FF# then
         Set (This, This.Code_Pointer, This.Code);
         Set (This, This.Encode_Pointer, 0);

         Commit (This.Queue, This.WG, Count (This.Code) + 1);
      else
         Set (This, This.Code_Pointer, 0);
         Commit (This.Queue, This.WG, Count (This.Code));
      end if;

      This.Code := 1;
      This.Prev_Code := 1;
   end End_Frame;

   ----------------
   -- Read_Slice --
   ----------------

   function Read_Slice (This : in out Instance) return Slice_Rec is

      function Make_Slice return Slice_Rec
        with Pre => State (This.RG) = Valid;

      function Make_Slice return Slice_Rec is
         Slice : constant BBqueue.Slice_Rec := BBqueue.Slice (This.RG);
      begin
         return (Slice.Length,
                 This.Buffer (This.Buffer'First + Slice.From)'Address);
      end Make_Slice;
   begin
      if State (This.RG) = Valid then

         --  We already have a read grant
         return Make_Slice;
      else

         --  Try to get a new read grant
         BBqueue.Read (This.Queue, This.RG);

         if State (This.RG) = Valid then
            return Make_Slice;
         else

            --  No data available
            return (0, System.Null_Address);
         end if;
      end if;
   end Read_Slice;

   -------------
   -- Release --
   -------------

   procedure Release (This : in out Instance) is
   begin
      if State (This.RG) = Valid then
         BBqueue.Release (This.Queue, This.RG);
      end if;
   end Release;

   -------------
   -- Read_CB --
   -------------

   procedure Read_CB (This   : in out Instance;
                      Result :    out Result_Kind)
   is
      G : Read_Grant := Empty;
   begin
      Read (This.Queue, G);
      Result := State (G);

      if Result = Valid then
         declare
            S : constant BBqueue.Slice_Rec := BBqueue.Slice (G);
            B : Storage_Array renames This.Buffer;
            To_Release : Count;
         begin
            Process_Read (B (B'First + S.From .. B'First + S.To),
                          To_Release);

            Release (This.Queue, G, To_Release);

            pragma Assert (State (G) = Empty);
         end;
      end if;
   end Read_CB;

end COBS.Queue.Encoder;
