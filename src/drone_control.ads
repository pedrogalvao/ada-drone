with AWS.Response;
with AWS.Status;
with AWS.Server;
with AWS.Parameters;
with Ada.Calendar; use Ada.Calendar;
with Ada.Containers.Vectors;
with Ada.Containers; use Ada.Containers;

package Drone_Control is

   type Vec3 is record 
      X : Float;
      Y : Float;
      Z : Float;
   end record;

   
   package Vec3Vector is new
     Ada.Containers.Vectors
       (Index_Type   => Natural,
        Element_Type => Vec3);

   package TimeVector is new
     Ada.Containers.Vectors
       (Index_Type   => Natural,
        Element_Type => Time);
      
   timestamps : TimeVector.Vector;
   positions : Vec3Vector.Vector;
   speeds : Vec3Vector.Vector;

   function HW_CB (Request : AWS.Status.Data) return AWS.Response.Data;

end Drone_Control;