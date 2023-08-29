with Ada.Text_IO; use Ada.Text_IO;

package body Drone_Control is


function Calculate_Force (Position:Float; Speed: Float; Target_Position: Float) return Float is
begin
    return ((Target_Position - Position) - 0.5 * Speed);
end Calculate_Force;


function HW_CB (Request : AWS.Status.Data) return AWS.Response.Data is
    pragma Unreferenced (Request);
    Position_X : Float;
    Position_Y : Float;
    Position_Z : Float;
    Current_Postition : Vec3;
    Current_Speed : Vec3;
    Time_Interval : Float;
    Second_Last_Index : Natural;
    Force_X : Float;
    Force_Y : Float;
    Force_Z : Float;
    Taget_X : Float := 10.0;
    Taget_Y : Float := 10.0;
    Taget_Z : Float := 10.0;
begin
    
    Position_X := Float'Value (AWS.Parameters.Get (AWS.Status.Parameters (Request), "position_x"));
    Position_Y := Float'Value (AWS.Parameters.Get (AWS.Status.Parameters (Request), "position_y"));
    Position_Z := Float'Value (AWS.Parameters.Get (AWS.Status.Parameters (Request), "position_z"));

    timestamps.append(Clock);

    Current_Postition := (X=>Position_X, Y=>Position_Y, Z=>Position_Z);

    if timestamps.Last_Index > 1 then 
        Second_Last_Index := Natural(Integer(timestamps.Last_Index) - 1);
        Time_Interval := Float(timestamps.Last_Element - timestamps(Second_Last_Index));
        Current_Speed := (
                            X => (Position_X - positions.Last_Element.X) / Time_Interval, 
                            Y => (Position_Y - positions.Last_Element.Y) / Time_Interval, 
                            Z => (Position_Z - positions.Last_Element.Z) / Time_Interval
                        );
    else
        Current_Speed := (
                            X => 0.0,
                            Y => 0.0,
                            Z => 0.0
                        );
    end if;

    positions.Append(Current_Postition);
    speeds.Append(Current_Speed);

    Put_Line ("X: " & AWS.Parameters.Get (AWS.Status.Parameters (Request), "position_x"));
    Put_Line ("Y: " & AWS.Parameters.Get (AWS.Status.Parameters (Request), "position_y"));
    Put_Line ("Z: " & AWS.Parameters.Get (AWS.Status.Parameters (Request), "position_z"));

    Force_X := Calculate_Force(Position_X, Current_Speed.X, 10.0);
    Force_Y := 9.81 + Calculate_Force(Position_Y, Current_Speed.Y, 10.0);
    Force_Z := Calculate_Force(Position_Z, Current_Speed.Z, 10.0);
    Put_Line("Force_X: " & Float'Image(Force_X));
    Put_Line("Force_Y: " & Float'Image(Force_Y));
    Put_Line("Force_Z: " & Float'Image(Force_Z));

    return AWS.Response.Build ("text/json", "{ ""force"" :[" 
                                    & Float'Image(Force_X) & ", " 
                                    & Float'Image(Force_Y) & ", " 
                                    & Float'Image(Force_Z) & "]}");
end HW_CB;

end Drone_Control;